@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ============================================
echo App Migration Script
echo ============================================

:: Step 1: Create target dir
if not exist "E:\soft" mkdir "E:\soft"

:: Step 2: Migrate each app
call :migrate "C:\Keil_v5" "E:\soft\Keil_v5" "Keil v5"
call :migrate "C:\ST" "E:\soft\ST" "STM32 Tools"
call :migrate "C:\Program Files\AnsysEM" "E:\soft\AnsysEM" "ANSYS EM"
call :migrate "C:\Program Files\Microsoft Visual Studio" "E:\soft\VS2022" "Visual Studio"

echo.
echo ============================================
echo Migration complete!
echo ============================================
echo.
echo C: drive free space:
wmic logicaldisk where "DeviceID='C:'" get FreeSpace /value

echo.
echo Checking junctions:
dir /AL "C:\Keil_v5" 2>nul && echo   Keil v5: OK
dir /AL "C:\ST" 2>nul && echo   STM32 Tools: OK
dir /AL "C:\Program Files\AnsysEM" 2>nul && echo   ANSYS EM: OK
dir /AL "C:\Program Files\Microsoft Visual Studio" 2>nul && echo   Visual Studio: OK

pause
exit /b 0

:migrate
set SRC=%~1
set DST=%~2
set LABEL=%~3

echo.
echo --- %LABEL% ---
echo Source: %SRC%
echo Target: %DST%

if not exist "%SRC%" (
    echo SKIP: source not found
    exit /b 0
)

if exist "%DST%" (
    echo WARNING: target already exists
    exit /b 0
)

echo Moving files with robocopy...
robocopy "%SRC%" "%DST%" /E /COPY:DAT /DCOPY:T /MOVE /R:2 /W:3 /NP /NFL /NDL /NJH /NJS
set RC=%ERRORLEVEL%
if %RC% geq 8 (
    echo ERROR: robocopy failed with code %RC%
    exit /b 1
)
echo Files moved successfully (code %RC%)

:: Remove empty source dir if still exists
if exist "%SRC%" rd /s /q "%SRC%" 2>nul

:: Create junction
mklink /J "%SRC%" "%DST%"
if %ERRORLEVEL% equ 0 (
    echo Junction created: %SRC% -^> %DST%
    echo OK: %LABEL% migrated
) else (
    echo FAILED to create junction. Files at %DST%.
    echo Run manually: mklink /J "%SRC%" "%DST%"
)
exit /b 0
