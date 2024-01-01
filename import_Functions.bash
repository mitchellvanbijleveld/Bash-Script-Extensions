#!/bin/bash

###########################################################################
# Function Import Script.                                                 #
# © 2024 Mitchell van Bijleveld - https://mitchellvanbijleveld.dev/.      #
# Last modified on 01 / 01 / 2024.                                        #
###########################################################################

###########################################################################
# Instructions.
###########################################################################
# You basically need to call this script with the functions you want to   #
# import and the script handles everything else. Read README.md for more  #
# information. Example usage: 'bash import_Functions.bash [functions]'.   #
###########################################################################

import_Functions() {

  SilentMode=false
  ##### In case the '--silent' flag is passed, replace the 'echo' function with printing nothing.
  if echo $@ | grep -q "\-\-silent"; then
    SilentMode=true
  fi

  set_FunctionString() {
    vTempFunction=$(cat "$TempDir/$FunctionX.bash" | grep "##### Version")
    # vTempFunction=$(echo $vTempFunction | sed 's/#//g')
    vTempFunction=$(printf "%s" "$vTempFunction" | tr -d '#')
    # vTempFunction=$(echo $vTempFunction | sed 's/Version//g')
    vTempFunction=$(printf "%s" "$vTempFunction" | tr -d 'Version')
    # vTempFunction=$(echo $vTempFunction | sed 's/ //g')
    vTempFunction=$(printf "%s" "$vTempFunction" | tr -d ' ')
  }

  ##### Log starting information.
  StringFunctions=$(echo $@ | sed 's/--silent//g')
  StringFunctions=$(echo $StringFunctions | sed 's/ /, /g')

  if [[ $SilentMode != true ]]; then
    echo "Mitchell van Bijleveld's Function Importer has been started..."
    echo "The following function(s) will be downloaded, checked on their sha256sum and imported to the script: $StringFunctions."
  fi

  ##### Function that updates the dynamic progress bar.
  UpdateProgressBar() {
    if [[ $SilentMode != true ]]; then
      for Percent in $(seq 1 $ProgressBarStepSize); do
        StringPercentage="$StringPercentage="
        Percentage=$(($Percentage + 1))
        # sleep "0.25"
      done
      MissingPercentage=$(($TerminalWidth - $TerminalSpareWhiteSpaces - $Percentage))
      StringPercentageCandy=$(awk "BEGIN {print $Percentage/$TerminalWidth}")
      # In case the dot is a comma, replace the comma with a dot.
      # StringPercentageCandy=$(echo "$StringPercentageCandy" | sed 's/,/./g')
      StringPercentageCandy=$(printf "%s" "$StringPercentageCandy" | tr ',' '.')

      StringPercentageCandy=$(awk "BEGIN {print $StringPercentageCandy * 100}")
      StringPercentageCandy=$(printf "%.0f\n" "$StringPercentageCandy")
      StringMissingPercentage=""
      if [[ $1 == "--finish-progressbar" ]]; then
        MissingPercentChar="="
        StringPercentageCandy=100
      else
        MissingPercentChar="."
        StringPercentageCandy=" $StringPercentageCandy"
      fi
      for MissingPercent in $(seq 1 $MissingPercentage); do
        StringMissingPercentage="$MissingPercentChar$StringMissingPercentage"
      done
      ProgressBar="[$StringPercentage$StringMissingPercentage] $StringPercentageCandy %%"

      printf "\r"
      printf "$ProgressBar"
      if [[ $1 == "--finish-progressbar" ]]; then
        printf "\n"
      fi

    else
      printf ""
    fi
  }

  ###########################################################################
  # Step 1 - Create a temporary directory to store the checksum files.      #
  ###########################################################################
  TempDir="/tmp/mitchellvanbijleveld/Bash-Script-Extensions"
  mkdir -p "$TempDir/"
  mkdir -p "$TempDir/.sha256sum"

  ##### Download new version info file.
  curl --output "$TempDir/.VERSION" "https://git.mitchellvanbijleveld.dev/Bash-Script-Extensions/VERSION" --silent
  source "$TempDir/.VERSION"

  if [[ $SilentMode != true ]]; then
    TerminalWidth=$(tput cols)
    TerminalSpareWhiteSpaces=9
    ProgressBarStepSize=$(($TerminalWidth - $TerminalSpareWhiteSpaces))
    ProgressBarStepSize=$(($ProgressBarStepSize / $#))
    ProgressBarStepSize=$(($ProgressBarStepSize / 6))
    Percentage=0
    ProcessedImports=0
  fi

  ###########################################################################
  # Step 2 - Download all functions, called by the script.                  #
  ###########################################################################
  for FunctionX in $@; do
    if [ $FunctionX == "--silent" ]; then
      continue
    fi

    ##### Get version of function from server version file
    eval vFunction=\$$FunctionX

    UpdateProgressBar

    # Download Files
    ##### If the file exists, compare the versions. If the file doesn't exist, download it. If the versions don't match, download new file.
    if [[ -e "$TempDir/$FunctionX.bash" ]]; then
      set_FunctionString
      if [[ $vFunction != $vTempFunction ]]; then
        curl --output "$TempDir/$FunctionX.bash" "https://git.mitchellvanbijleveld.dev/Bash-Script-Extensions/$FunctionX.bash" --silent &
        wait
        set_FunctionString
        if [[ $vFunction != $vTempFunction ]]; then
          UpdateProgressBar --finish-progressbar
          echo "Fatal error: version mismatch during import one of the functions."
          exit
        fi
      fi
    else
      curl --output "$TempDir/$FunctionX.bash" "https://git.mitchellvanbijleveld.dev/Bash-Script-Extensions/$FunctionX.bash" --silent &
      wait
      set_FunctionString
      if [[ $vFunction != $vTempFunction ]]; then
        UpdateProgressBar --finish-progressbar
        echo "Fatal error: version mismatch during import one of the functions."
        exit
      fi
    fi
    UpdateProgressBar

    curl --output "$TempDir/.sha256sum/$FunctionX.bash" "https://git.mitchellvanbijleveld.dev/Bash-Script-Extensions/sha256sum/$FunctionX.bash" --silent &
    UpdateProgressBar

    # Wait for the downloads to complete.
    wait

    # Get checksums
    expected_checksum=$(cat "$TempDir/.sha256sum/$FunctionX.bash")
    UpdateProgressBar
    actual_checksum=$(sha256sum "$TempDir/$FunctionX.bash" | awk '{print $1}')
    UpdateProgressBar

    # Compare checksum
    if [ "$expected_checksum" == "$actual_checksum" ]; then
      source "$TempDir/$FunctionX.bash"
    else
      ErrorDuringImport=true
      FailedImports="$FailedImports$TempDir/$FunctionX.bash "
    fi
    ProcessedImports=$(($ProcessedImports + 1))
    if [[ $ProcessedImports == $# ]]; then
      UpdateProgressBar --finish-progressbar
    else
      UpdateProgressBar
    fi
  done

  if [ $ErrorDuringImport ]; then
    echo "There was an error importing one or more functions, most likely due to a sha256sum mismatch."
    echo "You can, however, continue importing any other functions (if asked by the script) and run the script."
    echo "This can, however, be a serious security concern since I can't verify the integrity of the function that is being imported."
    echo
    NumberOfFailedImport=1
    for FailedImport in $FailedImports; do
      echo "$NumberOfFailedImport - $FailedImport"
      NumberOfFailedImport=$((NumberOfFailedImport + 1))
    done
    echo
    echo -n "Do you want to import and use the script(s) mentioned above? "
    read -p "If so, type 'Yes': " yn
    case $yn in
    Yes)
      echo "Well, I hope you know what you are doing."
      for FailedImport in $FailedImports; do
        echo "Importing file '$FailedImport'..."
        source $FailedImport
        sleep 0.5
      done
      ;;
    *)
      echo "Wise choice! The script will exit."
      echo
      exit 1
      ;;
    esac
  fi
}