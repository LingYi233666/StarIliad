@echo off

set DST_MOD_DIR=D:\Steam\steamapps\common\Don't Starve Together\mods
set STARILIAD_MOD_DIR=%DST_MOD_DIR%\StarIliad
set RELEASE_MOD_DIR=%DST_MOD_DIR%\StarIliad_release

@REM cd "%STARILIAD_MOD_DIR%"
git clone "%STARILIAD_MOD_DIR%" "%RELEASE_MOD_DIR%" 

@REM cd %RELEASE_MOD_DIR%
@REM rm -rf .git