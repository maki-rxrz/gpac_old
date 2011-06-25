@echo off
set OLDDIR=%CD%
cd /d %~dp0
REM ============================================
echo *** Generating a Windows GPAC installer ***
REM ============================================


echo:
REM ============================================
echo Check NSIS is in your PATH
REM ============================================

set NSIS_EXEC="%PROGRAMFILES%\NSIS\makensis.exe"
if not exist "%PROGRAMFILES%\NSIS\makensis.exe" echo   NSIS couldn't be found at default location %NSIS_EXEC%
if not exist "%PROGRAMFILES%\NSIS\makensis.exe" goto Abort
echo   Found NSIS at default location %NSIS_EXEC%


echo:
REM ============================================
echo Retrieving version/revision information
REM ============================================
if not exist include/gpac/revision.h echo   version couldn't be found - check include/gpac/revision.h exists
if not exist include/gpac/revision.h goto Abort

REM execute `git rev-list HEAD -1 --abbrev-commit` and check if the result if found within revision.h
for /f "delims=" %%i in ('git rev-list HEAD -1 --abbrev-commit') do Set VarRevisionGIT=%%i
for /f "tokens=3" %%a in ('findstr GPAC_SVN_REVISION "include\gpac\revision.h"') do set VarRevisionSVN=%%a
for /f "tokens=3" %%a in ('findstr GPAC_GIT_REV_HASH "include\gpac\revision.h"') do set VarRevisionBuild=%%a
set VarRevisionSVN=%VarRevisionSVN:"=%
set VarRevisionBuild=%VarRevisionBuild:"=%
echo VarRevisionBuild = %VarRevisionBuild%
echo VarRevisionGIT   = %VarRevisionGIT%
if !"%VarRevisionBuild%"==!"%VarRevisionGIT%" echo   local revision and last build revision are not congruent - please consider rebuilding before generating an installer
if !"%VarRevisionBuild%"==!"%VarRevisionGIT%" goto Abort
REM echo   version found: %VarRevisionSVN%

move bin\win32\release\nsis_install\default.out bin\win32\release\nsis_install\default.out_
echo Name "GPAC Framework ${GPAC_VERSION} revision %VarRevisionSVN%" > bin\win32\release\nsis_install\default.out
echo OutFile "GPAC.Framework.Setup-${GPAC_VERSION}-rev%VarRevisionSVN%.exe" >> bin\win32\release\nsis_install\default.out


echo:
REM ============================================
echo Executing NSIS
REM ============================================
call %NSIS_EXEC% bin\win32\release\nsis_install\gpac_installer.nsi


echo:
REM ============================================
echo Removing temporary files
REM ============================================
move bin\win32\release\nsis_install\default.out_ bin\win32\release\nsis_install\default.out


echo:
REM ============================================
echo Windows GPAC installer generated - goodbye!
REM ============================================
REM LeaveBatchSuccess
set VarRevisionGIT=
set VarRevisionSVN=
set VarRevisionBuild=
cd /d %OLDDIR%
exit/b 0

:Abort
echo:
echo  *** ABORTING: CHECK ERROR MESSAGES ABOVE ***

REM LeaveBatchError
set VarRevisionGIT=
set VarRevisionSVN=
set VarRevisionBuild=
cd /d %OLDDIR%
exit/b 1
