set OLDDIR=%CD%
cd /d %~dp0

for /f "tokens=3" %%a in ('findstr GPAC_SVN_REVISION "..\..\..\..\include\gpac\revision.h"') do set gpac_revision=%%a
set gpac_revision=%gpac_revision:"=%
set gpac_version="0.5.1-DEV-r%gpac_revision%"

zip "GPAC_%gpac_version%_WindowsMobile.zip" ../*.dll ../*.exe ../*.plg

cd /d %OLDDIR%
