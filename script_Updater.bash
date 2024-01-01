###########################################################################
# Script Updater for bash scripts on Linux/MacOS.                         #
# Mitchell van Bijleveld - (https://mitchellvanbijleveld.dev/             #
# © 2023 Mitchell van Bijleveld. Last edited on 28 / 04 / 2023.           #
##### Version 23.04.28                                                    #
###########################################################################

###########################################################################
# Instructions.
###########################################################################
# Please set the following variables in the script you want to use:       #
# URL_VERSION         : Location (URL) of the file where the version      #
#                       info is stored.                                   #
# URL_SCRIPT          : URL where the newer version of the script can     #
#                       be found                                          #
###########################################################################

Check_Script_Update () {
  echo "Mitchell van Bijleveld's Script Updater has been started..."
  echo "Checking for script updates..."
  Online_ScriptVersion=$(curl "$URL_VERSION" --silent)

  if [[ $Script_Version < $Online_ScriptVersion ]]; then
    ScriptPath=$(realpath $0)
    echo -e "\x1B[1;33mScript not up to date ($Script_Version)! \x1B[1;32mDownloading newest version ($Online_ScriptVersion)...\x1B[0m\n"
    curl --output "$ScriptPath" "$URL_SCRIPT" --progress-bar
    echo
    if [[ $@ == "" ]]; then
      echo "Restarting Script from '$ScriptPath' in 5 seconds..."
    else
      echo "Restarting Script from '$ScriptPath' with arguments '$@' in 5 seconds..."
    fi
    sleep 5
    /usr/bin/bash $ScriptPath $@
    exit
  elif [[ $Script_Version > $Online_ScriptVersion ]]; then
    echo -e "\x1B[1;33mYour version of the script ($Script_Version) is newer than the server version ($Online_ScriptVersion).\x1B[0m\n"
  else
    echo -e "\x1B[1;32mScript is up to date (Version $Script_Version).\x1B[0m"
    echo
  fi
}