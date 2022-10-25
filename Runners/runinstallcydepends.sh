#!/bin/bash

#Richard Deodutt
#10/23/2022
#This script is meant to run the script to install the Cypress dependencies

#Function to exit with a error code
exiterror(){
    #Log error
    echo "Something went wrong. exiting"
    #Exit with error
    exit 1
}

#Run as admin only check
admincheck(){
    #Check if the user has root, sudo or admin permissions
    if [ $UID != 0 ]; then
        #Send out a warning message
        echo "Run again with admin permissions"
        #Exit with a error message
        exiterror
    fi
}

#The main function
main(){
    #RDGOAT = Run Directory Gather Organize All Together
    cd RDGOAT > /dev/null 2>&1 || { mkdir RDGOAT && cd RDGOAT ; } ; curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-4/main/Scripts/installcydepends.sh && chmod +x installcydepends.sh && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-4/main/Scripts/libstandard.sh && chmod +x libstandard.sh && ./installcydepends.sh || exiterror
}

#Check for admin permissions
admincheck

#Call the main function
main

#Exit successs
exit 0