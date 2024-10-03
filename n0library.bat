@echo off
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 231015.1
set n0library_bat_version=128
:: usage:
::      call n0library.bat {:function} {param1} {param2} ... {paramN}
:: sample:
::      call n0library.bat :timestamp my_timestamp
::
:: list of functions:
::
::      :version
::          Out: ERRORLEVEL == version of n0library.bat
::          Sample: call n0library.bat :version
::          Result: ERRORLEVEL = 123
::
::      :save_error [%1 as message]
::          Sample: call n0library.bat :save_error "File is not found"
::          Result: Nothing. FATAL_ERROR+=%1
::
::      :fatal_error [%1 as message]
::          Sample: call n0library.bat :fatal_error "File is not found"
::          Result: ERRORLEVEL = -1 print to the screen %FATAL_ERROR% and %1
::
::      :find_latest [%1 as file path and mask] [%2 as destination var name] [%3 as FATAL_ERROR message]
::          Out: !%2! == latest %1 or empty if not found
::          Sample: call n0library.bat :find_latest "C:\TEMP\*.log" latest_log
::          Result: latest_log = C:\TEMP\211231_2359.log
::
::      :find_in_subdirs
::          In:  %1 as file mask, %2 as destination var name, %3 as optional file dir
::          Out: !%2! == latest %1 or empty if not found
::          Sample: call n0library.bat :find_in_subdirs "notepad.exe" notepad_exe
::          Sample: call n0library.bat :find_in_subdirs "notepad.exe" notepad_exe "."
::          Sample: call n0library.bat :find_in_subdirs "notepad.exe" notepad_exe ".\"
::          Sample: call n0library.bat :find_in_subdirs "notepad.exe" notepad_exe "C:\Windows"
::          Sample: call n0library.bat :find_in_subdirs "notepad.exe" notepad_exe "C:\Windows\"
::          Result: notepad_exe = C:\Windows\notepad.exe
::
::          :full_path          :check_path         :try_find_path      :find_path
::          if file is found =>
::          result == absolute path without validation
::                              result == absolute path or in current directory or in PATH or in sub directories
::                                                  result == absolute path or in current directory or in PATH or in sub directories
::                                                                      result == absolute path or in current directory or in PATH or in sub directories
::          if file is NOT found =>
::          result == absolute path without validation
::                              result == None
::                                                  result == None, FATAL_ERROR+=error message
::                                                                      exit, print FATAL_ERROR
::
::      :find_path [%1 as file name == notepad.exe] [%2 as var name == notepad_exe] [%3 as alternative error message]
::      :check_path [%1 as file name == notepad.exe] [%2 as var name == notepad_exe]
::      :set_var_if_path_exists [%1 as var name == notepad_exe] [%2 as file name == notepad.exe] [%3 as alternative error message]
::          Difference of :find_path vs :set_var_if_path_exists is ORDER OF ARGUMENTS
::          In:  %1 as destination var name, %2 as path to exe/bat/py file name
::          Out: !%1! = %2 if %2 is found, else execution termination.
::          Sample: call n0library.bat :set_var_if_path_exists notepad_exe "notepad.exe"
::          Check
::              Step 1: if file path from %2 exists
::              Step 2: looking for file name from %2 in current dir (it will be done by where.exe by default)
::              Step 3: looking for file name from %2 in %PATH%
::              Step 4: looking for file name from %2 in n0libarary.bat directory and sub directories
::          Result:
::           If file "notepad.exe" is found in current dir or PATH:
::               notepad_exe = C:\Windows\notepad.exe
::           If file "notepad.exe" is NOT found in current dir or PATH:
::               execution termination with printing %FATAL_ERROR% and error message
::
::      :try_find_path [%1 as file name == notepad.exe] [%2 as var name == notepad_exe] [%3 as error message to save into %FATAL_ERROR%]
::          In:  %1 as destination var name, %2 as path to exe/bat/py file name
::          Out: !%1! = %2 if %2 is found, else %2 is EMPTY.
::          Sample: call n0library.bat :try_find_path notepad_exe "notepad.exe"
::          Result:
::           If file "notepad.exe" is found in current dir or PATH:
::               notepad_exe = C:\Windows\notepad.exe
::           If file "notepad.exe" is NOT found in current dir or PATH:
::               notepad_exe is CLEARED
::
::      :find_path_update [%1 as file name == notepad.exe] [%2 as var name == notepad_exe]
::      :update_var_if_path_exists [%1 as var name == notepad_exe] [%2 as file name == notepad.exe]
::          Difference of :find_path vs :update_var_if_path_exists is ORDER OF ARGUMENTS
::          In:  %1 as destination var name, %2 as path to exe/bat/py file name
::          Out: !%1! = %2 if %2 is found, else execution termination.
::          Sample: call n0library.bat :update_var_if_path_exists notepad_exe "notepad.exe"
::          Result:
::           If %notepad_exe% is empty and file "notepad.exe" is found in current dir or PATH:
::               notepad_exe = C:\Windows\notepad.exe
::           If %notepad_exe% is not empty and file path %notepad_exe% exists:
::               notepad_exe = <existed value of notepad_exe>
::           If %notepad_exe% is not empty and file path %notepad_exe% NOT exists and file "notepad.exe" is found in current dir or PATH:
::               notepad_exe = C:\Windows\notepad.exe
::           If %notepad_exe% is not empty and file path %notepad_exe% NOT exists and file "notepad.exe" is NOT found in current dir or PATH:
::               execution termination
::
::      :timestamp
::          In:  %1 as destination var name for %timestamp% [optional]
::          Out: !%1! == %timestamp% + list of defined variables
::          Sample: call n0library.bat :timestamp
::          Result: timestamp == 210406_093227_928
::          Sample: call n0library.bat :timestamp my_timestamp
::          Result: my_timestamp == 210406_093227_928
::
::      :str_len
::          In:  %1 as string, optional %2 as destination var name
::          Out: %str_len% == len(%1)
::          Sample: call n0library.bat :str_len "C:\TEMP\archive.tar.gz"
::          Result: str_len == 22
::
::      :cut_tail
::          In:  %1 as expected tail (for example complex extention), %2 string for cutting (for example file name), %3 as destination var name
::          Out: !%3! == %2 without trailing %1 or %2
::          Sample: call n0library.bat :cut_tail .tar.gz "C:\TEMP\archive.tar.gz" archive_var
::          Result: archive_var == C:\TEMP\archive
::
::      :file_name_ext
::          In:  %1 as path, %2 as destination var name
::          Out: !%2! == %1
::          Sample: call n0library.bat :file_name_ext "C:\Windows\notepad.exe" file_name_ext_var
::          Result: file_name_ext_var == notepad.exe
::
::      :file_name_only
::          In:  %1 as path, %2 as destination var name
::          Out: !%2! == %1
::          Sample: call n0library.bat :file_name_only "C:\Windows\notepad.exe" file_name_only_var
::          Result: file_name_only_var == notepad
::
::      :full_path
::          In:  %1 as path, %2 as destination var name
::          Out: !%2! == %1
::          Sample: call n0library.bat :full_path "notepad.exe" full_path_var
::          Result: full_path_var == C:\Windows\notepad.exe
::
::      :path_only
::          In:  %1 as path (with file name), %2 as destination var name
::          Out: !%2! == %1
::          Sample: call n0library.bat :path_only "C:\Windows\notepad.exe" full_path_var
::          Result: full_path_var == C:\Windows
::
::      :posix_path
::          In:  %1 as path, %2 as destination var name
::          Out: !%2! == %1 where all '\' will be converted into '/'
::          Sample: call n0library.bat :posix_path "C:\Windows\notepad.exe" posix_path_var
::          Result: posix_path_var == C:/Windows/notepad.exe
::
::      :str_split  [%1 as incoming string to be splitted; %2 as separator; %3 as splitted part index [0..9]; %4 as destination var name]
::          Out: %4 == %1.split(%2)[%3]
::          Sample: call :str_split ssh://git@10.10.10.10:7999/tib/repo.git ssh:// 1 git_url_part
::          Result: git_url_part == git@10.10.10.10:7999/tib/repo.git
::
::      :str_split2 [%1 as incoming string to be splitted; %2 as separator; %3 as destination var name with splitted part before separator; %4 as destination var name with splitted part after separator;]
::          Out: %3, %4 == %1.split(%2,1)
::          Sample: call :str_split2 "value1;value2;value3" ; first_value other_values
::          Result: first_value == "value1", other_values == "value2;value3"
::
::      :translate [%1 as input str; %2 as from_map; %3 as to_map; %4 as destination var name]
::          COULD BE TRANSLATED ONLY SAFE CHARACTERS: 'a-zA-Z@#$()+-{}[]:;'`\/,.?'
::          FOR TRANSLATING '=*~!' USE :not_safe_replace
::          IMPOSSIBLE TO TRANSLATE: '|&^<>!%'
::          Sample: call n0library.bat :translate "C:\file.txt" ":\." "___" result
::          Result: result='C__file_txt'
::
::      :lower [%1 as incoming string to be converted; %2 as destination var name]
::          In:  %1 as path, %2 as destination var name
::          Out: !%2! == lower(%1)
::          Sample: call n0library.bat :lower "C:\Windows\notepad.exe" lower_filename
::          Result: lower_filename == c:\windows\notepad.exe
::
::      :upper [%1 as incoming string to be converted; %2 as destination var name]
::          In:  %1 as path, %2 as destination var name
::          Out: !%2! == upper(%1)
::          Sample: call n0library.bat :upper "C:\Windows\notepad.exe" upper_filename
::          Result: upper_filename == C:\WINDOWS\NOTEPAD.EXE
::
::      :str_in [%1 as String expression being searched; %2 as String expression sought; %3 as destination var name; %4 as optional value for %3]
::          In:  %1 as String expression being searched; %2 as String expression sought; %3 as destination var name; %4 as optional value for %3
::          Out: !%3! == True || ""
::          Sample: call n0library.bat :str_in "C:\Windows\notepad.exe" "windows" found
::          Result: found == True
::          Sample: call n0library.bat :str_in "C:\Windows\notepad.exe" "windows" found FOUND
::          Result: found == FOUND
::          Sample: call n0library.bat :str_in "C:\Windows\notepad.exe" "windowz" found
::          Result: found == ""
::
::      :equal_replace [%1 as string contains '='; %2 replacement; %3 as destination var name]
::          Sample: call :equal_replace "tag2=value1;tag2=value2;tag3=value3" ~ result
::          Result: result == "tag2~value1;tag2~value2;tag3~value3"
::
::      :not_safe_replace [%1 as string contains '=*~!'; %2 replacement; %3 as destination var name]
::          Sample: call :not_safe_replace "C:\~file=1!.*" _ result
::          Result: result == "C:\_file_1_._"
::
::      :str_split_by_equal [%1 as incoming string to be splitted; %2 as destination var name with splitted part before '='; %3 as destination var name with splitted part after '=']
::          Sample: call :str_split_by_equal "tag1=value1" _tag _value
::          Result: _tag == "tag1", _value == "value1"
::          Set default empty values to result variable
::
::      :get_value_by_tag [%1 as string contains pairs with separator ';'; %2 tag name; %3 as destination var name]
::          In:  %1 as string contains pairs with separator ';'; %2 tag name; %3 as destination var name
::          Out: !%3! == {value} || ""
::          Sample: call n0library.bat :str_in "ENV=1;ORG=2" "ENV" _ENV
::          Result: _ENV == 1
::          Sample: call n0library.bat :str_in "ENV=1;ORG=2" "ORG" _ORG
::          Result: _ORG == 2
::          Sample: call n0library.bat :str_in "ENV=1;ORG=2" "ORGLIST" _ORGLIST
::          Result: _ORGLIST == ""
::
::      :argv21 %*
::          In:  %*
::          Out: argv1=%0 .. argv21=%21, max_argv=21
::          Sample: call n0library.bat :argv21 %*
::          Result: argv1=argument1 argv2=argument1 max_argv=2
::
::      :argv22 prefix_ %*
::          In:  prefix_ %*
::          Out: prefix_argv1=%0 .. prefix_argv21=%21, prefix_max_argv=21
::          Sample: call n0library.bat :argv22 prefix_ %*
::          Result: prefix_argv1=argument1 prefix_argv2=argument1 prefix_max_argv=2
::
::      :str_left [%1 as input str; %2 as character count; %3 as destination var name]
::          Sample: call n0library.bat :str_left "1234567" 3 result
::          Result: result=123
::
::      :str_right [%1 as input str; %2 as character count; %3 as destination var name]
::          Sample: call n0library.bat :str_right "1234567" 3 result
::          Result: result=567
::
::      :str_mid [%1 as input str; %2 as offset, %3 as character count; %4 as destination var name]
::          Sample: call n0library.bat :str_right "1234567" 3 3 result
::          Result: result=456
::
::      :str_ltrim [%1 as input str; %2 as destination var name]
::          Sample: call n0library.bat :str_ltrim "      1234567      " result
::          Result: result='1234567      '
::
::      :str_rtrim [%1 as input str; %2 as destination var name]
::          Sample: call n0library.bat :str_rtrim "      1234567      " result
::          Result: result='      1234567'
::
::      :str_trim [%1 as input str; %2 as destination var name]
::          Sample: call n0library.bat :str_trim "      1234567      " result
::          Result: result='1234567'
::
::      :str_align [%1 as input str; %2 as character count; %3 as destination var name]
::          Sample: call n0library.bat :str_align "1234567" 10 result
::          Result: result='   1234567'
::
::      :remove_duplicated [%1 as input str; %2 as possible duplicated character; %3 as destination var name]
::          Sample: call n0library.bat :remove_duplicated "C__file___txt" "_" result
::          Result: result='C_file_txt'
::
::      :translate_into_safe [%1 as input str; %2 as destination var name]
::          COULD BE TRANSLATED ONLY SAFE CHARACTERS: 'a-zA-Z@#$()+-{}[]:;'`\/,.?'
::          FOR TRANSLATING '=*~!' USE :not_safe_replace
::          IMPOSSIBLE TO TRANSLATE: '|&^<>!%'
::          Sample: call n0library.bat :translate "C:\file.txt" ":\." "___" result
::          Result: result='C__file_txt'
::
::      :if_exists [%1 as files' names' list == C:\UTIL\notepad.exe;C:\Windows\notepad.exe;C:\Windows\System32\notepad.exe] [%2 as var name == notepad_exe] [%3 flag to exit in case of not exists]
::          Sample: call n0library.bat :if_exists "C:\UTIL\notepadpp.exe;C:\Windows\notepad.exe;C:\Windows\System32\notepad.exe" notepad_exe
::          Result:
::              if %3 is empty:
::                  notepad_exe='C:\Windows\notepad.exe' if 'C:\Windows\notepad.exe' exists and '' if all files in the list don't exist
::              if %3 is NOT empty:
::                  notepad_exe='C:\Windows\notepad.exe' if 'C:\Windows\notepad.exe' exists and termination if all files in the list don't exist
::
::      :file_size [%1 as file path] [%2 as var name == notepad_exe]
::          Sample: call n0library.bat :file_size "C:\Windows\notepad.exe" notepad_exe_size
::          Result: notepad_exe_size='254464' if 'C:\Windows\notepad.exe' exists and '' it doesn't exist
::
::      :prev_date [%1 as TIMESTAMP_YYMMDD] [%2 as var name == PDATE_YYMMDD] [%3 as centure == ''] [%4 as separator == '']
::          Sample: call n0library.bat :prev_date 231015
::          Result: PDATE_YYMMDD='231014'
::          Sample: call n0library.bat :prev_date 231015 PDATE_YYMMDD 20
::          Result: PDATE_YYMMDD='20231014'
::          Sample: call n0library.bat :prev_date 231015 PDATE_YYMMDD 20 -
::          Result: PDATE_YYMMDD='2023-10-14'
::          Sample: call n0library.bat :prev_date 231015 PDATE_YYMMDD "" -
::          Result: PDATE_YYMMDD='23-10-14'
::
::      :timestamp_to_YYMMDD [%1 as TIMESTAMP_YYMMDD] [%2 as var name == DATE_YYMMDD] [%3 as centure == ''] [%4 as separator == '']
::          Sample: call n0library.bat :timestamp_to_YYMMDD 231015_012345_678
::          Result: DATE_YYMMDD='231015'
::          Sample: call n0library.bat :timestamp_to_YYMMDD 231015_012345_678 DATE_YYMMDD
::          Result: DATE_YYMMDD='231015'
::          Sample: call n0library.bat :timestamp_to_YYMMDD 231015_012345_678 DATE_YYMMDD 20
::          Result: DATE_YYMMDD='20231015'
::          Sample: call n0library.bat :timestamp_to_YYMMDD 231015_012345_678 DATE_YYMMDD 20 -
::          Result: DATE_YYMMDD='2023-10-15'
::          Sample: call n0library.bat :timestamp_to_YYMMDD 231015_012345_678 DATE_YYMMDD "" -
::          Result: DATE_YYMMDD='23-10-15'
::
::      :timestamp_to_DDMMYY [%1 as TIMESTAMP_YYMMDD] [%2 as var name == DATE_DDMMYY] [%3 as centure == ''] [%4 as separator == '']
::          Sample: call n0library.bat :timestamp_to_DDMMYY 231015
::          Result: DATE_DDMMYY='151023'
::          Sample: call n0library.bat :timestamp_to_DDMMYY 231015 DATE_DDMMYY
::          Result: DATE_DDMMYY='151023'
::          Sample: call n0library.bat :timestamp_to_DDMMYY 231015 DATE_DDMMYY 20
::          Result: DATE_DDMMYY='15102023'
::          Sample: call n0library.bat :timestamp_to_DDMMYY 231015 DATE_DDMMYY 20 -
::          Result: DATE_DDMMYY='15-10-2023'
::          Sample: call n0library.bat :timestamp_to_DDMMYY 231015 DATE_DDMMYY "" -
::          Result: DATE_DDMMYY='15-10-23'
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if "%~1"=="" goto :usage
set "n0function=%~1"
if "%n0function:~0,1%"==":" goto :call_func
:usage
echo %~nx0 could be used only as library for other .bat files
pause
exit /b 0
:call_func
REM echo --=== %~nx0 ==--
if "%n0HOME%"=="" set "n0HOME=%~dp0"
call %*
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:save_error [%1 as message]
:: Sample: call n0library.bat :save_error "File is not found"
:: Result: Nothing. FATAL_ERROR+=%1
if "%~1"=="" call :fatal_error "Incorrect call :save_error. 1 incoming arguments are mandatory"
if defined FATAL_ERROR set "FATAL_ERROR=%FATAL_ERROR%[EOL]"
set "FATAL_ERROR=%FATAL_ERROR%%~1"
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:fatal_error [%1 as message]
:: Sample: call n0library.bat :fatal_error "File is not found"
:: Result: ERRORLEVEL = -1 print to the screen %FATAL_ERROR% and %1
echo *** FATAL ERROR:
if not "%~1" == "" call :save_error "%~1"
if defined FATAL_ERROR (
    REM call :cut_tail  "%FATAL_ERROR%" FATAL_ERROR
    setlocal EnableDelayedExpansion
    set NEWLINE=^


    :: Two (not one) empty lines are required: str_split__new_line == '"\n"'. Works ONLY with EnableDelayedExpansion
    set FATAL_ERROR=%FATAL_ERROR:[EOL]=!NEWLINE!    %
    echo     !FATAL_ERROR!
    endlocal
)
set FATAL_ERROR=
timeout 30
exit -1
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:version
:: Out: ERRORLEVEL == version of n0library.bat
:: Sample: call n0library.bat :version
:: Result: ERRORLEVEL = 123
echo %~dpnx0 == %n0library_bat_version:~0,1%.%n0library_bat_version:~1,2%
exit /b %n0library_bat_version%
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:find_latest [%1 as file path and mask] [%2 as destination var name] [%3 as FATAL_ERROR message]
:: Out: !%2! == latest %1 or empty if not found
:: Sample: call n0library.bat :find_latest "C:\TEMP\*.log" latest_log
:: Result: latest_log = C:\TEMP\211231_2359.log
if "%~2"=="" call :fatal_error "Incorrect call :find_latest. 2 incoming arguments are mandatory"
set "%~2="
set "find_latest__error_message=%~3"
if exist "%~1" (
    setlocal EnableDelayedExpansion
    for /f %%i in ('dir /b /o:-d "%~1"') do (set "find_latest__found_file=%~dp1%%i"&&goto :find_latest__take_only_first_found_file)
    :find_latest__take_only_first_found_file
    endlocal && set "%~2=%find_latest__found_file%" && set "find_latest__found_file=%find_latest__found_file%"
)
if not defined find_latest__found_file if defined find_latest__error_message call :save_error "%find_latest__error_message%"
set find_latest__found_file=
set find_latest__error_message=
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:find_in_subdirs
:: In:  %1 as file mask, %2 as destination var name, %3 as optional file dir
:: Out: !%2! == latest %1 or empty if not found
:: Sample: call n0library.bat :find_in_subdirs "notepad.exe" notepad_exe
:: Sample: call n0library.bat :find_in_subdirs "notepad.exe" notepad_exe "."
:: Sample: call n0library.bat :find_in_subdirs "notepad.exe" notepad_exe ".\"
:: Sample: call n0library.bat :find_in_subdirs "notepad.exe" notepad_exe "C:\Windows"
:: Sample: call n0library.bat :find_in_subdirs "notepad.exe" notepad_exe "C:\Windows\"
:: Result: notepad_exe = C:\Windows\notepad.exe
if "%~2"=="" call :fatal_error "Incorrect call :find_latest. 2 incoming arguments are mandatory + 1 is optional"
set "start_dir=%~3"
if "%start_dir%"=="" set "start_dir=.\"
if not "%start_dir:~-1%"=="\" set "start_dir=%start_dir%\"
:: clear destination var => if file mask will not found, return empty
set "%~2="
setlocal EnableDelayedExpansion
for %%a in (just_one_loop_to_suppress_File_Not_Found_message_in_dir) do (
    for /f %%i in ('dir /s /b "%start_dir%%~nx1"') do set "find_in_subdirs__found_file=%%i"&&goto :find_in_subdirs__take_only_first_found_file
) 2> nul
:find_in_subdirs__take_only_first_found_file
endlocal && set "%~2=%find_in_subdirs__found_file%"
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:find_path [%1 as file name == notepad.exe] [%2 as var name == notepad_exe] [%3 as alternative error message]
call :set_var_if_path_exists %2 %1 %3
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:check_path [%1 as file name == notepad.exe] [%2 as var name == notepad_exe]
set set_var_if_path_exists__DONOT_SAVE_FATAL_ERROR=True
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:try_find_path [%1 as file name == notepad.exe] [%2 as var name == notepad_exe] [%3 as alternative error message]
set set_var_if_path_exists__DONOT_RAISE_FATAL_ERROR=True
call :set_var_if_path_exists %2 %1 %3
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:find_path_update [%1 as file name == notepad.exe] [%2 as var name == notepad_exe]
call :update_var_if_path_exists %2 %1
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Check
::  Step 1: if file path from %2 exists
::  Step 2: looking for file name from %2 in current dir (it will be done by where.exe by default)
::  Step 3: looking for file name from %2 in %PATH%
::  Step 4: looking for file name from %2 in n0libarary.bat directory and sub directories
:set_var_if_path_exists [%1 as var name == notepad_exe] [%2 as file name == notepad.exe]
:: In:  %1 as destination var name, %2 as path to exe/bat/py file name
:: Out: !%1! = %2 if %2 is found, else execution termination.
:: Sample: call n0library.bat :set_var_if_path_exists notepad_exe "notepad.exe"
:: Result:
::  If file "notepad.exe" is found in current dir or PATH:
::      notepad_exe = C:\Windows\notepad.exe
::  If file "notepad.exe" is NOT found in current dir or PATH:
::      execution termination
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if "%~2"=="" call :fatal_error "Incorrect call :set_var_if_path_exists. 2 incoming arguments are mandatory"
set "%~1="
set "set_var_if_path_exists__FOUND_FILE=%~dpnx2"
if exist "%set_var_if_path_exists__FOUND_FILE%" goto :set_var_if_path_exists__define_var
if not "%WHERE_EXE%"=="" goto :WHERE_EXE_defined
set "WHERE_EXE=where.exe"
"%WHERE_EXE%" > nul 2> nul
if ERRORLEVEL 9000 goto :WHERE_EXE_not_found_in_path
goto :WHERE_EXE_defined
:WHERE_EXE_not_found_in_path
call :find_in_subdirs "%WHERE_EXE%" WHERE_EXE "%n0HOME%"
if "%WHERE_EXE%"=="" call :fatal_error "Impossible to find 'where.exe' anywhere"
:WHERE_EXE_defined
for /f "delims=" %%A in ('"%WHERE_EXE%" %~nx2 2^>nul') do (set "set_var_if_path_exists__FOUND_FILE=%%A" && goto :set_var_if_path_exists__define_var)
::stdout = ""
::stderr = "INFO: Could not find files for the given pattern(s)."
:set_var_if_path_exists__notfound_in_PATH
call :find_in_subdirs "%~nx2" set_var_if_path_exists__FOUND_FILE "%n0HOME%"
REM @echo on
REM echo -----------------------------
set "set_var_if_path_exists__FATAL_ERROR=%~3"
REM echo set_var_if_path_exists__FATAL_ERROR=0='%set_var_if_path_exists__FATAL_ERROR%'
if not defined set_var_if_path_exists__FATAL_ERROR set "set_var_if_path_exists__FATAL_ERROR=File path to '%~2' which should be stored in the variable '%~1' was not found."
REM echo set_var_if_path_exists__FATAL_ERROR=00='%set_var_if_path_exists__FATAL_ERROR%'
REM echo FATAL_ERROR=0='%FATAL_ERROR%'
setlocal EnableDelayedExpansion
if "%set_var_if_path_exists__FOUND_FILE%"=="" (
    REM echo set_var_if_path_exists__FATAL_ERROR=1='%set_var_if_path_exists__FATAL_ERROR%'
    REM echo set_var_if_path_exists__FATAL_ERROR=2='!set_var_if_path_exists__FATAL_ERROR!'

    REM echo FATAL_ERROR=1='%FATAL_ERROR%'
    REM echo FATAL_ERROR=2='!FATAL_ERROR!'
    REM if defined FATAL_ERROR set "FATAL_ERROR=%FATAL_ERROR%[EOL]"
    REM echo FATAL_ERROR=3='%FATAL_ERROR%'
    REM echo FATAL_ERROR=4='!FATAL_ERROR!'

    REM REM setx FATAL_ERROR "%FATAL_ERROR%%set_var_if_path_exists__FATAL_ERROR%"
    REM set "FATAL_ERROR=%FATAL_ERROR%!set_var_if_path_exists__FATAL_ERROR!"

    if not defined set_var_if_path_exists__DONOT_SAVE_FATAL_ERROR  call :save_error "!set_var_if_path_exists__FATAL_ERROR!"

    REM echo FATAL_ERROR=5='%FATAL_ERROR%'
    REM echo FATAL_ERROR=6='!FATAL_ERROR!'
    if not defined set_var_if_path_exists__DONOT_RAISE_FATAL_ERROR call :fatal_error
)
REM echo FATAL_ERROR=7='%FATAL_ERROR%'
endlocal && set "FATAL_ERROR=%FATAL_ERROR%"
REM echo FATAL_ERROR=9='%FATAL_ERROR%'

:set_var_if_path_exists__define_var
if defined set_var_if_path_exists__FOUND_FILE call :full_path "%set_var_if_path_exists__FOUND_FILE%" "%~1"

set set_var_if_path_exists__DONOT_SAVE_FATAL_ERROR=
set set_var_if_path_exists__DONOT_RAISE_FATAL_ERROR=
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:update_var_if_path_exists
:: In:  %1 as destination var name, %2 as path to exe/bat/py file name
:: Out: !%1! = %2 if %2 is found, else execution termination.
:: Sample: call n0library.bat :update_var_if_path_exists notepad_exe "notepad.exe"
:: Result:
::  If %notepad_exe% is empty and file "notepad.exe" is found in current dir or PATH:
::      notepad_exe = C:\Windows\notepad.exe
::  If %notepad_exe% is not empty and file path %notepad_exe% exists:
::      notepad_exe = <existed value of notepad_exe>
::  If %notepad_exe% is not empty and file path %notepad_exe% NOT exists and file "notepad.exe" is found in current dir or PATH:
::      notepad_exe = C:\Windows\notepad.exe
::  If %notepad_exe% is not empty and file path %notepad_exe% NOT exists and file "notepad.exe" is NOT found in current dir or PATH:
::      execution termination
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if "%~2"=="" call :fatal_error "Incorrect call :update_var_if_path_exists. 2 incoming arguments are mandatory"
setlocal EnableDelayedExpansion
set "update_var_if_path_exists__defined_value=!%~1%!"
endlocal && set "update_var_if_path_exists__defined_value=%update_var_if_path_exists__defined_value%"
if "%update_var_if_path_exists__defined_value%"=="" goto :set_var_if_path_exists
if not exist "%update_var_if_path_exists__defined_value%" goto :set_var_if_path_exists
:: %1 consist of file name, which exists
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Generate timestamps
:timestamp
:: In:  %1 as destination var name for %timestamp% [optional]
:: Out: !%1! == %timestamp% + list of defined variables
:: Sample: call n0library.bat :timestamp
:: Result: timestamp == 210406_093227_928
:: Sample: call n0library.bat :timestamp my_timestamp
:: Result: my_timestamp == 210406_093227_928
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if "%wmic_exe%"=="" call :set_var_if_path_exists wmic_exe "wmic.exe"
REM ****************************************************************************
REM This is a bug in Windows 7 and Windows Server 2008 (also R2) WMIC.
REM https://stackoverflow.com/questions/14651183/invalid-xsl-format-or-file-name
REM NOT POSSIBLE TO RUN SIMPLE: wmic.exe os get localdatetime
REM ****************************************************************************
if "%timestamp_region%"=="" for /f %%i in ('dir /b /a:d "%WINDIR%\System32\wbem\??-??"') do (set timestamp_region=%%i&&goto :timestamp_get_localdatetime)
:timestamp_get_localdatetime
REM reset ERRORLEVEL to zero
ver > nul
REM ****************************************************************************
REM FIXME: Just only single time double quotes are allowed inside 'for .. in (..)'
REM Double quotes after /format: are mandatory
REM so if wmic.exe will be inside path with spaces, below custruction will be failed
REM ****************************************************************************
for /f "skip=2" %%i in ('%wmic_exe% os get localdatetime /format:"%WINDIR%\System32\wbem\%timestamp_region%\csv"') do (
    for /f "delims=, tokens=2" %%j in ("%%i") do (
        set timestamp_localdatetime=%%j
        goto :timestamp__break
    )
)
:timestamp__break
if not "%ERRORLEVEL%"=="0" call :fatal_error "Getting localdatetime with wmic.exe was failed with ERRORLEVEL=%ERRORLEVEL%"
if "%timestamp_localdatetime%"=="" call :fatal_error "Impossible to get localdatetime with wmic.exe"
REM set yyyy=%timestamp_localdatetime:~0,4%
REM set yy=%timestamp_localdatetime:~2,2%
REM set mm=%timestamp_localdatetime:~4,2%
REM set dd=%timestamp_localdatetime:~6,2%
set timestamp__date=%timestamp_localdatetime:~2,6%
REM set hour=%timestamp_localdatetime:~8,2%
REM set minute=%timestamp_localdatetime:~10,2%
REM set second=%timestamp_localdatetime:~12,2%
set timestamp__hour=%timestamp_localdatetime:~8,6%
set timestamp__milisec=%timestamp_localdatetime:~15,3%
REM In real last 3 number of microsec are always 000
REM set microsec=%timestamp_localdatetime:~15,6%
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
REM set unique_sepa=%dd%_%hour%%minute%_%second%
REM set unique=%dd%%hour%%minute%%second%%milisec%
REM set unique_filename=%unique%
rem set timestamp=%yy%%mm%%dd%_%hour%%minute%
REM set timestamp=%yy%%mm%%dd%_%hour%%minute%%second%_%milisec%
set timestamp=%timestamp__date%_%timestamp__hour%_%timestamp__milisec%
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
REM if not "%~1"=="" (
    REM set "%~1=%timestamp%"&&echo %~1=%timestamp%
REM ) else (
    REM echo timestamp=%timestamp%
REM )
if not "%~1"=="" set "%~1=%timestamp%"
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:str_len
:: In:  %1 as string, optional %2 as destination var name
:: Out: %str_len% == len(%1)
:: Sample: call n0library.bat :str_len "C:\TEMP\archive.tar.gz"
:: Result: str_len == 22
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if "%~1"=="" call :fatal_error "Incorrect call :str_len. 1 incoming argument is mandatory"
setLocal EnableExtensions EnableDelayedExpansion
set "str_len__result=%~2"
if not "%str_len__result%" == "" goto :user_define_dst_var
set "str_len__result=%~0"
rem cut leading ':'
set "str_len__result=%str_len__result:~1%"
:user_define_dst_var
set "str_len__string=%~1"
set "str_len__count=0"
if "%str_len__string%"=="" goto :empty_str
set "str_len__count=1"
:next_char
for %%a in ("!str_len__string:~0,-%str_len__count%!") do (
    if "%%~a"=="" goto :empty_str
    set /a "str_len__count+=1"
    goto :next_char
)
:empty_str
endlocal & set "%str_len__result%=%str_len__count%"
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Cut %1 (tail) from %2 if %2 ends with %1 (expected tail), else leave as is, and return in %3
:cut_tail
:: In:  %1 as expected tail (for example complex extention), %2 string for cutting (for example file name), %3 as destination var name
:: Out: !%3! == %2 without trailing %1 or %2
:: Sample: call n0library.bat :cut_tail .tar.gz "C:\TEMP\archive.tar.gz" archive_var
:: Result: archive_var == C:\TEMP\archive
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if "%~3"=="" call :fatal_error "Incorrect call :cut_tail. 3 incoming arguments are mandatory"
set "tail=%~1"
set "org_str=%~2"
set "dst_var=%~3"
call :str_len "%tail%"
REM set tail
REM set org_str
REM set dst_var
REM set str_len
REM pause
setLocal EnableExtensions EnableDelayedExpansion
set "found_tail=!org_str:~-%str_len%!"
set "cutted=!org_str:~0,-%str_len%!"
endlocal & set "cutted=%cutted%" & set "found_tail=%found_tail%" & set "%dst_var%=%cutted%"
REM set found_tail
REM set cutted
REM pause
:: Return %2 (the original string for cutting) inside %3 (destination var name) if %2 not ends with %1 (expected tail)
if /i not "%found_tail%"=="%tail%" set "%dst_var%=%org_str%"
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Return only file name and extention of %1 and save into %2
:file_name_ext
:: In:  %1 as path, %2 as destination var name
:: Out: !%2! == %1
:: Sample: call n0library.bat :file_name_ext "C:\Windows\notepad.exe" file_name_ext_var
:: Result: file_name_ext_var == notepad.exe
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if "%~2"=="" call :fatal_error "Incorrect call :file_name_ext. 2 incoming arguments are mandatory"
set "%~2=%~nx1"
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Return only file name of %1 and save into %2
:file_name_only
:: In:  %1 as path, %2 as destination var name
:: Out: !%2! == %1
:: Sample: call n0library.bat :file_name_only "C:\Windows\notepad.exe" file_name_only_var
:: Result: file_name_only_var == notepad
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if "%~2"=="" call :fatal_error "Incorrect call :file_name_only. 2 incoming arguments are mandatory"
set "%~2=%~n1"
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Convert into full and normolize path %1 and save into %2
:full_path
:: In:  %1 as path, %2 as destination var name
:: Out: !%2! == %1
:: Sample: call n0library.bat :full_path "notepad.exe" full_path_var
:: Result: full_path_var == C:\Windows\notepad.exe
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if "%~2"=="" call :fatal_error "Incorrect call :full_path. 2 incoming arguments are mandatory"
set "%~2=%~dpnx1"
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Convert into full and normolize path %1, remove the file name (with extension) and save into %2
:path_only
:: In:  %1 as path (with file name), %2 as destination var name
:: Out: !%2! == %1
:: Sample: call n0library.bat :path_only "C:\Windows\notepad.exe" full_path_var
:: Result: full_path_var == C:\Windows
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if "%~2"=="" call :fatal_error "Incorrect call :path_only. 2 incoming arguments are mandatory"
set "%~2=%~dp1"
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Convert all '\' inside %1 into '/' and save into %2
:posix_path [%1 as incoming string to be converted; %2 as destination var name]
:: In:  %1 as path, %2 as destination var name
:: Out: !%2! == %1 where all '\' will be converted into '/'
:: Sample: call n0library.bat :posix_path "C:\Windows\notepad.exe" posix_path_var
:: Result: posix_path_var == C:/Windows/notepad.exe
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if "%~2"=="" call :fatal_error "Incorrect call :posix_path. 2 incoming arguments are mandatory"
set "windows_path=%~1"
set "%~2=%windows_path:\=/%"
set windows_path=
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:str_split [%1 as incoming string to be splitted; %2 as separator; %3 as splitted part index [0..9]; %4 as destination var name]
:: Out: %4 == %1.split(%2)[%3]
:: Sample: call :str_split ssh://git@10.10.10.10:7999/tib/repo.git ssh:// 1 git_url_part
:: Result: git_url_part == git@10.10.10.10:7999/tib/repo.git
if "%~4"=="" call :fatal_error "Incorrect call :str_split. 4 incoming arguments are mandatory"
setlocal EnableDelayedExpansion
set "str_split__string=%~1"
set "str_split__separator=%~2"
set "str_split__skip="
if %~3 gtr 0 set "str_split__skip=skip=%~3"
set str_split__new_line=^


:: Two (not one) empty lines are required: str_split__new_line == '"\n"'. Works ONLY with EnableDelayedExpansion

:: 'for' is required to remove "" from '"\n"' and to have possibility to use !string!
for %%n in ("!str_split__new_line!") do (
    set "str_split__splitted_parts=!str_split__string:%str_split__separator%=%%~n!"
)
:: incoming string contains only %separator%s
if "!str_split__splitted_parts!" == "" (
    endlocal && set "%~4="
    goto :eof
)
:: incoming string does't contain %separator%
if "!str_split__splitted_parts!" == "!str_split__string!" (
    endlocal && set "%~4=%str_split__string%"
    goto :eof
)
for /f  "eol= %str_split__skip% delims=" %%p in ("!str_split__splitted_parts!") do (
    endlocal && set "%~4=%%p"
    goto :eof
)
REM echo :str_split:: Index is out of the bound >&2
endlocal  && set "%~4="
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:str_split2 [%1 as incoming string to be splitted; %2 as separator; %3 as destination var name with splitted part before separator; %4 as destination var name with splitted part after separator;]
:: Out: %3, %4 == %1.split(%2,1)
:: Sample: call :str_split2 "value1;value2;value3" ; first_value other_values
:: Result: first_value == "value1", other_values == "value2;value3"
if "%~4"=="" call :fatal_error "Incorrect call :str_split2. 4 incoming arguments are mandatory"
:: Set default empty values to result variables
set "%~3="
set "%~4="
:: Incoming string and separator must not contain 
set "str_split2__in_str=%~1"
if "%str_split2__in_str%" == "" goto :eof
if not "%~1" == "%str_split2__in_str:=%" call :fatal_error "Incorrect call :str_split2. Incoming string must not contain characters ''!"
set "separator=%~2"
if not "%~2" == "%separator:=%"   call :fatal_error "Incorrect call :str_split2. Separator could not contain character ''!"

:: Change possible several characters separator into single character ''
setlocal EnableDelayedExpansion
set "str_split2__in_str=!str_split2__in_str:%separator%=!"
endlocal && set "str_split2__in_str=%str_split2__in_str%"
:: Incoming string contains just only single separator, so both left and right sides are empty
if "%str_split2__in_str%" == "" goto :eof
:: Incoming string starts with separator, so left side is empty and right sides are all other characters
if "%str_split2__in_str:~0,1%" == "" set "str_split2__in_str=%str_split2__in_str:~1%"&&goto :str_split2__revert_back_separator
for /F "tokens=1* delims=" %%a in ("%str_split2__in_str%") do (
    set "%3=%%a"
    set "str_split2__in_str=%%b"
)
:str_split2__revert_back_separator
if "%str_split2__in_str%" == "" goto :eof

:: Revert separator back to original one
setlocal EnableDelayedExpansion
set "str_split2__in_str=!str_split2__in_str:=%separator%!"
endlocal && set "%~4=%str_split2__in_str%"

set str_split2__in_str=
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:translate [%1 as input str; %2 as from_map; %3 as to_map; %4 as destination var name]
::          COULD BE TRANSLATED ONLY SAFE CHARACTERS: 'a-zA-Z@#$()+-{}[]:;'`\/,.?'
::          FOR TRANSLATING '=*~!' USE :not_safe_replace
::          IMPOSSIBLE TO TRANSLATE: '|&^<>!%'
::          Sample: call n0library.bat :translate "C:\file.txt" ":\." "___" result
::          Result: result='C__file_txt'
if "%~4"=="" call :fatal_error "Incorrect call :translate. 4 incoming arguments are mandatory"

set "translate__in_str=%~1"
if "%translate__in_str%" == "" goto :translate__exit
set "translate__from_map=%~2"
set "translate__to_map=%~3"
call :str_len "%translate__from_map%" translate__from_map_len
call :str_len "%translate__to_map%"   translate__to_map_len
if not "%translate__from_map_len%" == "%translate__to_map_len%" call :fatal_error "Incorrect call :translate. Length of maps are different (%translate__from_map_len%) '%translate__from_map%' vs (%translate__to_map_len%) '%translate__to_map%'"
set /a translate__from_map_len=%translate__from_map_len%-1

setlocal EnableDelayedExpansion
for /l %%i in (0,1,%translate__from_map_len%) do (
   call set "translate__from_char=%%translate__from_map:~%%i,1%%
   call set "translate__to_char=%%translate__to_map:~%%i,1%%
   call set "translate__in_str=%%translate__in_str:!translate__from_char!=!translate__to_char!%%
)
endlocal && set "translate__in_str=%translate__in_str%"
:translate__exit
set "%~4=%translate__in_str%"
set translate__in_str=
set translate__from_map=
set translate__to_map=
set translate__from_map_len=
set translate__to_map_len=
set translate__from_char=
set translate__to_char=
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:lower [%1 as incoming string to be converted; %2 as destination var name]
:: In:  %1 as path, %2 as destination var name
:: Out: !%2! == lower(%1)
:: Sample: call n0library.bat :lower "C:\Windows\notepad.exe" lower_filename
:: Result: lower_filename == c:\windows\notepad.exe
if "%~2"=="" call :fatal_error "Incorrect call :lower. 2 incoming arguments are mandatory"
call :translate "%~1" "ABCDEFGHIJKLMNOPQRSTUVWXYZ" "abcdefghijklmnopqrstuvwxyz" "%~2"
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:upper [%1 as incoming string to be converted; %2 as destination var name]
:: In:  %1 as path, %2 as destination var name
:: Out: !%2! == upper(%1)
:: Sample: call n0library.bat :upper "C:\Windows\notepad.exe" upper_filename
:: Result: upper_filename == C:\WINDOWS\NOTEPAD.EXE
if "%~2"=="" call :fatal_error "Incorrect call :upper. 2 incoming arguments are mandatory"
call :translate "%~1" "abcdefghijklmnopqrstuvwxyz" "ABCDEFGHIJKLMNOPQRSTUVWXYZ" "%~2"
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:str_in [%1 as String expression being searched; %2 as String expression sought; %3 as destination var name; %4 as optional value for %3]
:: In:  %1 as String expression being searched; %2 as String expression sought; %3 as destination var name; %4 as optional value for %3
:: Out: !%3! == True || ""
:: Sample: call n0library.bat :str_in "C:\Windows\notepad.exe" "windows" found
:: Result: found == True
:: Sample: call n0library.bat :str_in "C:\Windows\notepad.exe" "windows" found FOUND
:: Result: found == FOUND
:: Sample: call n0library.bat :str_in "C:\Windows\notepad.exe" "windowz" found
:: Result: found == ""
if "%~3"=="" call :fatal_error "Incorrect call :str_in. 3 incoming arguments are mandatory"
call :upper "%~1" str_in__STRING
call :upper "%~2" str_in__SUBSTR
set "str_in__VALUE=%~4"
if not defined str_in__VALUE set "str_in__VALUE=True"
set "str_in__FOUND="
setlocal EnableDelayedExpansion
if not "!str_in__STRING:%str_in__SUBSTR%=!"=="%str_in__STRING%" set "str_in__FOUND=%str_in__VALUE%"
endlocal && set "%~3=%str_in__FOUND%"
set str_in__STRING=
set str_in__SUBSTR=
set str_in__VALUE=
set str_in__FOUND=
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:equal_replace [%1 as string contains '='; %2 replacement; %3 as destination var name]
:: Sample: call :equal_replace "tag2=value1;tag2=value2;tag3=value3" ~ result
:: Result: result == "tag2~value1;tag2~value2;tag3~value3"
set "equal_replace__in_str=%~1"
if "%equal_replace__in_str%" == "" goto :equal_sign_replace__set_result_var
if "%equal_replace__in_str:~-1%" == "=" set "equal_replace__in_str=%equal_replace__in_str:~0,-1%%~2"
:equal_sign_replace__more_one_time
for /f "tokens=1* delims==" %%a in ("%equal_replace__in_str%") do (
    set "equal_replace__before_equal=%%a"
    set "equal_replace__after_equal=%%b"
)
if not defined equal_replace__after_equal goto :equal_sign_replace__set_result_var
set "equal_replace__in_str=%equal_replace__before_equal%%~2%equal_replace__after_equal%"
goto :equal_sign_replace__more_one_time
:equal_sign_replace__set_result_var
set "%~3=%equal_replace__in_str%"
set equal_replace__in_str=
set equal_replace__before_equal=
set equal_replace__after_equal=
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:not_safe_replace [%1 as string contains '=*~!'; %2 replacement; %3 as destination var name]
::          Sample: call :not_safe_replace "C:\~file=1!.*" _ result
::          Result: result == "C:\_file_1_._"
set "not_safe_replace__in_str=%~1"
if "%not_safe_replace__in_str%" == "" goto :not_safe_replace__exit
if "%not_safe_replace__in_str:~-1%" == "=" set "not_safe_replace__in_str=%not_safe_replace__in_str:~0,-1%%~2"
if "%not_safe_replace__in_str:~-1%" == "*" set "not_safe_replace__in_str=%not_safe_replace__in_str:~0,-1%%~2"
if "%not_safe_replace__in_str:~-1%" == "~" set "not_safe_replace__in_str=%not_safe_replace__in_str:~0,-1%%~2"
if "%not_safe_replace__in_str:~-1%" == "!" set "not_safe_replace__in_str=%not_safe_replace__in_str:~0,-1%%~2"
:not_safe_replace__more_one_time
for /f "tokens=1* delims==*~!" %%a in ("%not_safe_replace__in_str%") do (
    set "not_safe_replace__before_equal=%%a"
    set "not_safe_replace__after_equal=%%b"
)
if not defined not_safe_replace__after_equal goto :not_safe_replace__exit
set "not_safe_replace__in_str=%not_safe_replace__before_equal%%~2%not_safe_replace__after_equal%"
goto :not_safe_replace__more_one_time
:not_safe_replace__exit
set "%~3=%not_safe_replace__in_str%"
set not_safe_replace__in_str=
set not_safe_replace__before_equal=
set not_safe_replace__after_equal=
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:str_split_by_equal [%1 as incoming string to be splitted; %2 as destination var name with splitted part before '='; %3 as destination var name with splitted part after '=']
:: Sample: call :str_split_by_equal "tag1=value1" _tag _value
:: Result: _tag == "tag1", _value == "value1"
:: Set default empty values to result variable
set "%~2="
set "%~3="
if "%~1" == "" goto :eof
for /f "tokens=1* delims==" %%a in ("%~1") do (
    set "%~2=%%a"
    set "%~3=%%b"
)
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:get_value_by_tag [%1 as string contains pairs with separator ';'; %2 tag name; %3 as destination var name]
:: In:  %1 as string contains pairs with separator ';'; %2 tag name; %3 as destination var name
:: Out: !%3! == {value} || ""
:: Sample: call n0library.bat :str_in "ENV=1;ORG=2" "ENV" _ENV
:: Result: _ENV == 1
:: Sample: call n0library.bat :str_in "ENV=1;ORG=2" "ORG" _ORG
:: Result: _ORG == 2
:: Sample: call n0library.bat :str_in "ENV=1;ORG=2" "ORGLIST" _ORGLIST
:: Result: _ORGLIST == ""
if "%~3"=="" call :fatal_error "Incorrect call :get_value_by_tag. 3 incoming arguments are mandatory"
:: Set default empty values to result variable
set "%3="
set "get_value_by_tag__OTHER_PAIRS=%~1"
:get_value_by_tag__next_pair
if not defined get_value_by_tag__OTHER_PAIRS goto :eof
call :str_split2         "%get_value_by_tag__OTHER_PAIRS%"   ";"    get_value_by_tag__FIRST_PAIR get_value_by_tag__OTHER_PAIRS
call :str_split_by_equal "%get_value_by_tag__FIRST_PAIR%"           get_value_by_tag__TAG        get_value_by_tag__VALUE
if /i not "%get_value_by_tag__TAG%" == "%~2" goto :get_value_by_tag__next_pair
set "%3=%get_value_by_tag__VALUE%"
set get_value_by_tag__FIRST_PAIR=
set get_value_by_tag__OTHER_PAIRS=
set get_value_by_tag__TAG=
set get_value_by_tag__VALUE=
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:argv22 [convert %* into argv1=%1 .. argv21=%21, max_argv=21]
:: In:  prefix_ %*
:: Out: prefix_argv1=%0 .. prefix_argv21=%22, prefix_max_argv=22
:: Sample: call n0library.bat :argv22 prefix_ %*
:: Result: prefix_argv1=argument1 prefix_argv2=argument1 prefix_max_argv=2
set "argv21__prefix=%~1"
set "argv21__skip_leading_arguments=1"
goto :use_argv21__prefix

:argv21 [convert %* into argv1=%1 .. argv21=%21, max_argv=21]
:: In:  %*
:: Out: argv1=%0 .. argv21=%21, max_argv=21
:: Sample: call n0library.bat :argv21 %*
:: Result: argv1=argument1 argv2=argument1 max_argv=2
set "argv21__prefix="
set "argv21__skip_leading_arguments=0"
:use_argv21__prefix
set "argv21__max_argv=21"
:clean_all_possible_argv
set "argv21__argv%argv21__max_argv%="
set /a "argv21__max_argv-=1"
if %argv21__max_argv% neq 0 goto :clean_all_possible_argv

set argv21__argv_tmp=

@REM Replace all ' ' (not to confuse with other delimeters) into temporary tag '20'
set argv21__argv=%*
if not defined argv21__argv goto :eof
set "argv21__argv=%argv21__argv: =20%"

@REM Because of loop 'for' recognize '=' as delimiter (as ' '), we should replace all '=' into temporary tag '3D'
setlocal EnableDelayedExpansion
for %%a in (%argv21__argv%) do (
    @REM '=' is recognized as delimiter (because of all ' ' were replaced with temporary tag '20'),
    @REM so we will add '3D' in the place of eaten '='
    if not "!argv21__argv_tmp!" == "" set argv21__argv_tmp=!argv21__argv_tmp!3D
    set argv21__argv_tmp=!argv21__argv_tmp!%%a
)
endlocal && set "argv21__argv=%argv21__argv_tmp%"

@REM Replace temporary tag '20' back into ' ' to use it as default delimiter
set "argv21__argv=%argv21__argv:20= %"

@REM Split arguments line by ' '
set /a "argv21__max_argv-=%argv21__skip_leading_arguments%"
setlocal EnableDelayedExpansion
for %%a in (%argv21__argv%) do (
    set /a "argv21__max_argv+=1"
    if !argv21__max_argv! geq 1 (
        set "curr_arg=%%~a"
        @REM Replace temporary tag '3D' back into '='
        if defined curr_arg set "curr_arg=!curr_arg:3D==!"
        set "argv21__argv!argv21__max_argv!=!curr_arg!"
        if defined argv21__argv_tmp set "argv21__argv_tmp=!argv21__argv_tmp! "
        set argv21__argv_tmp=!argv21__argv_tmp!"!curr_arg!"
        REM @echo [!argv21__max_argv!]='!curr_arg!'
    )
)
endlocal && set "%argv21__prefix%argv=%argv21__argv_tmp%" ^
         && set "%argv21__prefix%max_argv=%argv21__max_argv%" ^
         && set "%argv21__prefix%argv1=%argv21__argv1%" ^
         && set "%argv21__prefix%argv2=%argv21__argv2%" ^
         && set "%argv21__prefix%argv3=%argv21__argv3%" ^
         && set "%argv21__prefix%argv4=%argv21__argv4%" ^
         && set "%argv21__prefix%argv5=%argv21__argv5%" ^
         && set "%argv21__prefix%argv6=%argv21__argv6%" ^
         && set "%argv21__prefix%argv7=%argv21__argv7%" ^
         && set "%argv21__prefix%argv8=%argv21__argv8%" ^
         && set "%argv21__prefix%argv9=%argv21__argv9%" ^
         && set "%argv21__prefix%argv10=%argv21__argv10%" ^
         && set "%argv21__prefix%argv11=%argv21__argv11%" ^
         && set "%argv21__prefix%argv12=%argv21__argv12%" ^
         && set "%argv21__prefix%argv13=%argv21__argv13%" ^
         && set "%argv21__prefix%argv14=%argv21__argv14%" ^
         && set "%argv21__prefix%argv15=%argv21__argv15%" ^
         && set "%argv21__prefix%argv16=%argv21__argv16%" ^
         && set "%argv21__prefix%argv17=%argv21__argv17%" ^
         && set "%argv21__prefix%argv18=%argv21__argv18%" ^
         && set "%argv21__prefix%argv19=%argv21__argv19%" ^
         && set "%argv21__prefix%argv20=%argv21__argv20%" ^
         && set "%argv21__prefix%argv21=%argv21__argv21%"


set argv21__argv_tmp=
set argv21__max_argv=
set argv21__argv=
set argv21__skip_leading_arguments=
set argv21__prefix=

goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:str_left [%1 as input str; %2 as character count; %3 as destination var name]
::          Sample: call n0library.bat :str_left "1234567" 3 result
::          Result: result=123
if "%~3"=="" call :fatal_error "Incorrect call :str_left. 3 incoming arguments are mandatory"
set "str_left__out_str=%~1"
setlocal EnableDelayedExpansion
set "str_left__out_str=!str_left__out_str:~0,%~2!"
endlocal && set "%~3=%str_left__out_str%"
set str_left__out_str=
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:str_right [%1 as input str; %2 as character count; %3 as destination var name]
::          Sample: call n0library.bat :str_right "1234567" 3 result
::          Result: result=567
if "%~3"=="" call :fatal_error "Incorrect call :str_right. 3 incoming arguments are mandatory"
set "str_right__out_str=%~1"
setlocal EnableDelayedExpansion
set "str_right__out_str=!str_right__out_str:~-%~2!"
endlocal && set "%~3=%str_right__out_str%"
set str_right__out_str=
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:str_mid [%1 as input str; %2 as offset, %3 as character count; %4 as destination var name]
::          Sample: call n0library.bat :str_right "1234567" 3 3 result
::          Result: result=456
if "%~4"=="" call :fatal_error "Incorrect call :str_mid. 4 incoming arguments are mandatory"
set "str_mid__out_str=%~1"
setlocal EnableDelayedExpansion
set "str_mid__out_str=!str_mid__out_str:~%~2,%~3!"
endlocal && set "%~4=%str_mid__out_str%"
set str_mid__out_str=
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:str_ltrim [%1 as input str; %2 as destination var name]
::          Sample: call n0library.bat :str_ltrim "      1234567      " result
::          Result: result='1234567      '
if "%~2"=="" call :fatal_error "Incorrect call :str_ltrim. 2 incoming arguments are mandatory"
for /f "tokens=* delims= " %%a in ("%~1") do set "%~2=%%a"
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:str_rtrim [%1 as input str; %2 as destination var name]
::          Sample: call n0library.bat :str_rtrim "      1234567      " result
::          Result: result='      1234567'
if "%~2"=="" call :fatal_error "Incorrect call :str_rtrim. 2 incoming arguments are mandatory"
REM set "str_rtrim__in_str=%~1"
REM setlocal EnableDelayedExpansion
REM for /l %%a in (1,1,31) do if "!str_rtrim__in_str:~-1!"==" " set str_rtrim__in_str=!str:~0,-1!
REM endlocal && set "%~2=%str_rtrim__in_str%"
set "str_rtrim__in_str=%~1@$#EOL@$#"
set "str_rtrim__in_str=%str_rtrim__in_str:                @$#EOL@$#=@$#EOL@$#%"
set "str_rtrim__in_str=%str_rtrim__in_str:        @$#EOL@$#=@$#EOL@$#%"
set "str_rtrim__in_str=%str_rtrim__in_str:    @$#EOL@$#=@$#EOL@$#%"
set "str_rtrim__in_str=%str_rtrim__in_str:  @$#EOL@$#=@$#EOL@$#%"
set "str_rtrim__in_str=%str_rtrim__in_str: @$#EOL@$#=@$#EOL@$#%"
set "%~2=%str_rtrim__in_str:@$#EOL@$#=%"
set str_rtrim__in_str=
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:str_trim [%1 as input str; %2 as destination var name]
::          Sample: call n0library.bat :str_trim "      1234567      " result
::          Result: result='1234567'
if "%~2"=="" call :fatal_error "Incorrect call :str_trim. 2 incoming arguments are mandatory"
call :str_ltrim "%~1" str_ltrimed
call :str_rtrim "%str_ltrimed%" "%~2"
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:str_align [%1 as input str; %2 as character count; %3 as destination var name]
::          Sample: call n0library.bat :str_align "1234567" 10 result
::          Result: result='   1234567'
if "%~3"=="" call :fatal_error "Incorrect call :str_align. 3 incoming arguments are mandatory"
set "str_align__str_mid__out_str=                      %~1"
setlocal EnableDelayedExpansion
set "str_align__str_mid__out_str=!str_align__str_mid__out_str:~-%~2!"
endlocal && set "%~3=%str_align__str_mid__out_str%"
set str_align__str_mid__out_str=
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:remove_duplicated [%1 as input str; %2 as possible duplicated character; %3 as destination var name]
::          Sample: call n0library.bat :remove_duplicated "C__file___txt" "_" result
::          Result: result='C_file_txt'
if "%~3"=="" call :fatal_error "Incorrect call :remove_duplicated. 3 incoming arguments are mandatory"
set "remove_duplicated__str_mid__out_str=%~1"
if "%remove_duplicated__str_mid__out_str%" == "" goto :remove_duplicated_exit
:repeate_remove_duplicated
set "remove_duplicated__prv_str=%remove_duplicated__str_mid__out_str%"
setlocal EnableDelayedExpansion
set "remove_duplicated__str_mid__out_str=!remove_duplicated__prv_str:%~2%~2=%~2!"
endlocal && set "remove_duplicated__str_mid__out_str=%remove_duplicated__str_mid__out_str%"
if not "%remove_duplicated__prv_str%" == "%remove_duplicated__str_mid__out_str%" goto :repeate_remove_duplicated
:remove_duplicated_exit
set "%~3=%remove_duplicated__str_mid__out_str%"
set remove_duplicated__str_mid__out_str=
set remove_duplicated__prv_str=
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:translate_into_safe [%1 as input str; %2 as destination var name]
::          EXTREMELY NOT SAFE CHARACTERS '|&^<>!%' ARE IMPOSSIBLE TO TRANSLATE!
::          Sample: call n0library.bat :translate_into_safe "C:\file-!.txt" result
::          Result: result='C__file___txt'
if "%~2"=="" call :fatal_error "Incorrect call :translate_into_safe. 2 incoming arguments are mandatory"

call :not_safe_replace "%~1" _ translate_into_safe__partialy_translated
call :translate "%translate_into_safe__partialy_translated%" " @#$()+-{}[]:;'`\/,.?" "_____________________" translate_into_safe__partialy_translated
call :remove_duplicated "%translate_into_safe__partialy_translated%" _ "%~2"

set translate_into_safe__partialy_translated=
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:if_exists [%1 as files' names' list == C:\UTIL\notepad.exe;C:\Windows\notepad.exe;C:\Windows\System32\notepad.exe] [%2 as var name == notepad_exe] [%3 flag to exit in case of not exists]
::          Sample: call n0library.bat :if_exists "C:\UTIL\notepadpp.exe;C:\Windows\notepad.exe;C:\Windows\System32\notepad.exe" notepad_exe
::          Result:
::              if %3 is empty:
::                  notepad_exe='C:\Windows\notepad.exe' if 'C:\Windows\notepad.exe' exists and '' if all files in the list don't exist
::              if %3 is NOT empty:
::                  notepad_exe='C:\Windows\notepad.exe' if 'C:\Windows\notepad.exe' exists and termination if all files in the list don't exist
if "%~2"=="" call :fatal_error "Incorrect call :if_exists. 2 incoming arguments are mandatory"
set "%~2="
set "if_exists__OTHER_PATHS=%~1"
:if_exists_next_file
if not defined if_exists__OTHER_PATHS goto :if_exists_exit
call :str_split2 "%if_exists__OTHER_PATHS%" ";" if_exists__FIRST_PATH if_exists__OTHER_PATHS
if not exist "%if_exists__FIRST_PATH%" goto :if_exists_next_file
call :full_path "%if_exists__FIRST_PATH%" "%~2"
:if_exists_exit
if not "%~3"=="" (
    if not exist "%if_exists__FIRST_PATH%" call :fatal_error "No one files found from '%~1' which should be stored in variable '%~2'"
)
set if_exists__FIRST_PATH=
set if_exists__OTHER_PATHS=
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:file_size [%1 as file path] [%2 as var name == notepad_exe]
::          Sample: call n0library.bat :file_size "C:\Windows\notepad.exe" notepad_exe_size
::          Result: notepad_exe_size='254464' if 'C:\Windows\notepad.exe' exists and '' it doesn't exist
if "%~2"=="" call :fatal_error "Incorrect call :file_size. 2 incoming arguments are mandatory"
set "%~2=0"
REM if exist "%~1" echo '%~1' exists && set "%~2=%~z1"
if exist "%~1" set "%~2=%~z1"
REM echo Size = '%~z1'
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:prev_date [%1 as TIMESTAMP_YYMMDD] [%2 as var name == PDATE_YYMMDD] [%3 as centure == ''] [%4 as separator == '']
::          Sample: call n0library.bat :prev_date 231015
::          Result: PDATE_YYMMDD='231014'
::          Sample: call n0library.bat :prev_date 231015 PDATE_YYMMDD 20
::          Result: PDATE_YYMMDD='20231014'
::          Sample: call n0library.bat :prev_date 231015 PDATE_YYMMDD 20 -
::          Result: PDATE_YYMMDD='2023-10-14'
::          Sample: call n0library.bat :prev_date 231015 PDATE_YYMMDD "" -
::          Result: PDATE_YYMMDD='23-10-14'
if "%~1"=="" call :fatal_error "Incorrect call :prev_date. 1 incoming argument is mandatory"
set "prev_date__result=%~2"
if not "%prev_date__result%" == "" goto :user_defined__prev_date__result
set "prev_date__result=PDATE_YYMMDD"
:user_defined__prev_date__result
set "prev_date__centure=%~3"
set "prev_date__separator=%~4"

setlocal EnableDelayedExpansion
set "TIMESTAMP_YYMMDD=%~1"
set /A "YY=!TIMESTAMP_YYMMDD:~0,2!, MM=1!TIMESTAMP_YYMMDD:~2,2!-100, DD=1!TIMESTAMP_YYMMDD:~4,2!-101, FEB=28+^!(YY%%4)"

set "DayPerMonth= 31 31 %Feb% 31 30 31 30 31 31 30 31 30"
if %DD% equ 0 set /A "MM+=M=-1,DD=0%DayPerMonth: =+^!(MM-(M+=1))*%,YY-=^!MM,MM+=12*^!MM"
set /A "MM+=100,DD+=100"
endlocal && set "%prev_date__result%=%prev_date__centure%%YY%%prev_date__separator%%MM:~1%%prev_date__separator%%DD:~1%"

goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:timestamp_to_YYMMDD [%1 as TIMESTAMP_YYMMDD] [%2 as var name == DATE_YYMMDD] [%3 as centure == ''] [%4 as separator == '']
::          Sample: call n0library.bat :timestamp_to_YYMMDD 231015_012345_678
::          Result: DATE_YYMMDD='231015'
::          Sample: call n0library.bat :timestamp_to_YYMMDD 231015_012345_678 DATE_YYMMDD
::          Result: DATE_YYMMDD='231015'
::          Sample: call n0library.bat :timestamp_to_YYMMDD 231015_012345_678 DATE_YYMMDD 20
::          Result: DATE_YYMMDD='20231015'
::          Sample: call n0library.bat :timestamp_to_YYMMDD 231015_012345_678 DATE_YYMMDD 20 -
::          Result: DATE_YYMMDD='2023-10-15'
::          Sample: call n0library.bat :timestamp_to_YYMMDD 231015_012345_678 DATE_YYMMDD "" -
::          Result: DATE_YYMMDD='23-10-15'
if "%~1"=="" call :fatal_error "Incorrect call :timestamp_to_YYMMDD. 1 incoming argument is mandatory"
set "timestamp_to_YYMMDD__result=%~2"
if not "%timestamp_to_YYMMDD__result%" == "" goto :user_defined__timestamp_to_YYMMDD__result
set "timestamp_to_YYMMDD__result=DATE_YYMMDD"
:user_defined__timestamp_to_YYMMDD__result
set "timestamp_to_YYMMDD__centure=%~3"
set "timestamp_to_YYMMDD__separator=%~4"

setlocal EnableDelayedExpansion
set "TIMESTAMP_YYMMDD=%~1"
set "YY=!TIMESTAMP_YYMMDD:~0,2!"
set "MM=!TIMESTAMP_YYMMDD:~2,2!"
set "DD=!TIMESTAMP_YYMMDD:~4,2!"
endlocal && set "%timestamp_to_YYMMDD__result%=%timestamp_to_YYMMDD__centure%%YY%%timestamp_to_YYMMDD__separator%%MM%%timestamp_to_YYMMDD__separator%%DD%"

goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:timestamp_to_DDMMYY [%1 as TIMESTAMP_YYMMDD] [%2 as var name == DATE_DDMMYY] [%3 as centure == ''] [%4 as separator == '']
::          Sample: call n0library.bat :timestamp_to_DDMMYY 231015
::          Result: DATE_DDMMYY='151023'
::          Sample: call n0library.bat :timestamp_to_DDMMYY 231015 DATE_DDMMYY
::          Result: DATE_DDMMYY='151023'
::          Sample: call n0library.bat :timestamp_to_DDMMYY 231015 DATE_DDMMYY 20
::          Result: DATE_DDMMYY='15102023'
::          Sample: call n0library.bat :timestamp_to_DDMMYY 231015 DATE_DDMMYY 20 -
::          Result: DATE_DDMMYY='15-10-2023'
::          Sample: call n0library.bat :timestamp_to_DDMMYY 231015 DATE_DDMMYY "" -
::          Result: DATE_DDMMYY='15-10-23'
if "%~1"=="" call :fatal_error "Incorrect call :timestamp_to_DDMMYY. 1 incoming argument is mandatory"
set "timestamp_to_DDMMYY__result=%~2"
if not "%timestamp_to_DDMMYY__result%" == "" goto :user_defined_timestamp_to_DDMMYY__result
set "timestamp_to_DDMMYY__result=DATE_DDMMYY"
:user_defined_timestamp_to_DDMMYY__result
set "timestamp_to_DDMMYY__centure=%~3"
set "timestamp_to_DDMMYY__separator=%~4"

setlocal EnableDelayedExpansion
set "TIMESTAMP_YYMMDD=%~1"
set "YY=!TIMESTAMP_YYMMDD:~0,2!"
set "MM=!TIMESTAMP_YYMMDD:~2,2!"
set "DD=!TIMESTAMP_YYMMDD:~4,2!"
endlocal && set "%timestamp_to_DDMMYY__result%=%DD%%timestamp_to_DDMMYY__separator%%MM%%timestamp_to_DDMMYY__separator%%timestamp_to_DDMMYY__centure%%YY%"

goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
