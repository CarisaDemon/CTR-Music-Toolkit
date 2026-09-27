#include <common.h>

enum LibraryOfModelsConstants
{
	LIBRARY_OF_MODELS_CLEAR_COUNT = 0xe2,
	LIBRARY_OF_MODELS_CAPACITY = 0xe3,
};

#if defined(CTR_NATIVE)
static int LibraryOfModels_NativeRangeInMempack(const void *ptr, size_t bytes)
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

// NOTE(aalhendi): ASM-verified NTSC-U 926 0x8003147c-0x800314c0.
void LibraryOfModels_Store(struct GameTracker *gGT, u32 numModels, struct Model **ptrModelArray)
{
#if defined(CTR_NATIVE)
	const int listIsNativeMempack = LibraryOfModels_NativeRangeInMempack(ptrModelArray, sizeof(*ptrModelArray));
#endif

	while (numModels != 0)
	{
#if defined(CTR_NATIVE)
		if (listIsNativeMempack && !LibraryOfModels_NativeRangeInMempack(ptrModelArray, sizeof(*ptrModelArray)))
		{
			return;
		}
#endif

		struct Model *m = *ptrModelArray;
		if (m == NULL)
		{
			return;
		}

#if defined(CTR_NATIVE)
		if (listIsNativeMempack && !LibraryOfModels_NativeRangeInMempack(m, sizeof(*m)))
		{
			return;
		}
#endif

		if (m->id != -1)
		{
#if defined(CTR_NATIVE)
			if ((m->id < 0) || (m->id >= LIBRARY_OF_MODELS_CAPACITY))
			{
				return;
			}
#endif
			gGT->modelPtr[m->id] = m;
		}
		numModels--;
		ptrModelArray++;
	}
}

// NOTE(aalhendi): ASM-verified NTSC-U 926 0x800314c0-0x800314e0.
void LibraryOfModels_Clear(struct GameTracker *gGT)
{
	for (s32 i = 0; i < LIBRARY_OF_MODELS_CLEAR_COUNT; i++)
	{
		gGT->modelPtr[i] = 0;
	}
}
