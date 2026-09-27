/*
 * Derived from REDRIVER2/PsyCross MIT source:
 * externals/PsyCross/src/psx/LIBAPI.C
 * See THIRD_PARTY_NOTICES.md for copyright and license details.
 */

#include <macros.h>

#include <psx/libapi.h>
#include <SDL3/SDL.h>

// CTR converts RCNT1 units through divisor 0x147e and then scales the result
// by 32/100 into elapsedTimeMS. Retail/native 30 FPS previously accumulated
// about 263 RCNT units per 60 Hz VBlank, i.e. 15780 units/second. Drive that
// same clock from the host high-resolution timer so game logic can run above
// 30 FPS without receiving zero time between VBlanks.
#define CTR_NATIVE_RCNT1_TICKS_PER_SECOND 15780u

global_variable u64 s_rootCounterEpoch = 0;
global_variable u64 s_rootCounterBase = 0;

internal u64 NativeRCnt_CurrentTicks(void)
{
	const u64 now = SDL_GetPerformanceCounter();
	const u64 freq = SDL_GetPerformanceFrequency();

	if (freq == 0)
	{
		return 0;
	}
	if (s_rootCounterEpoch == 0)
	{
		s_rootCounterEpoch = now;
	}

	return ((now - s_rootCounterEpoch) * CTR_NATIVE_RCNT1_TICKS_PER_SECOND) / freq;
}

void NativeRCnt_EmitVBlank(void)
{
	// RCNT1 now follows host elapsed time continuously. VBlank remains a
	// separate 60 Hz service for audio/input callbacks.
}

int SetRCnt(int spec, unsigned short target, int mode)
{
	spec &= 0xffff;
	if (spec > 2)
	{
		return 0;
	}

	(void)target;
	(void)mode;
	return 1;
}

int GetRCnt(int spec)
{
	u64 counts;

	(void)spec;

	counts = NativeRCnt_CurrentTicks() - s_rootCounterBase;
	if (counts > 0x7fffffff)
	{
		return 0x7fffffff;
	}

	return (int)counts;
}

int StartRCnt(int spec)
{
	spec &= 0xffff;
	if (spec > 2)
	{
		return 0;
	}

	s_rootCounterBase = NativeRCnt_CurrentTicks();
	return 1;
}

int StopRCnt(int spec)
{
	(void)spec;
	return 0;
}

int ResetRCnt(int spec)
{
	(void)spec;

	s_rootCounterBase = NativeRCnt_CurrentTicks();
	return 0;
}

int OpenEvent(unsigned int event, int spec, int mode, int32_t (*func)())
{
	(void)event;
	(void)spec;
	(void)mode;
	(void)func;
	return 0;
}

int CloseEvent(unsigned int event)
{
	(void)event;
	return 0;
}

int EnableEvent(unsigned int event)
{
	(void)event;
	return 0;
}

int TestEvent(unsigned int event)
{
	(void)event;
	return 0;
}

void InitCARD(int val)
{
	(void)val;
}

int StartCARD(void)
{
	return 0;
}

int StopCARD(void)
{
	return 0;
}

void _bu_init(void)
{
}
