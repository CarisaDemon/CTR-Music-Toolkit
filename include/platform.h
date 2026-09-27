#ifndef PLATFORM_H
#define PLATFORM_H

struct PlatformMempackArena
{
	void *base;
	void *start;
	void *endOfMemory;
	int size;
	int backingSize;
};

void Platform_Init(const char *title, int width, int height);
void Platform_Shutdown(void);
void Platform_InitScratchpad(void);
const struct PlatformMempackArena *Platform_InitMempackArena(void);
const struct PlatformMempackArena *Platform_GetMempackArena(void);
void Platform_BeginFrame(void);
int Platform_BeginScene(void);
void Platform_EndScene(void);
void Platform_EndFrame(void);
int Platform_GetDisplayFPS(void);
void Platform_PresentVRAMDisplay(void);
void Platform_PinVRAMDisplayFrames(int frameCount);
void Platform_PinVRAMDisplayRect(int x, int y, int w, int h, int frameCount);
int Platform_GetVBlankCount(void);
void Platform_WaitUntilVBlank(int targetVBlank);
void Platform_PollHostEvents(void);
int Platform_PollInput(void);
#if defined(CTR_NATIVE)
int Platform_GetWideMode(void);
void Platform_SetWideMode(int enabled);
int Platform_GetHighRefreshMode(void);
void Platform_SetHighRefreshMode(int enabled);
int Platform_GetHighRefreshTargetFPS(void);
void Platform_WaitForHighRefreshFrame(void);
void Platform_UpdateLegacy30HzClock(int elapsedTimeMS);
int Platform_GetLegacy30HzTicks(void);
int Platform_GetSubpixelMode(void);
void Platform_SetSubpixelMode(int enabled);
#endif

#if defined(CTR_NATIVE)
int NikoGetEnterKey(void);
#endif

#endif
