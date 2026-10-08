@echo off
rem Build Android FindSeeds. Pemeriksa stage dan semua uji dijalankan dulu;
rem export HANYA dilakukan jika semuanya lolos.
rem   tools\build_android.bat            build debug   -> build\FindSeeds-debug.apk
rem   tools\build_android.bat release    build release -> build\FindSeeds.apk
rem Prasyarat: preset export bernama "Android" (Project > Export di editor),
rem export template Godot 4.7.2, dan Android SDK yang diatur di Editor Settings.
rem Nama preset bisa diganti lewat variabel lingkungan PRESET, lokasi Godot lewat GODOT.
setlocal
if "%GODOT%"=="" set "GODOT=D:\Download\Godot_v4.7.2-stable_win64\Godot_v4.7.2-stable_win64_console.exe"
if "%PRESET%"=="" set "PRESET=Android"
set "PROYEK=%~dp0.."

echo ===== Pemeriksa stage dan uji
call "%~dp0periksa.bat" --semua
if errorlevel 1 (
	echo.
	echo BUILD DIBATALKAN: pemeriksa stage atau uji gagal. Perbaiki dulu, lalu build ulang.
	exit /b 1
)

if not exist "%PROYEK%\export_presets.cfg" goto tanpa_preset
findstr /c:"name=\"%PRESET%\"" "%PROYEK%\export_presets.cfg" >nul || goto tanpa_preset

if not exist "%PROYEK%\build" mkdir "%PROYEK%\build"
if /i "%~1"=="release" (
	set "MODE=--export-release"
	set "KELUARAN=%PROYEK%\build\FindSeeds.apk"
) else (
	set "MODE=--export-debug"
	set "KELUARAN=%PROYEK%\build\FindSeeds-debug.apk"
)
echo.
echo ===== Export %PRESET% (%MODE%)
"%GODOT%" --headless --path "%PROYEK%" %MODE% "%PRESET%" "%KELUARAN%"
if errorlevel 1 (
	echo.
	echo BUILD GAGAL saat export. Cek export template dan Android SDK.
	exit /b 1
)
echo.
echo BUILD SELESAI: %KELUARAN%
exit /b 0

:tanpa_preset
echo.
echo Pemeriksa dan uji LOLOS, tetapi preset export "%PRESET%" belum ada.
echo Buat lewat editor: Project ^> Export ^> Add... ^> Android, beri nama "%PRESET%".
exit /b 2
