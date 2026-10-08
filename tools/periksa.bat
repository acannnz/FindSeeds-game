@echo off
rem Pemeriksa stage dan uji otomatis FindSeeds.
rem   tools\periksa.bat                  periksa semua stage di data\stage
rem   tools\periksa.bat --semua          pemeriksa stage + semua uji
rem   tools\periksa.bat --uji            uji mandiri pemeriksa
rem   tools\periksa.bat --uji-logika     uji logika murni (kantong, aturan aksi)
rem   tools\periksa.bat --uji-gerak      uji gerak dan tabrakan
rem   tools\periksa.bat --uji-interaksi  uji interaksi di stage sungguhan
rem   tools\periksa.bat --uji-main       bot memainkan solusi tercepat tiap stage
rem   tools\periksa.bat --uji-alur       timer, jeda, waktu habis, bintang, lanjut
rem   tools\periksa.bat --uji-plugin     plugin editor pemeriksa (Run dibatalkan jika stage salah)
rem   tools\periksa.bat --uji-kontrol    joystick dinamis, tombol aksi melayang, label target, tata letak
rem   tools\periksa.bat --uji-aset       aset gambar lengkap, bisa dimuat, cadangan placeholder
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
rem --fixed-fps membuat simulasi deterministik dan secepat mungkin.
set "JALAN=%GODOT% --headless --fixed-fps 60 --path "%PROYEK%" --script"
if /i "%~1"=="--semua" goto semua
if /i "%~1"=="--uji" (%JALAN% res://tools/uji_pemeriksa.gd & exit /b)
if /i "%~1"=="--uji-logika" (%JALAN% res://tools/uji_logika.gd & exit /b)
if /i "%~1"=="--uji-gerak" (%JALAN% res://tools/uji_gerak.gd & exit /b)
if /i "%~1"=="--uji-interaksi" (%JALAN% res://tools/uji_interaksi.gd & exit /b)
if /i "%~1"=="--uji-main" (%JALAN% res://tools/uji_main.gd & exit /b)
if /i "%~1"=="--uji-alur" (%JALAN% res://tools/uji_alur.gd & exit /b)
if /i "%~1"=="--uji-plugin" (%JALAN% res://tools/uji_plugin.gd & exit /b)
if /i "%~1"=="--uji-kontrol" (%JALAN% res://tools/uji_kontrol.gd & exit /b)
if /i "%~1"=="--uji-aset" (%JALAN% res://tools/uji_aset.gd & exit /b)

%JALAN% res://tools/pemeriksa_stage.gd -- %*
exit /b %ERRORLEVEL%

:semua
set "GAGAL=0"
rem Impor aset dulu supaya tekstur SVG tersedia (perlu di clone baru).
echo ===== impor aset
"%GODOT%" --headless --path "%PROYEK%" --import >nul 2>&1
for %%S in (pemeriksa_stage uji_pemeriksa uji_logika uji_gerak uji_interaksi uji_main uji_alur uji_plugin uji_kontrol uji_aset) do (
	echo.
	echo ===== %%S
	%JALAN% res://tools/%%S.gd
	if errorlevel 1 set "GAGAL=1"
)
echo.
if "%GAGAL%"=="1" (
	echo HASIL AKHIR: ADA YANG GAGAL
	exit /b 1
)
echo HASIL AKHIR: SEMUA LOLOS
exit /b 0
