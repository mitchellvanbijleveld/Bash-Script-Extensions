###########################################################################
# Print information about a script                                        #
# Mitchell van Bijleveld - (https://mitchellvanbijleveld.dev/             #
# © 2023 Mitchell van Bijleveld. 01 / 01 / 2023                           #
##### Version 23.04.28                                                    #
###########################################################################

###########################################################################
# Instructions.
###########################################################################
# Please set the following variables in the script you want to use:       #
# ScriptName             : Name of the script you use                     #
# ScriptDescription      : Description of the script with a brief         #
#                          explaination of what the script does.          #
# ScriptDeveloper        : Name of the developer                          #
# ScriptDeveloperWebsite : Website of the developer                       #
# Script_Version          : Version of your script                        #
# ScriptCopyright        : Year of copyright                              # 
###########################################################################

print_ScriptInfo () {
  echo "$ScriptName"
  echo "$ScriptDescription"
  echo
  echo "Script Developer  : $ScriptDeveloper"
  echo "Developer Website : $ScriptDeveloperWebsite"
  echo
  echo "Version $Script_Version - $ScriptCopyright $ScriptDeveloper"
  echo
}