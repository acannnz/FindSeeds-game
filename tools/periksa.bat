@echo off
rem Pemeriksa stage FindSeeds.
rem   tools\periksa.bat                  periksa semua stage di data\stage
rem   tools\periksa.bat --uji            jalankan uji mandiri pemeriksa
rem   tools\periksa.bat --uji-gerak      jalankan uji gerak dan tabrakan
rem   tools\periksa.bat --data=FOLDER    periksa data di folder lain
rem   tools\periksa.bat --stage=FOLDER   periksa file stage di folder lain
rem Lokasi Godot bisa diganti lewat variabel lingkungan GODOT.
setlocal
if "%GODOT%"=="" set "GODOT=D:\Download\Godot_v4.7.2-stable_win64\Godot_v4.7.2-stable_win64_console.exe"
if not exist "%GODOT%" (
	echo Godot tidak ditemukan di "%GODOT%". Atur variabel GODOT ke Godot_v4.x_console.exe.
	exit /b 2
)
set "PROYEK=%~dp0.."
if /i "%~1"=="--uji" goto uji
if /i "%~1"=="--uji-gerak" goto uji_gerak

"%GODOT%" --headless --path "%PROYEK%" --script res://tools/pemeriksa_stage.gd -- %*
exit /b %ERRORLEVEL%

:uji
"%GODOT%" --headless --path "%PROYEK%" --script res://tools/uji_pemeriksa.gd
exit /b %ERRORLEVEL%

:uji_gerak
rem --fixed-fps membuat simulasi deterministik dan secepat mungkin.
"%GODOT%" --headless --fixed-fps 60 --path "%PROYEK%" --script res://tools/uji_gerak.gd
exit /b %ERRORLEVEL%
