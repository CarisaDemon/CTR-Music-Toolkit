#include <common.h>

#if defined(CTR_NATIVE)
#include "platform/native_log.h"
#endif

// NOTE(aalhendi): ASM-verified NTSC-U 926 0x80021984-0x80021a20.
void CTR_CycleTex_LEV(struct AnimTex *animtex, int timer)
{
	int frameCurr;
	struct AnimTex *curAnimTex = animtex;

	// Termination is determined by pointer to First AnimTex
	while (*(int *)curAnimTex != (int)animtex)
	{
		// which texture to draw this frame
		frameCurr = timer + curAnimTex->frameOffset;

		// allow frames to skip updating (like 60fps hacks)
		frameCurr = frameCurr >> curAnimTex->frameSkip;

		// loop back to index[0] after finished cycle
		frameCurr = frameCurr % curAnimTex->numFrames;

		// save result
		curAnimTex->frameCurr = frameCurr;

		struct IconGroup4 **ptrArray = ANIMTEX_GETARRAY(curAnimTex);

		// Save new frame
		// For levels, this is just a pointer
		curAnimTex->ptrActiveTex = (int *)ptrArray[frameCurr];

		// Go to next AnimTex, which comes after this AnimTex's ptrarray
		curAnimTex = (struct AnimTex *)&ptrArray[curAnimTex->numFrames];
	}
}

// NOTE(aalhendi): ASM-verified NTSC-U 926 0x80021a20-0x80021ac0.
void CTR_CycleTex_Model(struct AnimTex *animtex, int timer)
{
	int frameCurr;
	struct AnimTex *curAnimTex = animtex;

	// Termination is determined by pointer to First AnimTex
	while (*(int *)curAnimTex != (int)animtex)
	{
		// which texture to draw this frame
		frameCurr = timer + curAnimTex->frameOffset;

		// allow frames to skip updating (like 60fps hacks)
		frameCurr = frameCurr >> curAnimTex->frameSkip;

		// loop back to index[0] after finished cycle
		frameCurr = frameCurr % curAnimTex->numFrames;

		// save result
		curAnimTex->frameCurr = frameCurr;

		struct IconGroup4 **ptrArray = ANIMTEX_GETARRAY(curAnimTex);

		// Save new frame
		// For Model, this is a pointer to a pointer
		*curAnimTex->ptrActiveTex = (int)ptrArray[frameCurr];

		// Go to next AnimTex, which comes after this AnimTex's ptrarray
		curAnimTex = (struct AnimTex *)&ptrArray[curAnimTex->numFrames];
	}
}

#if defined(CTR_NATIVE)
static int CTR_CycleTex_NativeRangeInMempack(const void *ptr, size_t bytes)
{
	const struct PlatformMempackArena *arena = Platform_GetMempackArena();
	const u8 *p = (const u8 *)ptr;
	const u8 *base;
	const u8 *end;

	if ((arena == NULL) || (arena->base == NULL) || (arena->endOfMemory == NULL) || (ptr == NULL))
		return 0;

	base = (const u8 *)arena->base;
	end = (const u8 *)arena->endOfMemory;
	if ((p < base) || (p > end))
		return 0;
	return bytes <= (size_t)(end - p);
}
#endif

// NOTE(aalhendi): ASM-verified NTSC-U 926 0x80021ac0-0x80021b94.
void CTR_CycleTex_AllModels(u32 numModels, struct Model **pModelArray, int timer)
{
	struct Model *pModel;
	struct ModelHeader *pHeader;

	if (pModelArray == NULL)
	{
		return;
	}

	if (numModels == 0)
	{
		return;
	}

	const int modelListIsNativeMempack =
#if defined(CTR_NATIVE)
	    CTR_CycleTex_NativeRangeInMempack(pModelArray, sizeof(*pModelArray));
#else
	    0;
#endif

	while (true)
	{
#if defined(CTR_NATIVE)
		if (modelListIsNativeMempack && !CTR_CycleTex_NativeRangeInMempack(pModelArray, sizeof(*pModelArray)))
			return;
#endif

		pModel = *pModelArray;
		if (pModel == NULL)
		{
			return;
		}

#if defined(CTR_NATIVE)
		if (modelListIsNativeMempack && !CTR_CycleTex_NativeRangeInMempack(pModel, sizeof(*pModel)))
		{
			static const void *s_lastBadModel;
			if (s_lastBadModel != pModel)
			{
				Platform_LogWarn("[CycleTex] skipping transient invalid Model pointer %p at timer=%d\n", (void *)pModel, timer);
				s_lastBadModel = pModel;
			}
			return;
		}

		if ((pModel->numHeaders < 0) ||
		    ((pModel->numHeaders > 0) && modelListIsNativeMempack &&
		     !CTR_CycleTex_NativeRangeInMempack(pModel->headers, (size_t)pModel->numHeaders * sizeof(*pModel->headers))))
		{
			Platform_LogWarn("[CycleTex] skipping transient invalid Model headers model=%p headers=%p count=%d timer=%d\n",
			                 (void *)pModel, (void *)pModel->headers, (int)pModel->numHeaders, timer);
			return;
		}
#endif

		// iterate over all model headers
		for (int j = 0; j < pModel->numHeaders; j++)
		{
			pHeader = &pModel->headers[j];

			if ((pHeader->animtex != NULL) && ((pHeader->flags & 2) == 0))
			{
				CTR_CycleTex_Model(pHeader->animtex, timer);
			}
		}

		numModels--;
		if (numModels == 0)
		{
			return;
		}

		pModelArray++;
	}
}

// NOTE(aalhendi): ASM-verified NTSC-U 926 0x80021b94-0x80021bbc.
void CTR_CycleTex_2p3p4pWumpaHUD(u32 *ptrActiveTex, u32 *ptrArray, int numFrames)
{
	ptrArray[0] = ptrActiveTex[0];
	ptrActiveTex[0] = CtrGpu_PrimToOTLink24(&ptrArray[numFrames - 1]);
}
