@echo OFF
call build.bat
if NOT %ERRORLEVEL% == 1 %PLAYDATE_SDK_PATH%\bin\PlaydateSimulator.exe .\out\game.pdx
