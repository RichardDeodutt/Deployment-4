#!/bin/bash

#Richard Deodutt
#10/29/2022
#This script is meant to install python3-venv on ubuntu

#Source or import standard.sh
source libstandard.sh

#Name of main target
Name='python3-venv'

#Home directory
Home='.'

#Log file name
LogFileName="InstallVenv.log"

#Set the log file location and name
setlogs

#The main function
main(){

    #Update local apt repo database
    aptupdatelog

    #Install python3-pip if not already
    aptinstalllog "python3-pip"

    #Install python3-venv if not already
    aptinstalllog "python3-venv"
}

#Log start
logokay "Running the install ${Name} script"

#Check for admin permissions
admincheck

#Call the main function
main

#Log successs
logokay "Ran the install ${Name} script successfully"

#Exit successs
exit 0