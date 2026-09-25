# CTR Music Toolkit

Custom OGG music for **CTR Native**, the PC port of *Crash Team Racing* (1999). This repository contains the Windows music manager and the source code used for the CTR Native custom music build.

> **Game files are not included.** You must supply your own legally obtained NTSC-U game disc image. Pirated copies are not supported or endorsed.

## What it does

- Replace a track by selecting its in-game Level ID and choosing an OGG Vorbis file.
- Create a separate, faster Final Lap track while preserving the original pitch.
- Keep custom tracks organized in the game's `assets/MUSIC_CUSTOM/` folder.
- Back up, restore, and remove custom tracks through the Toolkit.
- Use the game's music volume setting with supported custom music builds.
- Let the supported music core handle Adventure hub transitions, mask music, Final Lap, and race results without overlapping the custom track with the game's transition music.

The Toolkit manages music files. **Playing custom OGG music requires a CTR Native build with the custom music core**; an unmodified CTR Native executable does not gain OGG support simply by placing files in `assets/MUSIC_CUSTOM/`.

## Quick start: Windows release

1. Download the latest compiled Windows package from this repository's **Releases** page and extract it.
2. Provide your own legally obtained game disc image as `assets/ctr-u.bin`, next to `ctr_native.exe`.
3. Run `CTR Music Toolkit/CTR Music Toolkit.bat`.
4. Select the folder containing `ctr_native.exe` with **Browse...**, or type or paste that folder's path and press Enter. A path ending in `ctr_native.exe` also works.
5. Choose a track's Level ID, then double-click it to select an `.ogg` file. You can also use **Add / Replace** to enter an ID manually.
6. Start `ctr_native.exe` and test the track in game.

The Toolkit creates `assets/MUSIC_CUSTOM/` when needed. For a release build, the relevant files look like this:

```text
CTR Native/
├── ctr_native.exe
├── assets/
│   ├── ctr-u.bin                 # Your own game image; not distributed here
│   └── MUSIC_CUSTOM/
│       ├── level_XX.ogg          # Regular track
│       └── level_XX_final.ogg    # Optional Final Lap track
└── CTR Music Toolkit/
    ├── CTR Music Toolkit.bat
    └── CTR_Music_Toolkit_GUI.ps1
```

`XX` stands for a Level ID. Some IDs are still shown as numbers because their in-game locations have not been confirmed. The Toolkit displays available IDs even when they do not have a custom OGG yet.

### Final Lap

Select a Level ID with a regular custom OGG and click **Create Final Lap**. The Toolkit creates `level_XX_final.ogg` at **1.12× speed** while keeping the pitch. This operation uses FFmpeg; if it is missing, the Toolkit can offer to download it. After replacing a regular OGG, create its Final Lap version again to keep the two tracks matched.

### Managing your music

| Control | Action |
| --- | --- |
| **Add / Replace** | Assign an OGG to a Level ID. |
| **Remove Selected** | Remove the selected custom track and its Final Lap version. |
| **Remove All** | Remove all custom OGG tracks from the selected game folder. |
| **Backup** | Copy custom music to `CTR_Music_Backup/`. |
| **Restore** | Restore a backup you select. |
| **Open Folder** | Open `assets/MUSIC_CUSTOM/`. |

Use genuine **OGG Vorbis** audio files. Changing the extension of another format to `.ogg` does not convert it.

## Building CTR Native from source

The source directory contains the CTR Native build scripts, `game/` code, `include/` headers, `platform/` code, and bundled SDL3 sources. See its own `README.md` for the full toolchain setup and Linux instructions.

On Windows, the source supports either Visual Studio Build Tools with the **Desktop development with C++** workload (`build-msvc.bat`) or the 32-bit MinGW toolchain (`build.bat`). SDL3 is built from the bundled source. To build a custom music version, apply the music core to a compatible source tree **before** running the build script. Use the instructions supplied with that core patch; rebuilding an unmodified source tree will produce the original audio behavior.

For the MinGW build, the executable is normally `build/ctr_native.exe`. The upstream CTR Native README also describes the MSVC output path. Place your own `assets/ctr-u.bin` at the location specified there for a development build.

**Disc format:** CTR Native expects a single-track raw PS1 BIN image with MODE2/2352 sectors and the data track starting at byte 0. A cooked 2048-byte `.iso` does not contain the XA/STR data required for all audio and video playback. See the CTR Native source README for extracted-asset override options.

## Troubleshooting

- **The custom track does not play:** confirm you are launching a build with the custom music core, the Toolkit points to that game's folder, and the Level ID matches the location being played. Check `assets/MUSIC_CUSTOM/level_XX.ogg`.
- **Final Lap uses the regular song:** generate `level_XX_final.ogg` with **Create Final Lap** and confirm the custom music core is present in the build you launched.
- **The Toolkit does not open:** start it with `CTR Music Toolkit.bat` on Windows and keep its PowerShell script alongside the batch file.
- **A displayed track name seems wrong:** use its numeric Level ID; some location names are still unverified.

## Project layout

Depending on the release and source layout, you may find:

| Item | Purpose |
| --- | --- |
| `CTR Music Toolkit.bat` / `CTR_Music_Toolkit_GUI.ps1` | Windows track manager. |
| `ctr-native/` or the source directory | CTR Native game and platform source. |
| `game/`, `include/`, `platform/` | Game code, declarations, and native platform implementation inside the source tree. |
| `externals/` | Bundled dependencies and build support inside the source tree. |
| Releases | Compiled Windows downloads, when published. |

The compiled package and the source tree may use different directory layouts; follow the README bundled with the download you choose.

## Credits and legal information

CTR Native builds on [CTR-ModSDK](https://github.com/CTR-tools/CTR-ModSDK). Its native platform work uses material derived in part from [PsyCross](https://github.com/OpenDriver2/PsyCross), and it bundles [SDL3](https://github.com/libsdl-org/SDL). See the source tree and third-party notices for their respective terms.

*Crash Team Racing* and its game assets belong to their respective rights holders. This project does **not** provide a game disc image, ISO, or copyrighted game assets. Obtain any required game files legally; pirated copies are not supported or endorsed.
