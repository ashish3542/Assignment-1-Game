@echo off
setlocal
set "GODOT=%USERPROFILE%\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe"
if exist "%GODOT%" goto launch
set "GODOT=%USERPROFILE%\Downloads\Godot_v4.7.2-stable_win64.exe"
if exist "%GODOT%" if not exist "%GODOT%\NUL" goto launch
echo Godot was not found in its original download location.
echo Open Godot, import this folder's project.godot, and press F5.
echo Read RUN_GAME.md for complete instructions.
pause
exit /b 1
:launch
"%GODOT%" --path "%~dp0."
