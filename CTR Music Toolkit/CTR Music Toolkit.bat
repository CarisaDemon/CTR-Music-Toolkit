@echo off
setlocal
title CTR Music Toolkit
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0CTR_Music_Toolkit_GUI.ps1"
endlocal
