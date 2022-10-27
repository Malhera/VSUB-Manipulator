@echo off
setlocal EnableDelayedExpansion
set "starboundpath=C:\Program Files (x86)\Steam\steamapps\common\Starbound"
REM  Here, there! ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
REM  If you need to change the starbound path, it's there! Don't mess up the format "starboundpath=\Starboudfolderpath"
REM  A quote before the variable name, a quote after the variable value!
set backups_to_keep=10
REM  Here just there^ you can change how many backups of each dataslot you wanna keep
REM -------------------------------------------------------------------------------------------------------------------
:runcheck
tasklist /FI "IMAGENAME eq starbound.exe" | findstr "starbound.exe" >nul
if %ERRORLEVEL% == 0 echo "Can't do backup, switch, or restore operations while the game is running..."
if %ERRORLEVEL% == 1 goto prelaunch
timeout 20
goto runcheck
REM --------------------------------------------------------------------------------Main Menu
:menu0
set ops=0
call:displayactivedataslot
echo   #        Choose the kind of operation you want to execute on data sets     #
IF "!lastbackup!"=="1" (
    set "line=  # %lastbackup_stamp%     1--Backup - [DONE] on Slot %lastbackup_slot% : %lastbackup_name%%g3%%g3%%g3%"
) ELSE IF "!lastbackup!"=="2" (
    set "line=  #              1--Backup - [FAILED] on Slot %lastbackup_slot% : %lastbackup_name%%g3%%g3%%g3%"
) ELSE (
    set "line=  #              1--Backup   %g3%%g3%%g3%"
)
set "line=%line:~0,76% #"
echo %line%

IF "!lastrestore!"=="1" (
    set "line=  # %lastrestore_stamp%     2--Restore - [DONE] on Slot %lastrestore_slot% : %lastrestore_name%%g3%%g3%%g3%"
) ELSE IF "!lastrestore!"=="2" (
    set "line=  # %lastrestore_stamp%     2--Restore - [FAILED] on Slot %lastrestore_slot% : %lastrestore_name%%g3%%g3%%g3%"
) ELSE IF "!lastrestore!"=="3" (
    set "line=  #[ERROR EARLY] 2--Restore - on Set %lastrestore_slot% %lastrestoreerror% %g3%%g3%%g3%"
) ELSE (
    set "line=  #              2--Restore   %g3%%g3%%g3%"
)
set "line=%line:~0,76% #"
echo %line%
echo   #              3--Switch   %g3%%g3%%g3%#
echo   #              4--Manage All Slots         %g3%%g3%#
echo   #              5--Quit     %g3%%g3%     ? for help #
%minig2%%g3%%la%color 0F
set /p ops=Type the corresponding number of your choice then press ENTER: 
set ops | FINDSTR /R /C:"[&""|()]">nul
IF NOT ERRORLEVEL 1 set ops=0 >nul
echo.
if "%ops%"=="1" echo Backup process started... & call:makebackup %activedsnum% %activedsnam% & goto title
if "%ops%"=="2" call:menuselect 1 restore & goto title
if "%ops%"=="3" call:menuselect 3 switch & goto title
if "%ops%"=="4" call:menuselect 3 manage & goto title
if "%ops%"=="5" goto exit
if "%ops%"=="?" call:help0 & pause & goto title
color 0c%la%goto title
REM --------------------------------------------------------------------------------Backuplist menu
:menu1
set ops=0
call:detectbackups
if "!menumode1!"=="restore" (
    call:displayactivedataslot
    set backupslot=%activedsnum%
    set "line=  #           Choose which backup you want to Restore to Slot !backupslot!%g3%"
    set "line=!line:~0,76! #"
    echo !line!
) else if "!menumode1!"=="import" (
    call:displayselectedslot %selectedimportsource% %activedsnum%
    set backupslot=%selectedimportsource%
    set "line=  #        Choose from which Backup you want to Import into Slot %selectedimportdest%%g3%%g3%"
    set "line=!line:~0,76! #"
    echo !line! 
)
set COUNT=0
IF NOT exist "%backuplocation%\dataslot%backupslot%\backup_????-??-??_??-??-??" (
    echo   # - - -%g3%%g3%%g3%              - - - #
    echo   #              There are no backup available for this dataslot             #
    echo   # - - -%g3%%g3%%g3%              - - - #
) else (
    for /F "delims=" %%a in ('dir /ad /o-n /b "%backuplocation%\dataslot%backupslot%\backup_????-??-??_??-??-??"') do ( 
        set /A COUNT=!COUNT! + 1
        call:math !COUNT! 9
        set "padding= "
        set "hpadding= "
        set "hdash=-"
        if !mathresult!==1 (
            set "padding="
            call:math !COUNT! 99
            if !mathresult!==1 (
                set "hpadding=" 
                set "hdash="
            )
        )
        set "line=  #             !padding!!COUNT!-!hdash!!hpadding![...]\dataslot%backupslot%\%%a               %g3%%g3%"
        set "line=!line:~0,76! #"
        echo !line! 
    )
    if "!menumode1!"=="import" (
        set /A COUNT=!COUNT! + 1
        set "line=  #             !padding!!COUNT!-!hdash!!hpadding!FULL dataset copy into Slot %selectedimportdest%%g3%%g3%"
        set "line=!line:~0,76! #"
        echo !line! 
    )
)
set /A lastoption=!COUNT! + 1
set "line=  #             !padding!%lastoption%-!hdash!!hpadding!Go back to main menu     %g3%%g3%"
set "line=%line:~0,76% #"
echo %line%
%minig2%%g3%%la%color 0F
set /p ops=Type the corresponding number of your choice then press ENTER: 
set ops | FINDSTR /R /C:"[&""|()]">nul
IF NOT ERRORLEVEL 1 set ops=0 >nul
echo.
set /A ops=%ops% + 1 - 1
REM math IF %ops% GEQ 1 IF %ops% LEQ !COUNT!
call:math %ops% 1
set "Test1=" & IF "!mathresult!"=="1" set "Test1=1"
IF "!mathresult!"=="0" set "Test1=1"
call:math %ops% !COUNT!
set "Test2=" & IF "!mathresult!"=="-1" set "Test2=1"
IF "!mathresult!"=="0" set "Test2=1"
IF !Test2!==1 IF !Test1!==1 (
    if "!menumode1!"=="restore" (
        set COUNT=0
        for /F "delims=" %%a in ('dir /ad /o-n /b "%backuplocation%\dataslot%backupslot%\*"') do ( 
            set /A COUNT=!COUNT! + 1
            IF "%ops%"=="!COUNT!" (
                call:restore "%backupslot%" "%%a" & call:menuselect 0 & goto title
            )  
        )
    ) else if "!menumode1!"=="import" (
        if "%ops%"=="!COUNT!" (
            set "importsourcebackup=all" & call:menuselect 2 import & goto title
        ) else (
            set COUNT=0
            for /F "delims=" %%a in ('dir /ad /o-n /b "%backuplocation%\dataslot%selectedimportsource%\*"') do ( 
                set /A COUNT=!COUNT! + 1
                IF "%ops%"=="!COUNT!" (
                    set "importsourcebackup=%%a" & call:menuselect 2 import & goto title
                )  
            ) 
        )
    )
)
if "%ops%"=="%lastoption%" (
    if "!menumode1!"=="restore" (
        call:menuselect 0%la%goto title
    ) else if "!menumode1!"=="import" (
        call:menuselect 3 import & goto title
    )
)
color 0c%la%goto title
REM --------------------------------------------------------------------------------Naming Operation Menu
:menu2
if "!menumode2!"=="create" (
    call:displayselectedslot %selectedmanageslot% %activedsnum%
    set "menuline1=  #             Choose a name for your new dataset on Slot %selectedmanageslot%%g3%%g3%%g3%"
    set "menuline1=!menuline1:~0,76! #"
    echo !menuline1!
) else if "!menumode2!"=="rename" (
    call:displayselectedslot %selectedmanageslot% %activedsnum%
    set "menuline1=  #             Choose a new name for your dataset on Slot %selectedmanageslot%%g3%%g3%%g3%"
    set "menuline1=!menuline1:~0,76! #"
    echo !menuline1!
    set "menuline2=  #     Current name = !selectedmanageslotname!%g3%%g3%%g3%%g3%"
    set "menuline2=!menuline2:~0,76! #"
    echo !menuline2!
) else if "!menumode2!"=="import" (
    call:displayselectedslot %selectedimportdest% %activedsnum%
    set "menuline1=  #             Choose a new name for your dataset on Slot %selectedimportdest%%g3%%g3%%g3%"
    set "menuline1=!menuline1:~0,76! #"
    echo !menuline1!
    set "menuline2=  #     Source = %selectedimportsource%-!dataslotname%selectedimportsource%! %g3%%g3%%g3%%g3%"
    set "menuline2=!menuline2:~0,76! #"
    echo !menuline2!
    if "%importsourcebackup%"=="all" (
        set "menuline3=  #              Whole data set %g3%%g3%%g3%%g3%"
    ) else (
        set "menuline3=  #             [...]dataset%selectedimportsource%/%importsourcebackup%%g3%%g3%%g3%"
    )
    set "menuline3=!menuline3:~0,76! #"
    echo !menuline3!
) else if "!menumode2!"=="createnoback" (
    call:displayselectedslot %selectedmanageslot% %selectedmanageslot%
    set "menuline1=  #             Choose a name for your current dataset on Slot %selectedmanageslot%%g3%%g3%%g3%"
    set "menuline1=!menuline1:~0,76! #"
    echo !menuline1!
)
    echo   # - - -%g3%%g3%%g3%              - - - #
    echo   #      Try to keep it under 30 characters if possible for lisibility.      #
    echo   #   And please... no weird symbols. You don't want to fuck-up your saves.  #
if "!menumode2!"=="createnoback" (
    echo   # - - -%g3%%g3%%g3%              - - - #
) else (
    echo   # - - -%g3%%g3%%g3%Type "b" to go back #
) 
%minig2%%g3%%la%color 0F
set /p newname=Type the desired name and then press ENTER: 
set ops | FINDSTR /R /C:"[&""|()]">nul
IF NOT ERRORLEVEL 1 set ops=0 >nul
echo.
if NOT "!menumode2!"=="createnoback"  (
    if "!menumode2!"=="import" (
        if "%newname%"=="b" call:menuselect 1 import & goto title
    ) else if "!menumode2!"=="create" (
        if "%newname%"=="b" call:menuselect manageslot & goto title
    ) else if "!menumode2!"=="rename" (
        if "%newname%"=="b" call:menuselect manageslot & goto title
    )
)
set ops2=0
echo Confirm the following: "!newname:~0,50!"
set /p ops2=Type "CONFIRM" to validate name, anything else cancels:
set ops | FINDSTR /R /C:"[&""|()]">nul
IF NOT ERRORLEVEL 1 set ops2=0 >nul
echo.
if "!menumode2!"=="create" (
    if "!ops2!"=="CONFIRM" (
        echo Creating Dataset "!newname:~0,50!" in Slot %selectedmanageslot% ...
        if NOT exist "%backuplocation%\dataslot%selectedmanageslot%" mkdir "%backuplocation%\dataslot%selectedmanageslot%"
        (echo !newname:~0,50!)>"%backuplocation%\dataslot%selectedmanageslot%\setname.bin"
        IF NOT exist "%backuplocation%\dataslot%selectedmanageslot%\backup_????-??-??_??-??-??" (
            mkdir "%backuplocation%\dataslot%selectedmanageslot%\backup_0000-00-00_00-00-00"
            mkdir "%backuplocation%\dataslot%selectedmanageslot%\backup_0000-00-00_00-00-00\player"
            mkdir "%backuplocation%\dataslot%selectedmanageslot%\backup_0000-00-00_00-00-00\universe"
        )
        Echo Done!
        timeout 1 > NUL
        call:menuselect 3 manage & goto title
    )
)
if "!menumode2!"=="rename" (
    if "!ops2!"=="CONFIRM" (
        echo Renaming Dataset "!newname:~0,50!" in Slot %selectedmanageslot% ...
        if NOT exist "%backuplocation%\dataslot%selectedmanageslot%" mkdir "%backuplocation%\dataslot%selectedmanageslot%"
        IF "%activedsnum%"=="%selectedmanageslot%" (
            (echo %activedsnum%)>"%starboundpath%\storage\set.bin"
            (echo !newname:~0,50!)>>"%starboundpath%\storage\set.bin"
        )
        IF NOT exist "%backuplocation%\dataslot%selectedmanageslot%\backup_????-??-??_??-??-??" (
            call:makebackup %selectedmanageslot% !newname:~0,50!
        ) else (
            (echo !newname:~0,50!)>"%backuplocation%\dataslot%selectedmanageslot%\setname.bin"
        )
        timeout 1 > NUL
        call:menuselect 3 manage & goto title
    )
)
if "!menumode2!"=="import" (
    if "!ops2!"=="CONFIRM" (
        echo Cleaning destination Slot %selectedimportdest%...
        if exist "%backuplocation%\dataslot%selectedimportdest%" rd /Q /S "%backuplocation%\dataslot%selectedimportdest%"
        timeout 1 > NUL
        echo Naming Imported Dataset "!newname:~0,50!" in Slot %selectedmanageslot% ...
        mkdir "%backuplocation%\dataslot%selectedimportdest%"
        if "%importsourcebackup%"=="all" (
            xcopy /s/e /V /H /K /Y /Q "%backuplocation%\dataslot%selectedimportsource%\*" "%backuplocation%\dataslot%selectedimportdest%\"
        ) else (
            xcopy /s/e /V /H /K /Y /Q "%backuplocation%\dataslot%selectedimportsource%\%importsourcebackup%\*" "%backuplocation%\dataslot%selectedimportdest%\%importsourcebackup%\"
        )
        (echo !newname:~0,50!)>"%backuplocation%\dataslot%selectedimportdest%\setname.bin"
        timeout 1 > NUL
        call:menuselect 3 manage & goto title
    )
)
if "!menumode2!"=="createnoback" (
    if "!ops2!"=="CONFIRM" (
        echo Naming Dataset "!newname:~0,50!" in Slot %selectedmanageslot% ...
        (echo %selectedmanageslot%)>"%starboundpath%\storage\set.bin"
        (echo !newname:~0,50!)>>"%starboundpath%\storage\set.bin"
        echo Cleaning destination Slot %selectedmanageslot%...
        if exist "%backuplocation%\dataslot%selectedmanageslot%" rd /Q /S "%backuplocation%\dataslot%selectedmanageslot%"
        echo Backup process started... 
        call:makebackup %selectedmanageslot% !newname:~0,50!
        set missmatchdetect=0
        call:detectactivedataslot
        timeout 1 > NUL
        call:menuselect 0 & goto title
    )
)
color 0c%la%goto title
REM --------------------------------------------------------------------------------Menu Slot selection
:menu3
set ops=0
call:detectbackups
if NOT "!menumode3!"=="createnoback" call:detectactivedataslot
%minig1%
if "!menumode3!"=="switch" (
    echo   #             Choose which dataset slot you want to activate.              #
    echo   #   Current active slot will be backed up automatically, unless specified  #
    echo   # - - -%g3%%g3%%g3%              - - - #
    set COUNT=0
    FOR /L %%c IN (1,1,!slotcount!) DO (
        if NOT "!dataslotname%%c!"=="Empty" (
            set /A COUNT=!COUNT! + 1
            call:displaydataslotinmenu %%c !dataslotname%%c! !COUNT!
        )
    )
    set /A lastoption=!COUNT! + 1
    echo   # - - -%g3%%g3%%g3%add f before number #
    set "lastline=  #             !padding!!lastoption!-!hdash!!hpadding!Go back to main menu              to not backup ex: f1%g3%"
    set "lastline=!lastline:~0,76! #"
    echo !lastline!
) else if "!menumode3!"=="manage" (
    echo   #      Choose which dataslot slot you want to delete, create or rename     #
    echo   # - - -%g3%%g3%%g3%              - - - #
    set COUNT=0
    FOR /L %%c IN (1,1,!slotcount!) DO (
        set /A COUNT=!COUNT! + 1
        call:displaydataslotinmenu %%c !dataslotname%%c! !COUNT!
    )
    set /A lastoption=!COUNT! + 1
    echo   # - - -%g3%%g3%%g3%              - - - #
    set "lastline=  #             !padding!!lastoption!-!hdash!!hpadding!Go back to main menu%g3%%g3%%g3%"
    set "lastline=!lastline:~0,76! #"
    echo !lastline!
) else if "!menumode3!"=="import" (
    echo   #      Choose which dataslot you want to import data from in the list      #
    echo   # - - -%g3%%g3%%g3%              - - - #
    set COUNT=0
    FOR /L %%c IN (1,1,!slotcount!) DO (
        if NOT "!dataslotname%%c!"=="Empty" (
            set /A COUNT=!COUNT! + 1
            call:displaydataslotinmenu %%c !dataslotname%%c! !COUNT!
        )
    )
    set /A lastoption=!COUNT! + 1
    echo   # - - -%g3%%g3%%g3%              - - - #
    set "lastline=  #             !padding!!lastoption!-!hdash!!hpadding!Go back to main menu%g3%%g3%%g3%"
    set "lastline=!lastline:~0,76! #"
    echo !lastline!
) else if "!menumode3!"=="createnoback" (
    if "!missmatchdetect!"=="1" (
    echo   #    Your current active dataset doesn't have a name or associated slot    #
    echo   #                       Select a dataslot to use:                          #
    ) else (
    echo   #  Your current active dataset name doesn't match with its slot's backups  #
    echo   #         Select a new dataslot to use for your current dataset:           #
    )
    echo   # - - -%g3%%g3%%g3%              - - - #
    set COUNT=0
    FOR /L %%c IN (1,1,!slotcount!) DO (
        if "!dataslotname%%c!"=="Empty" (
            set /A COUNT=!COUNT! + 1
            call:displaydataslotinmenu %%c !dataslotname%%c! !COUNT!
        )
    )
    set /A lastoption=!COUNT! + 1
    echo   # - - -%g3%%g3%%g3%              - - - #
)
%minig2%%g3%%la%color 0F
if "!menumode3!"=="import" echo Selecting an active slot will make an auto-backup.
set /p ops=Type the corresponding number of your choice then press ENTER: 
set ops | FINDSTR /R /C:"[&""|()]">nul
IF NOT ERRORLEVEL 1 set ops=0 >nul
echo.
REM math IF %ops% GEQ 1 IF %ops% LEQ !COUNT!
call:math %ops:f=% 1
set "Test1=" & IF "!mathresult!"=="1" set "Test1=1"
IF "!mathresult!"=="0" set "Test1=1"
call:math %ops:f=% !COUNT!
set "Test2=" & IF "!mathresult!"=="-1" set "Test2=1"
IF "!mathresult!"=="0" set "Test2=1"
IF "!menumode3!"=="switch" (
    if "%ops%"=="%lastoption%" call:menuselect 0%la%goto title
    IF !Test2!==1 IF !Test1!==1 (
        IF "%ops:f=%"=="%activedsnum%" (
            goto title
        )
        IF NOT "%ops:~0,1%"=="f" (
            echo Backup process started... 
            call:makebackup %activedsnum% %activedsnam% 
        ) ELSE IF NOT EXIST "%backuplocation%\dataslot%activedsnum%\backup_????-??-??_??-??-??" (
            echo No-Backup Switching option forced off
            echo You had no backup on your current active slot %activedsnum%
            timeout 1 > NUL
            echo Backup process started... 
            call:makebackup %activedsnum% %activedsnam%
            timeout 1 > NUL
        )
        echo Switching...
        for /F "delims= eol=|" %%I in ('dir /ad /on /b "%backuplocation%\dataslot!menuslotselected%ops:f=%!\backup_????-??-??_??-??-??"') do ( 
            set selectedbackup=%%I 
        )
        IF EXIST "%backuplocation%\dataslot!menuslotselected%ops:f=%!\backup_????-??-??_??-??-??" (
            call:restore !menuslotselected%ops:f=%! !selectedbackup!
            echo Done!
            timeout 1 > NUL
        ) else (
            echo Slot !menuslotselected%ops:f=%! contains no backups... 
            timeout 1 > NUL
            echo Marking as empty...
            (echo Empty)>"%backuplocation%\dataslot!menuslotselected%ops:f=%!\setname.bin"
            timeout 1 > NUL
            echo Done!
            timeout 4 > NUL
        )
        goto title
    )
) else if "!menumode3!"=="manage" (
    if "%ops%"=="%lastoption%" call:menuselect 0%la%goto title
    IF !Test2!==1 IF !Test1!==1 (
        set /A ops=%ops% + 1 - 1
        set selectedmanageslot=%ops%
        call:menuselect manageslot & goto title
    ) 
) else if "!menumode3!"=="import" (
    if "%ops%"=="%lastoption%" (
        call:menuselect manageslot
        goto title
    )
    IF !Test2!==1 IF !Test1!==1 (
        set /A ops=%ops% + 1 - 1
        set selectedimportsource=!menuslotselected%ops%!
        if "!selectedimportsource!"=="%activedsnum%" (
        echo Backup process started... 
        call:makebackup %activedsnum% %activedsnam%
        timeout 1 > NUL
        )
        call:menuselect 1 import & goto title
    ) 
) else if "!menumode3!"=="createnoback" (
    IF !Test2!==1 IF !Test1!==1  (
        set /A ops=%ops% + 1 - 1
        set selectedmanageslot=!menuslotselected%ops%!
        call:menuselect 2 createnoback & goto title
    ) 
)
color 0c%la%goto title
REM --------------------------------------------------------------------------------Manage Slot Operation Menu
:menumanageslot
set ops=0
call:detectbackups
call:detectactivedataslot
call:displayselectedslot %selectedmanageslot% %activedsnum%
echo   #        Choose the kind of operation you want to execute on data sets     #
if  "!selectedmanageslotname!"=="Empty" (
    echo   #              1--Create New DataSet       %g3%%g3%#
    echo   #              2--Import from a Backup     %g3%%g3%#
    echo   #              3--Go back to slot selection%g3%%g3%#
) else (
    echo   #              1--Rename   %g3%%g3%%g3%#
    if %selectedmanageslot% NEQ %activedsnum% (
        echo   #              2--Delete   %g3%%g3%%g3%#
        echo   #              3--Go back to slot selection%g3%%g3%#
    ) else (
        echo   #     [ACTIVE] X--Can't delete             %g3%%g3%#
        echo   #              2--Go back to slot selection%g3%%g3%#
    )
)
%minig2%%g3%%la%color 0F
set /p ops=Type the corresponding number of your choice then press ENTER:
set ops | FINDSTR /R /C:"[&""|()]">nul
IF NOT ERRORLEVEL 1 set ops=0 >nul
echo.
if  "!selectedmanageslotname!"=="Empty" (
    if "%ops%"=="1" call:menuselect 2 create & goto title
    if "%ops%"=="2" ( 
        set selectedimportdest=%selectedmanageslot%
        call:menuselect 3 import
        goto title
    )
    if "%ops%"=="3" call:menuselect 3 manage & goto title
) else (
    if "%ops%"=="1" call:menuselect 2 rename & goto title
    if NOT "!mathresult!"=="%activedsnum%" (
        if "%ops%"=="2" (
            set ops2=0
            echo WARNING: This will delete all backups of this slot.
            set /p ops2=Please confirm by spelling "DELETE", anything else cancels:
            set ops | FINDSTR /R /C:"[&""|()]">nul
            IF NOT ERRORLEVEL 1 set ops2=0 >nul
            echo.
            if "!ops2!"=="DELETE" (
                echo Deletion confirmed...
                rd /Q /S "%backuplocation%\dataslot%selectedmanageslot%"
                echo Done!
                timeout 1 > NUL
                call:menuselect 3 manage & goto title
            )
        )
        if "%ops%"=="3" call:menuselect 3 manage & goto title
    ) else (
        if "%ops%"=="2" call:menuselect 3 manage & goto title
    )
)
color 0c%la%goto title
REM --------------------------------------------------------------------------------PRELAUNCH
:prelaunch
color 0F
set "count1=timeout /t 1 /nobreak >nul"
set "backuplocation=%starboundpath%\backupstorage"
set chosenmenu=goto menu0
set "debug=0"
set defaultslotcount=4
set slotcount=!defaultslotcount!
title VSUB-Manipulator by Malhera/Vix
set g1=echo /%g5%--------------------------\
set g2=echo \%g5%--------------------------/
set g3=                
set g4=~~~~~~~~~~~~
set g5=----------------------------------------------------
set minig1=echo   /%g5%----------------------\
set minivg1=echo /%g5%------------------\
set minig2=echo   \%g5%----------------------/
set minivg2=echo \%g5%------------------/
set titlestartbar=echo #~~~~~~~~~~~~#%g5%#~~~~~~~~~~~~#
set titlestartbarmini=echo #~~~~~~~~#%g5%--------#~~~~~~~~#
set titleendbar=echo \~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/
set le=^& echo
set la=^& 
set "Errorflash=color 4c%la%%count1%%la%color 4F%la%%count1%%la%color 4c%la%%count1%%la%color 4F%la%%count1%%la%color 4c%la%%count1%%la%color 4F%la%%count1%%la%color 4c%la%%count1%%la%color 4F%la%%count1%%la%color 4c%la%%count1%%la%color 4F%la%%count1%%la%color 4c%la%%count1%%la%color 4F%la%%count1%%la%"
IF NOT EXIST "%starboundpath%" (
    goto nopath
)
REM ------------------------------------------------------Detect if active data is associated to a slot and check for name missmatch
if NOT exist "%starboundpath%\storage" mkdir "%starboundpath%\storage" 
if NOT exist "%starboundpath%\storage\set.bin" (
    call:menuselect 3 createnoback
    goto title
) else (
    call:detectactivedataslot
    call:detectbackups
    call:checknamingmissmatch
    if "!missmatchdetect!"=="1" (
        call:menuselect 3 createnoback
        goto title
    ) else (
        goto title
    )   
)
REM --------------------------------------------------------------------------------Path Error screen
:nopath
color 4F%la%%g1%%le% #----------Starbound doesn't seem to be installed at the default path----------#%le% #-------------You'll have to edit the first variable of the script-------------#%la%%g2%%la%%Errorflash%pause%la%goto end

:title
mode con: cols=81 lines=42
cls
echo /~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\%la%%titlestartbar%%le% #~~~~~~~~~~~~#  Vixen's Starbound Universe and Being Manipulator  #~~~~~~~~~~~~#%la%%titlestartbar%%la%%titleendbar%%la%%chosenmenu%
goto:EOF
REM --------------------------------------------------------------------------------FUNCTIONS
:menuselect
if "%~1"=="1" (
    if "%~2"=="import" (
        set "menumode%~1=import"
    ) else if "%~2"=="restore" (
        set "menumode%~1=restore"
    ) else (
        set "menumode%~1="
    )
) else if "%~1"=="2" (
    if "%~2"=="import" (
        set "menumode%~1=import"
    ) else if "%~2"=="create" (
        set "menumode%~1=create"
    ) else if "%~2"=="createnoback" (
        set "menumode%~1=createnoback"
    ) else if "%~2"=="rename" (
        set "menumode%~1=rename"
    ) else (
        set "menumode%~1="
    )
) else if "%~1"=="3" (
    if "%~2"=="switch" (
        set "menumode%~1=switch"
    ) else if "%~2"=="import" (
        set "menumode%~1=import"
    ) else if "%~2"=="createnoback" (
        set "menumode%~1=createnoback"
    ) else if "%~2"=="manage" (
        set "menumode%~1=manage"
    ) else (
        set "menumode%~1="
    )
)
set chosenmenu=goto menu%~1
goto:EOF
REM --------------------------------------------------------------------------------Check for name missmatch
:checknamingmissmatch
set missmatchdetect=0
set COUNT=0
FOR /L %%c IN (1,1,!slotcount!) DO (
    set /A COUNT=!COUNT! + 1
    if "!activedsnum!"=="%%c" (
        set trim=!dataslotname%%c!
        for /l %%a in (1,1,60) do if "!trim:~-1!"==" " set trim=!trim:~0,-1!
        set dataslot!COUNT!=1
        if "!dataslotname%%c!"=="Empty" (
            set "dataslotname!COUNT!=!activedsnam!"
        ) else if NOT "%activedsnam%"=="!trim!" (
            IF NOT exist "%backuplocation%\dataslot%%c\backup_????-??-??_??-??-??" (
                call:makebackup %activedsnum% %activedsnam%
            )
            set missmatchdetect=1
        )
    )
)
goto:EOF
REM --------------------------------------------------------------------------------Backup storage scrubber
:detectbackups
set lastfounddataslot=0
if NOT exist "%backuplocation%" (
    mkdir "%backuplocation%"
) else (
    if exist "%backuplocation%\dataslot*" (
        for /F "delims=" %%a in ('dir /ad /o-n /b "%backuplocation%\dataslot*"') do (
            set tempdataslot=%%a
            set /A dstrim=!tempdataslot:dataslot=! + 1 - 1
            REM IF !dstrim! GTR !lastfounddataslot!
            call:math !dstrim! !lastfounddataslot!
            if %debug%==1 ( echo IF !dstrim! GTR !lastfounddataslot! )
            if "!mathresult!"=="1" (
                set lastfounddataslot=!dstrim!
            ) 
        )
    )
)
if exist "%backuplocation%\dataslot*" (
    REM IF "%activedsnum%" GTR "!slotcount!"
    call:math %activedsnum% !slotcount!
      if %debug%==1 ( echo IF "%activedsnum%" GTR "!slotcount!" )
      IF !mathresult!==1 ( set /A slotcount=!activedsnum! + 1 )
    REM  IF "!lastfounddataslot!" LEQ "!slotcount!"
    call:math !lastfounddataslot! !slotcount!
    set "Test=" & IF "!mathresult!"=="-1" set Test=1
    IF "!mathresult!"=="0" set Test=1
    set "Test2=" & IF "!mathresult!"=="1" set Test2=1
    IF "!mathresult!"=="0" set Test2=1
    if %debug%==1 ( echo IF "!lastfounddataslot!" LEQ "!slotcount!" )
    IF !Test!==1 (
        set /A slotcount=!lastfounddataslot! + 1
        REM IF !slotcount! LEQ %defaultslotcount%
        call:math !slotcount! %defaultslotcount%
        set "Test3=" & IF "!mathresult!"=="-1" set Test3=1
        IF "!mathresult!"=="0" set Test3=1
        if %debug%==1 ( echo IF !slotcount! LEQ %defaultslotcount% )
        IF !Test3!==1 set slotcount=%defaultslotcount%
    REM else IF !lastfounddataslot! GEQ !slotcount!
    if %debug%==1 ( echo else IF !lastfounddataslot! GEQ !slotcount! )
    ) else if !Test2!==1 (
        set /A slotcount=!lastfounddataslot! + 1
    )
)
set COUNT=0
FOR /L %%c IN (1,1,!slotcount!) DO (
    set /A COUNT=!COUNT! + 1
    if NOT exist "%backuplocation%\dataslot%%c" (
        set dataslot!COUNT!=0
        set dataslotname!COUNT!=Empty
    ) else (
        if NOT exist "%backuplocation%\dataslot%%c\setname.bin" (
            set dataslot!COUNT!=0
            set dataslotname!COUNT!=Empty
        ) else (
            set dataslot!COUNT!=1
            call:readnamefromdataslot %%c
            set dataslotname!COUNT!=!currdataslotnam!
        )
    )
)
if %debug%==1 ( pause )
goto:EOF
REM --------------------------------------------------------------------------------dataslot display in Main Menu
REM --------------------------------------------------------------------------------displaydataslotinmenu :slot#: :dataslotname: :activedataslot#:
:displaydataslotinmenu
if %debug%==1 ( echo call:displaydataslotinmenu %1 %2 %3 )
set "spaces=%g3%%g3%%g3%"
call:math %~1 9
set "padding= "
set "hpadding= "
set "hdash=-"
if !mathresult!==1 (
set "padding="
call:math %~1 99
if !mathresult!==1 set "hpadding=" & set "hdash="
)
if "%~1"=="%activedsnum%" (
    set "slotline=  # [ACTIVE]-   !padding!%~3!hdash!-!hpadding!Slot!hpadding!%~1!padding!: %~2%spaces%"
    set "slotline=!slotline:~0,66! -[ACTIVE] #"
) else (
    set "slotline=  #             !padding!%~3!hdash!-!hpadding!Slot!hpadding!%~1!padding!: %~2%spaces%"
    set "slotline=!slotline:~0,76! #"
)
set menuslotselected%~3=%~1
echo !slotline!
goto:EOF
REM --------------------------------------------------------------------------------Detect active dataslot
:detectactivedataslot
set "var=1"
for /f "tokens=1,* delims=:" %%a in ('findstr /n "^" "%starboundpath%\storage\set.bin" ^|findstr "^%var%:"') do set activedsnum=%%b
set "var=2"
for /f "tokens=1,* delims=:" %%a in ('findstr /n "^" "%starboundpath%\storage\set.bin" ^|findstr "^%var%:"') do set activedsnam=%%b
if NOT exist "%backuplocation%\dataslot%activedsnum%" mkdir "%backuplocation%\dataslot%activedsnum%"
if NOT exist "%backuplocation%\dataslot%activedsnum%\setname.bin" (echo %activedsnam%)>"%backuplocation%\dataslot%activedsnum%\setname.bin"
goto:EOF
REM --------------------------------------------------------------------------------Readnamefromdataslot :slot#:
:readnamefromdataslot
if %debug%==1 ( echo call:readnamefromdataslot %1 )
set "var=1"
for /f "tokens=1,* delims=:" %%a in ('findstr /n "^" "%backuplocation%\dataslot%~1\setname.bin" ^|findstr "^%var%:"') do set trim=%%b
for /l %%a in (1,1,60) do if "!trim:~-1!"==" " set trim=!trim:~0,-1!
set currdataslotnam=!trim!
goto:EOF
REM --------------------------------------------------------------------------------Display active dataslot in head menu bar
:displayactivedataslot
if %debug%==1 ( echo call:displayactivedataslot %activedsnam% %activedsnum% )
set "spaces=---------------------------------------------------------------"
set "line=  /---{Active Data Slot :  %activedsnum% - %activedsnam%"
set "line=%line:~0,73%}%spaces%"
set "line=%line:~0,76%-\"
echo %line%
goto:EOF
REM --------------------------------------------------------------------------------Display selected slot in head menu bar and detect if empty
REM --------------------------------------------------------------------------------displayselectedslot :slot#: :activeslot#:
:displayselectedslot
if %debug%==1 ( echo call:displayselectedslot %1 %2 )
IF "%~1"=="0" (
    set %~1=X
    set dataslotnameX=ERROR : Don't proceed
)
set "spaces=---------------------------------------------------------------"
set "line=  /---{Selected Slot :  %~1 - !dataslotname%~1!"
IF  "!dataslotname%~1!"=="Empty" ( set emptyselectedslot=1 ) else ( set emptyselectedslot=0 )
IF "%~1"=="%~2" (
    set "line=%line:~0,66%}[ACTIVE]%spaces%"
) else (
    set "line=%line:~0,75%}%spaces%"
)
set "line=%line:~0,76%-\"
echo %line%
set selectedmanageslotname=!dataslotname%~1!
goto:EOF
REM --------------------------------------------------------------------------------makebackup :slot#: :name:
:makebackup
if %debug%==1 ( echo call:makebackup %1 %2 )
IF NOT exist "%backuplocation%\dataslot%~1" mkdir "%backuplocation%\dataslot%~1"
(echo %~2)> "%backuplocation%\dataslot%~1\setname.bin"
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "stamp=%YYYY%-%MM%-%DD%_%HH%-%Min%-%Sec%"
set "lastbackup_stamp=%HH%:%Min%:%Sec%" & set lastbackup_slot=%~1 & set lastbackup_name=%~2
mkdir "%backuplocation%\dataslot%~1\backup_%stamp%"
xcopy /s/e /V /H /K /Y /Q "%starboundpath%\storage\*" "%backuplocation%\dataslot%~1\backup_%stamp%\"
IF exist "%backuplocation%\dataslot%~1\backup_%stamp%\set.bin" del "%backuplocation%\dataslot%~1\backup_%stamp%\set.bin"
IF ErrorLevel 1 (
    set lastbackup=2
) else (
    set lastbackup=1
)
for /F "skip=%backups_to_keep% eol=| delims=" %%I in ('dir "%backuplocation%\dataslot%~1\backup_????-??-??_??-??-??" /AD /B /O-N 2^>nul') do rd /Q /S "%backuplocation%\dataslot%~1\%%I"
goto:EOF
REM --------------------------------------------------------------------------------restore :slot#: :backupname:
:restore
IF NOT exist "%backuplocation%\dataslot%~1" set lastrestore=3 & set lastrestoreerror="No backup folder for this slot!" & goto:EOF
IF NOT exist "%backuplocation%\dataslot%~1\%~2" set lastrestore=3 & set lastrestoreerror="This backup doesn't seem to exist!" & goto:EOF
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "stamp=%YYYY%-%MM%-%DD%_%HH%-%Min%-%Sec%"
set "lastrestore_stamp=%HH%:%Min%:%Sec%" & set lastrestore_slot=%~1 & set lastrestore_name=%~2
RD /Q /S "%starboundpath%\storage\" & mkdir "%starboundpath%\storage"
xcopy /s/e /V /H /K /Y /Q "%backuplocation%\dataslot%~1\%~2\*" "%starboundpath%\storage\"
IF ErrorLevel 1 (
    set lastrestore=2
) else (
    set lastrestore=1
)
(echo %~1)>"%starboundpath%\storage\set.bin"
(echo !dataslotname%~1!)>>"%starboundpath%\storage\set.bin"
goto:EOF
REM --------------------------------------------------------------------------------Math, because batch is doofus
REM --------------------------------------------------------------------------------call:math ### ###
REM --------------------------------------------------------------------------------returns -1 if first number smaller than second
REM --------------------------------------------------------------------------------returns 0 if equal
REM --------------------------------------------------------------------------------returns 1 if first number greater than second
:math
if %debug%==1 ( echo call:math %1 %2 )
call :compareFloats %1 %2
:compareFloats
set mathresult=
set n1=%1
set n2=%2
set int1=0
set int2=0
set dec1=0
set dec2=0
for /f "tokens=1,2 delims=." %%a in ("%n1%.0") do (
    set int1=%%a
    set dec1=%%b
)
for /f "tokens=1,2 delims=." %%a in ("%n2%.0") do (
    set int2=%%a
    set dec2=%%b
)
if !int1! EQU !int2! (
    if !dec1! EQU !dec2! (
        set "mathresult=0"
    ) else (
        if !dec1! LSS !dec2! (
            set "mathresult=-1"
        ) else (
            set "mathresult=1"
        )
    )
) else (
    if !int1! LSS !int2! (
        set "mathresult=-1"
    ) else (
        set "mathresult=1"
    )
)
goto:EOF
REM --------------------------------------------------------------------------------HELP
:help0
echo Help:
echo # Active Slot - Which dataset is actually active/used by Starbound
echo # Backup      - Make an new backup for your Active Slot.
echo # Restore     - Lets you list your backups for your Active slot, and restore 
echo #               from one.
echo # Switch      - Lets you switch your Active Slot, making an automatic backup for 
echo #               it before restoring an other slot as your Active Slot
echo # Manage      - Will let you overview all yours Slots
echo #           empty-   In an empty slot, you'll be able to create a new dataset or 
echo #                    import from and other slot.
echo #       non-empty-   In a non-empty slot, you'll be able to empty it (delete) or 
echo #                    change its label with the rename option.
goto:EOF
:exit
echo Exiting script ...
timeout /t 2 /nobreak >nul
goto :EOF
