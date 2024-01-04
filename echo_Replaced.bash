###########################################################################
# Custom 'echo' function that writes in a verbose logging style.          #
# Mitchell van Bijleveld - (https://mitchellvanbijleveld.dev/             #
# © 2023 Mitchell van Bijleveld. 01 / 11 / 2023                           #
##### Version 24.01.05-0057                                               #
###########################################################################

###########################################################################
# Instructions.
###########################################################################
# It's as simple as putting 'echo_Verbose [TEXT]' instead of echo.        #
# In case you want to use this function only when a --verbose flag is     #
# passed, build a function that sets an argument called                   #
# 'ArgumentVerboseLogging' in your script (and set it to 'true'. If you   #
# set the ScriptOption_LogStyle to 'Verbose' in your script, the verbose  #
# logging will be used.                                                   #
###########################################################################
ScriptLogFileTimeStamp=$(date +"D%Y%m%dT%H%M")
ScriptLogFileName="$FolderPath_Logs/$Internal_ScriptName-$ScriptLogFileTimeStamp.log"
#ScriptLogFileName="TestingLogWriting $(date +"%Y%m%d %H%M%S").txt"
###########################################################################

echo "Logs will be written to '$ScriptLogFileName'..."

if [[ ! -e "$ScriptLogFileName" ]]; then
    mkdir -p "$FolderPath_Logs"
    printf "$(date +"%Y-%m-%d %H:%M:%S") [DEBUG] : The execution of '$ScriptName' has been started. \n" >>$ScriptLogFileName
fi

write_LogFile() {
    if [[ $PrintedMessage != "" && $DoNotLog != true ]]; then
        printf "$(date +"%Y-%m-%d %H:%M:%S") [DEBUG] : $PrintedMessage \n" >>$ScriptLogFileName
    fi
}

CheckFlagsAndSetMessageString() {
    DoNotLog=false
    NewLine=true
    PrintedMessage="$@"
    case "$1" in
    "-n")
        NewLine=false
        PrintedMessage="$2"
        ;;
    "-e")
        PrintedMessage="$2"
        ;;
    esac
    case $3 in
    "--do-not-log")
        DoNotLog=true
        ;;
    esac
    write_LogFile $PrintedMessage
}

print_LogMessage() {
    printf "$(date +"%Y-%m-%d %H:%M:%S") [DEBUG] : $PrintedMessage"
    if [[ $NewLine == true ]]; then
        printf "\n"
    fi
}

print_Message() {
    printf "$PrintedMessage"
    if [[ $NewLine == true ]]; then
        printf "\n"
    fi
}

echo() {
    if [[ $@ != "" ]]; then
        CheckFlagsAndSetMessageString "$@"
        if [[ $ScriptOption_LogStyle == "Verbose" ]]; then
            print_LogMessage "$PrintedMessage"
        else
            print_Message "$PrintedMessage"
        fi
    else
        printf "\n"
    fi
}

echo_Verbose() {
    if [[ $@ != "" ]]; then
        CheckFlagsAndSetMessageString "$@"
        if [[ $ScriptOption_LogLevel == "Verbose" ]]; then
            if [[ $ScriptOption_LogStyle == "Verbose" ]]; then
                print_LogMessage "$PrintedMessage"
            else
                print_Message "$PrintedMessage"
            fi
        fi
    else
        printf "\n"
    fi
}