#!/bin/bash

#Richard Deodutt
#09/26/2022
#This script is meant to do a status check of the system after the deployment.

#Source or import standard.sh
source libstandard.sh

#Name of main target
Name='status check'

#Home directory
Home='/home'

#Log file name
LogFileName="StatusCheck.log"

#Set the log file location and name
setlogs

#The main function
main(){
    #Install Screenfetch if not already
    aptinstalllog "screenfetch"
    #Log Java Status
    java -version > /dev/null 2>&1 && log "$(echo "Java Version" ; java -version 2>&1 | cat )" || logwarning "Can't Check the version of Java"
    #Log Jenkins Status
    systemctl status jenkins --no-pager > /dev/null 2>&1 && log "$(echo "Jenkins Status" ; systemctl status jenkins --no-pager)" || logwarning "Can't Check the Status of Jenkins"
    #Log Nginx Status
    systemctl status nginx --no-pager > /dev/null 2>&1 && log "$(echo "Nginx Status" ; systemctl status nginx --no-pager)" || logwarning "Can't Check the Status of Nginx"
    #Log the node version
    log "$(echo "The Node Version")"
    npm --version > /dev/null 2>&1 && logokay "$(node --version)" || logwarning "Can't Check the version of Node"
    #Log the npm version
    log "$(echo "The NPM Version")"
    npm --version > /dev/null 2>&1 && logokay "$(npm --version)" || logwarning "Can't Check the version of NPM"
    #Log the terraform version
    log "$(echo "The Terraform Version")"
    terraform --version > /dev/null 2>&1 && logokay "$(terraform --version)" || logwarning "Can't Check the version of Terraform"
    #Log Screenfetch
    log "$(echo "Screenfetch" ; screenfetch)"
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