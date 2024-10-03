@echo ======================================================================
@echo === 240108.1
@echo ======================================================================
@echo off
if not "%~1" == "" set "PYTL_ROOT=%~1"
if not defined PYTL_ROOT @echo Usage: %~nx0 ^<PYTL_ROOT^> [DB_CONNECTION_NAME] [ENV] [TARGET_DIR] [VENV_DIR_RUN] [PYTHON_EXE]^
    && @echo    PYTL_ROOT           == PyTL root directory, for example D:\PyTL\W4DEV30 ^
    && @echo    DB_CONNECTION_NAME  == the name of variable in *.parm file, by default DB_STG_SRC_WLTURL. It's used for DDL SQL scripts execution. ^
    && @echo    ENV                 == the path to *.parm file, by default '%%PYTL_ROOT%%\Env\region.parm' ^
    && @echo    TARGET_DIR          == the path to BAT files directory, by default '%%PYTL_ROOT%%\PyTL_Jobs\NIC\' ^
    && @echo    VENV_DIR_RUN        == the path to Python VENV directory, by default '%%PYTL_ROOT%%\PyTL_Core\.venv\' ^
    && @echo    PYTHON_EXE          == the path to system python.exe, by default 'C:\Python38-x32\python.exe' ^
    && goto :eof
if not "%~2" == "" set "DB_CONNECTION_NAME=%~2"
if not defined DB_CONNECTION_NAME set "DB_CONNECTION_NAME=DB_STG_SRC_WLTURL"
if not "%~3" == "" set "ENV=%~3"
if not "%~4" == "" set "TARGET_DIR=%~4"
if not "%~5" == "" set "VENV_DIR_RUN=%~5"
if not "%~6" == "" set "PYTHON_EXE=%~6"
set FATAL_ERROR=
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo ======================================================================
@echo === FIND n0library.bat
@echo ======================================================================
setlocal EnableDelayedExpansion
for %%P in ("%~dp0\" ".\" "%PYTL_HOME%" "%~dp0\..\" ".\..\") do set "n0library_bat=%%~P\n0library.bat"&&if exist "!n0library_bat!" goto :N0LIBRARY_is_found
set "n0library_bat="
:N0LIBRARY_is_found
endlocal && set "n0library_bat=%n0library_bat%"
if not defined n0library_bat call n0library.bat :find_path "n0library.bat" n0library_bat
call "%n0library_bat%" :full_path "%n0library_bat%" n0library_bat
:N0LIBRARY_is_defined
call "%n0library_bat%" :version 1> nul 2> nul
set "n0library_version=%ERRORLEVEL%"
if %n0library_version% lss 122 @echo *** Incorrect version of '%n0library_bat%' required 1.22, found %n0library_version:~0,1%.%n0library_version:~1,2%!&&echo *** Execution terminated!!&&exit -1
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
                                                             call  "%n0library_bat%" :full_path   "%PYTL_ROOT%"                 PYTL_ROOT
                                                             call  "%n0library_bat%" :cut_tail \  "%PYTL_ROOT%"                 PYTL_ROOT
if not exist "%PYTL_ROOT%"                                   mkdir "%PYTL_ROOT%"

                                                             call  "%n0library_bat%" :timestamp                                 install_timestamp
if     defined HISTORY_DIR                                   call  "%n0library_bat%" :full_path   "%HISTORY_DIR%"               HISTORY_DIR
if not defined HISTORY_DIR  if defined bamboo_HISTORY_DIR    call  "%n0library_bat%" :full_path   "%bamboo_HISTORY_DIR%"        HISTORY_DIR
if not defined HISTORY_DIR                                   call  "%n0library_bat%" :full_path   "%PYTL_ROOT%\History"         HISTORY_DIR
                                                             call  "%n0library_bat%" :cut_tail \  "%HISTORY_DIR%"               HISTORY_DIR
if not exist "%HISTORY_DIR%"                                 mkdir "%HISTORY_DIR%"

if     defined ENV                                           call  "%n0library_bat%" :check_path  "%ENV%"                       ENV
if not defined ENV          if defined bamboo_ENV            call  "%n0library_bat%" :check_path  "%bamboo_ENV%"                ENV
if not defined ENV                                           call  "%n0library_bat%" :check_path  "%PYTL_ROOT%\Env\region.parm" ENV
if not defined ENV                                           call  "%n0library_bat%" :find_latest "%PYTL_ROOT%\Env\*.parm"      ENV "'%PYTL_ROOT%\Env\*.parm' are NOT found."

if     defined TARGET_DIR                                    call  "%n0library_bat%" :full_path   "%TARGET_DIR%"                TARGET_DIR
if not defined TARGET_DIR   if defined bamboo_TARGET_DIR     call  "%n0library_bat%" :full_path   "%bamboo_TARGET_DIR%"         TARGET_DIR
if not defined TARGET_DIR                                    call  "%n0library_bat%" :full_path   "%PYTL_ROOT%\PyTL_Jobs\NIC"   TARGET_DIR
                                                             call  "%n0library_bat%" :cut_tail \  "%TARGET_DIR%"                TARGET_DIR
if not exist "%TARGET_DIR%"                                  mkdir "%TARGET_DIR%"
                                                             call  "%n0library_bat%" :str_len     "%TARGET_DIR%"                len_TARGET_DIR
                                                             set /a "len_TARGET_DIR+=1"

if     defined VENV_DIR_RUN                                  call  "%n0library_bat%" :full_path   "%VENV_DIR_RUN%"              VENV_DIR_RUN
if not defined VENV_DIR_RUN if defined bamboo_VENV_DIR_RUN   call  "%n0library_bat%" :full_path   "%bamboo_VENV_DIR_RUN%"       VENV_DIR_RUN
if not defined VENV_DIR_RUN                                  call  "%n0library_bat%" :full_path   "%PYTL_ROOT%\PyTL_Core\.venv" VENV_DIR_RUN
                                                             call  "%n0library_bat%" :cut_tail \  "%VENV_DIR_RUN%"              VENV_DIR_RUN
if not exist "%VENV_DIR_RUN%"                                mkdir "%VENV_DIR_RUN%"
                                                             call  "%n0library_bat%" :full_path   "%VENV_DIR_RUN%\Lib\site-packages" VENV_DIR_SITE
                                                             call  "%n0library_bat%" :str_len     "%VENV_DIR_SITE%"             len_VENV_DIR_SITE
                                                             set /a "len_VENV_DIR_SITE+=1"

if     defined PYTHON_EXE                                    call  "%n0library_bat%" :check_path  "%PYTHON_EXE%"                PYTHON_EXE
if not defined PYTHON_EXE   if defined bamboo_PYTHON_EXE     call  "%n0library_bat%" :check_path  "%bamboo_PYTHON_EXE%"         PYTHON_EXE
if not defined PYTHON_EXE   if defined bamboo_local_python38 call  "%n0library_bat%" :check_path  "%bamboo_local_python38%"     PYTHON_EXE
if not defined PYTHON_EXE                                    call  "%n0library_bat%" :find_path   "C:\Python38-x32\python.exe"  PYTHON_EXE

@echo ======================================================================
@echo === Check '%PYTHON_EXE%' version inside system environment
@echo ======================================================================
for /f "tokens=2" %%v in ('"%PYTHON_EXE%" -V') do set "PYTHON_VERSION=%%v"
if not defined REQUIRED_PYTHON_VERSION  set "REQUIRED_PYTHON_VERSION=%bamboo_REQUIRED_PYTHON_VERSION%"
if not defined REQUIRED_PYTHON_VERSION  set "REQUIRED_PYTHON_VERSION=3.8.5"
if not "%PYTHON_VERSION%" == "%REQUIRED_PYTHON_VERSION%"    call "%n0library_bat%" :save_error    "'%PYTHON_EXE%' is v%PYTHON_VERSION% but required v%REQUIRED_PYTHON_VERSION%"
@echo Required v%REQUIRED_PYTHON_VERSION% == found v%PYTHON_VERSION%
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if defined FATAL_ERROR call "%n0library_bat%" :fatal_error
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo ======================================================================
@echo === Check system environment
@echo ======================================================================
@echo on
where.exe perl.exe
where.exe grep.exe
where.exe findstr.exe
@if ERRORLEVEL 1 call "%n0library_bat%" :fatal_error "Mandatory windows utility 'findstr.exe' is not found"
where.exe sed.exe
where.exe python.exe
set PATH
"%PYTHON_EXE%" -VV
@if ERRORLEVEL 1 call "%n0library_bat%" :fatal_error "Error with execution of '%PYTHON_EXE% -VV'"
"%PYTHON_EXE%" -m pip -VV
@if ERRORLEVEL 1 call "%n0library_bat%" :fatal_error "Error with execution of '%PYTHON_EXE% -m pip -VV'"
"%PYTHON_EXE%" -m pip list > "%HISTORY_DIR%\%install_timestamp%.tmp" 2>&1
@if ERRORLEVEL 1 call "%n0library_bat%" :fatal_error "Error with execution of '%PYTHON_EXE% -m pip list'"
type "%HISTORY_DIR%\%install_timestamp%.tmp"

set PYTL_CORE_VERSION=
for /f "tokens=2" %%a in ('type "%HISTORY_DIR%\%install_timestamp%.tmp" ^| findstr.exe pytl-core') do (
    set PYTL_CORE_VERSION=%%a
)
if defined PYTL_CORE_VERSION call "%n0library_bat%" :fatal_error "pytl_core==%PYTL_CORE_VERSION% is already installed in the system environment."
del "%HISTORY_DIR%\%install_timestamp%.tmp"

@echo off
@echo ======================================================================
@echo === Upgrade system environment
@echo ======================================================================
@echo on
"%PYTHON_EXE%" -m pip install --no-cache-dir --disable-pip-version-check --no-index --upgrade --find-links=./ -r "%~dp0\system.requirements.txt"
@if ERRORLEVEL 1 call "%n0library_bat%" :fatal_error "Error with upgrade of Python system environment"
@echo off

@echo ======================================================================
@echo === Create virtual environment '%VENV_DIR_RUN%' for execution
@echo ======================================================================
if exist "%VENV_DIR_RUN%\Scripts\activate.bat" echo =-= Virtual environment '%VENV_DIR_RUN%' was setuped already&&goto :skip_setup_VENV_DIR_RUN
echo =-= Setup virtual environment '%VENV_DIR_RUN%'
@echo on
"%PYTHON_EXE%" -m venv --system-site-packages --without-pip --clear --prompt "%VENV_DIR_RUN%" "%VENV_DIR_RUN%"
@if ERRORLEVEL 1 call "%n0library_bat%" :fatal_error "Error with creation of Python virtual environment"
@echo off
:skip_setup_VENV_DIR_RUN
@echo ======================================================================
@echo === Enable virtual environment '%VENV_DIR_RUN%' for execution
@echo ======================================================================
@if not exist "%VENV_DIR_RUN%\Scripts\activate.bat" call "%n0library_bat%" :fatal_error "'%VENV_DIR_RUN%\Scripts\activate.bat' is not found"
call "%VENV_DIR_RUN%\Scripts\activate.bat"
@if ERRORLEVEL 1 call "%n0library_bat%" :fatal_error "Error with activation of Python virtual environment '%VENV_DIR_RUN%\Scripts\activate.bat'"
@echo on
where python.exe
python.exe -VV
@if ERRORLEVEL 1 call "%n0library_bat%" :fatal_error "Error with execution of 'python.exe -VV'"
python.exe -m pip -VV
@if ERRORLEVEL 1 call "%n0library_bat%" :fatal_error "Error with execution of 'python.exe -m pip -VV'"
python.exe -m pip list
@if ERRORLEVEL 1 call "%n0library_bat%" :fatal_error "Error with execution of 'python.exe -m pip list'"
python.exe -m pip freeze > "%HISTORY_DIR%\%install_timestamp%.1before_install"
@if ERRORLEVEL 1 call "%n0library_bat%" :fatal_error "Error with execution of 'python.exe -m pip freeze'"
@echo ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-==
type "%HISTORY_DIR%\%install_timestamp%.1before_install"
@echo =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
@echo off

@echo ======================================================================
@echo === Show already installed files
@echo ======================================================================
@echo === %TARGET_DIR%
call :SMART_DIR %len_TARGET_DIR%     "%TARGET_DIR%\*.py"     "%TARGET_DIR%\*.bat"    "%TARGET_DIR%\*.sql"    "%TARGET_DIR%\run_sql.txt"     "%TARGET_DIR%\record"
@echo === %VENV_DIR_SITE%
call :SMART_DIR %len_VENV_DIR_SITE%  "%VENV_DIR_SITE%\*.py"  "%VENV_DIR_SITE%\*.bat" "%VENV_DIR_SITE%\*.sql" "%VENV_DIR_SITE%\run_sql.txt"  "%VENV_DIR_SITE%\record"
@echo ======================================================================

@echo ======================================================================
@echo === Check python.exe version inside virtual environment
@echo ======================================================================
for /f "tokens=2" %%v in ('python.exe -V') do set "PYTHON_VERSION=%%v"
if not "%PYTHON_VERSION%" == "%REQUIRED_PYTHON_VERSION%"    call "%n0library_bat%" :fatal_error "'%PYTHON_EXE%' is v%PYTHON_VERSION% but required v%REQUIRED_PYTHON_VERSION%"
@echo Required v%REQUIRED_PYTHON_VERSION% == found v%PYTHON_VERSION%

@echo ======================================================================
@echo === Install all modules in the loop:
@echo on
type "%~dp0\install.txt"
@echo off
@echo ======================================================================
setlocal EnableDelayedExpansion
for /f %%a in (%~dp0\install.txt) do (
    set "PYTL_MODULE_FULL=%%a"
    for /f "tokens=1,2,3,4* delims=<>=" %%b in ("!PYTL_MODULE_FULL!") do (
        set "PYTL_MODULE_SHORT=%%b"
        set "PYTL_MODULE_VERSION=%%c"
    )
    call :INSTALL_SINGLE_MODULE "!PYTL_MODULE_FULL!" "!PYTL_MODULE_SHORT!" "!PYTL_MODULE_VERSION!"
    echo RESULT_CODE=0='!RESULT_CODE!'
)
endlocal

@echo ======================================================================
@echo === Show installed modules
@echo ======================================================================
@echo on
copy "%~dp0\install.txt" "%HISTORY_DIR%\%install_timestamp%.2installed"
python.exe -m pip -VV
@if ERRORLEVEL 1 call "%n0library_bat%" :fatal_error "Error with execution of 'python.exe -VV'"
python.exe -m pip list
@if ERRORLEVEL 1 call "%n0library_bat%" :fatal_error "Error with execution of 'python.exe -m pip list'"
python.exe -m pip freeze > "%HISTORY_DIR%\%install_timestamp%.3after_install"
@if ERRORLEVEL 1 call "%n0library_bat%" :fatal_error "Error with execution of 'python.exe -m pip freeze'"
@echo ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-==
type "%HISTORY_DIR%\%install_timestamp%.3after_install"
@echo =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
@echo off

@echo ======================================================================
@echo === Show installed files
@echo ======================================================================
@echo === %TARGET_DIR%
call :SMART_DIR %len_TARGET_DIR%     "%TARGET_DIR%\*.py"     "%TARGET_DIR%\*.bat"    "%TARGET_DIR%\*.sql"    "%TARGET_DIR%\run_sql.txt"     "%TARGET_DIR%\record"
@echo === %VENV_DIR_SITE%
call :SMART_DIR %len_VENV_DIR_SITE%  "%VENV_DIR_SITE%\*.py"  "%VENV_DIR_SITE%\*.bat" "%VENV_DIR_SITE%\*.sql" "%VENV_DIR_SITE%\run_sql.txt"  "%VENV_DIR_SITE%\record"
@echo ======================================================================

@echo off
call "%VENV_DIR_RUN%\Scripts\deactivate.bat"
@if ERRORLEVEL 1 call "%n0library_bat%" :fatal_error "Error with deactivation of Python virtual environment '%VENV_DIR_RUN%\Scripts\deactivate.bat'"


goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:INSTALL_SINGLE_MODULE
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
endlocal
set "PYTL_MODULE_FULL=%~1"
set "PYTL_MODULE_SHORT=%~2"
set "PYTL_MODULE_VERSION=%~3"
set RESULT_CODE=
@echo ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-==
@echo =-= Check if '%PYTL_MODULE_SHORT%' v%PYTL_MODULE_VERSION% is already installed
@echo =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
set PYTL_MODULE_FOUND=
for /f "tokens=2" %%a in ('python.exe -m pip show %PYTL_MODULE_SHORT% ^| findstr.exe Version:') do (
    set PYTL_MODULE_FOUND=%%a
)
if not defined PYTL_MODULE_FOUND @echo =-= '%PYTL_MODULE_SHORT%' was not installed, so skip uninstall&&goto :skip_uninstall
if defined FORCE_REINSTALL echo FORCE_REINSTALL is defined&&goto :force_uninstall
if defined bamboo_FORCE_REINSTALL echo bamboo_FORCE_REINSTALL is defined&&goto :force_uninstall
if "%PYTL_MODULE_FOUND%" == "%PYTL_MODULE_VERSION%" @echo =-= Exactly the same version of '%PYTL_MODULE_FULL%' was installed, so skip uninstall+install&&goto :check_installed_module
:force_uninstall
@echo =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
@echo =-= Check if %PYTL_MODULE_SHORT%.uninstall exists
@echo =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
@echo on
python.exe -c "exec('try:\n import %PYTL_MODULE_SHORT%.uninstall\nexcept:\n print(""Sub module %PYTL_MODULE_SHORT%.uninstall does NOT exist."")\n exit(-1)\nelse:\n print(""%PYTL_MODULE_SHORT%.uninstall EXISTS."")\n exit(0)')"
@set "RESULT_CODE=%ERRORLEVEL%"
@echo off
echo RESULT_CODE=0) if submodule %PYTL_MODULE_SHORT%.uninstall exists='%RESULT_CODE%'
if not "%RESULT_CODE%" == "0" goto :unistall_pytl_module
@echo =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
@echo =-= Unsetup '%PYTL_MODULE_SHORT%' v%PYTL_MODULE_FOUND%
@echo =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
@echo on
python.exe -m "%PYTL_MODULE_SHORT%.uninstall" "TARGET_DIR=%TARGET_DIR%" "ENV=%ENV%" "DB_CONNECTION_NAME=%DB_CONNECTION_NAME%"
@set "RESULT_CODE=%ERRORLEVEL%"
@echo off
echo RESULT_CODE=1) after execution of %PYTL_MODULE_SHORT%.uninstall='%RESULT_CODE%'
if not "%RESULT_CODE%" == "0" echo *** Issue with unsetup of %PYTL_MODULE_SHORT%.uninstall&&goto :terminate_execution
:unistall_pytl_module
@echo =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
@echo =-= Uninstall '%PYTL_MODULE_SHORT%' v%PYTL_MODULE_FOUND%
@echo =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
@echo on
python.exe -m pip uninstall %PYTL_MODULE_SHORT% --yes --disable-pip-version-check
@set "RESULT_CODE=%ERRORLEVEL%"
@echo off
echo RESULT_CODE=2) after unistalling module %PYTL_MODULE_SHORT%='%RESULT_CODE%'
@REM REM if not "%RESULT_CODE%" == "0" @echo *** Impossible to uninstall '%PYTL_MODULE_FULL%'!&&call "%VENV_DIR_RUN%\Scripts\deactivate.bat"&&echo *** Execution terminated!!&&exit -1
@REM REM FATAL BAT ISSUE: after call "%VENV_DIR_RUN%\Scripts\deactivate.bat" doesn't go to the next commands &&echo *** Execution terminated!!&&exit -1
if "%RESULT_CODE%" == "0" goto :skip_uninstall
@echo *** Impossible to uninstall '%PYTL_MODULE_FULL%'!
:terminate_execution
call "%VENV_DIR_RUN%\Scripts\deactivate.bat"
@echo *** Execution terminated!!
exit -1
:skip_uninstall
@echo =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
@echo =-= Install '%PYTL_MODULE_FULL%'
@echo =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
pushd "%~dp0"
@echo on
python.exe -m pip install --no-cache-dir --disable-pip-version-check --no-index --upgrade --find-links=./ "%PYTL_MODULE_FULL%"
@set "RESULT_CODE=%ERRORLEVEL%"
@echo off
echo RESULT_CODE=3) after installing of %PYTL_MODULE_FULL%='%RESULT_CODE%'
popd
@REM REM if not "%RESULT_CODE%" == "0" @echo *** Impossible to install '%PYTL_MODULE_FULL%'!&&call "%VENV_DIR_RUN%\Scripts\deactivate.bat"&&echo *** Execution terminated!!&&exit -1
@REM REM FATAL ISSUE: after call "%VENV_DIR_RUN%\Scripts\deactivate.bat" doesn't go to the next commands &&echo *** Execution terminated!!&&exit -1
if not "%RESULT_CODE%" == "0" echo *** Issue with install of %PYTL_MODULE_FULL%&&goto :terminate_execution
:check_installed_module
@echo =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
@echo =-= Check if %PYTL_MODULE_SHORT%.install exists
@echo =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
@echo on
python.exe -c "exec('try:\n import %PYTL_MODULE_SHORT%.install\nexcept:\n print(""Sub module %PYTL_MODULE_SHORT%.install does NOT exist."")\n exit(-1)\nelse:\n print(""%PYTL_MODULE_SHORT%.install EXISTS."")\n exit(0)')"
@set "RESULT_CODE=%ERRORLEVEL%"
@echo off
echo RESULT_CODE=4) if submodule %PYTL_MODULE_SHORT%.install exists='%RESULT_CODE%'
if not "%RESULT_CODE%" == "0" goto :setup_is_completed
@echo =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
@echo =-= Setup of '%PYTL_MODULE_FULL%'
@echo =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
@echo on
python.exe -m "%PYTL_MODULE_SHORT%.install" "TARGET_DIR=%TARGET_DIR%" "ENV=%ENV%" "DB_CONNECTION_NAME=%DB_CONNECTION_NAME%"
@set "RESULT_CODE=%ERRORLEVEL%"
@echo off
echo RESULT_CODE=5) after execution of %PYTL_MODULE_SHORT%.install='%RESULT_CODE%'
if not "%RESULT_CODE%" == "0" echo *** Issue with setup of %PYTL_MODULE_SHORT%.install&&goto :terminate_execution
:setup_is_completed
@echo =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
@echo =-= Installation of '%PYTL_MODULE_FULL%' is completed
@echo ===-=-=-===-=-=-===-=-=-===-=-=-===-=-=-===-=-=-===-=-=-=-===-=-=-=-==

setlocal EnableDelayedExpansion
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:SMART_DIR
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "SMART_DIR__dir_name_len=%~1"
set "SMART_DIR__command=cmd.exe /c dir /b /s /a:-d 22%~222 22%~322 22%~422 22%~522 22%~622 22%~722 22%~822 22%~922 ^| sort"
set "SMART_DIR__command=%SMART_DIR__command:2222=%"
set "SMART_DIR__command=%SMART_DIR__command:22="%"
setlocal EnableDelayedExpansion
for /f %%i in ('%SMART_DIR__command%') do (
    set "SMART_DIR__file_size=         %%~zi"
    set "SMART_DIR__file_size=!SMART_DIR__file_size:~-10!"
    set "SMART_DIR__file_path=%%i"
    set "SMART_DIR__file_path=!SMART_DIR__file_path:~%SMART_DIR__dir_name_len%,999!"
    echo %%~ti !SMART_DIR__file_size! !SMART_DIR__file_path!
)
endlocal
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
