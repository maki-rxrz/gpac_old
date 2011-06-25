@echo off
cd /d %~dp0
rem set svn_remote=remotes/svn/trunk
rem set svn_remote=origin/plain
set svn_remote=plain
for /f "tokens=3 delims=@ " %%a in ('git log -1 %svn_remote% ^| findstr git-svn-id:')            do echo #define GPAC_SVN_REVISION       "%%a"> test.h
for /f "delims=" %%a in ('git rev-list %svn_remote% ^| %SYSTEMROOT%\System32\find.exe /c /v ""') do echo #define GPAC_GIT_SVN_REVISION   "%%a">> test.h
for /f "delims=" %%a in ('git rev-list HEAD ^| %SYSTEMROOT%\System32\find.exe /c /v ""')         do echo #define GPAC_GIT_REVISION       "%%a">> test.h
for /f "delims=" %%a in ('git rev-list HEAD -1 --abbrev-commit')                                 do echo #define GPAC_GIT_REV_HASH       "%%a">> test.h
for /f "tokens=3 delims=@ " %%a in ('git log -1 %svn_remote% ^| findstr git-svn-id:')            do echo #define GPAC_GIT_VERSION        "%%a">> test.h
if not exist include\gpac\revision.h goto create
ECHO n|COMP test.h include\gpac\revision.h > nul
if errorlevel 1 goto create
DEL test.h
exit/b
:create
MOVE /Y test.h include\gpac\revision.h
