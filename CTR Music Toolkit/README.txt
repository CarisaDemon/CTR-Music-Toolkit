CTR MUSIC TOOLKIT
=================

Custom OGG music manager for the compiled CTR Native PC port.

GETTING STARTED
---------------

1. Open "CTR Music Toolkit.bat".
2. Click "Browse..." and select the folder containing ctr_native.exe. You can
   also type or paste the path into the box and press Enter. A path ending in
   ctr_native.exe works too.
3. Choose the Level ID of the track you want to replace.
4. Double-click the track and select your OGG Vorbis file. Alternatively, click
   "Add / Replace" and enter a Level ID manually.
5. Launch the game. The custom track is ready to play.

The Toolkit creates assets\MUSIC_CUSTOM in the selected game folder and stores
tracks as level_XX.ogg. Entries with only a Level ID have not yet been
identified in game; their displayed names are placeholders.

FINAL LAP
---------

Select a track with custom music and click "Create Final Lap". The Toolkit
creates a separate level_XX_final.ogg at 1.12x speed while keeping the pitch.
If FFmpeg is unavailable, you can choose to download it the first time. After
replacing a normal track, recreate its Final Lap version.

MANAGING TRACKS
---------------

- "Remove Selected" deletes the chosen custom track and its Final Lap version.
- "Remove All" deletes all custom OGG tracks from the selected game folder.
- "Backup" saves a copy of your custom tracks in CTR_Music_Backup.
- "Restore" loads a selected backup into the game folder.
- "Open Folder" opens assets\MUSIC_CUSTOM.
- "About" displays Toolkit information and the contact for ID findings.

LEGAL NOTE
----------

The Toolkit does not include a game ISO or copyrighted game assets. Obtain any
required game image legally. Pirated copies are not supported or endorsed.
