#!/bin/bash

#Richard Deodutt
#10/26/2022
#This script is meant to upgrade the packages of the system.

#Source or import standard.sh
source libstandard.sh

#Name of main target
Name='system upgrade'

#Home directory
Home='.'

#Log file name
LogFileName="SystemUpgrade.log"

#Set the log file location and name
setlogs

#The main function
main(){
    #Update local apt repo database
    aptupdatelog

    #Upgrade the system
    apt-get upgrade > /dev/null 2>&1 && logokay "Successfully finished ${Name}" || { logerror "Failure finishing ${Name}" && exiterror ; }

    #Remove unneeded packages
    apt-get autoremove > /dev/null 2>&1 && logokay "Successfully cleaned up the ${Name}" || { logerror "Failure cleaning up the ${Name}" && exiterror ; }
}

#Log start
logokay "Running the ${Name} script"

#Check for admin permissions
admincheck

#Call the main function
main

#Log successs
logokay "Ran the ${Name} script successfully"

#Exit successs
exit 0