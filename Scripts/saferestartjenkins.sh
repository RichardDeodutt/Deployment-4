#!/bin/bash

#Richard Deodutt
#10/25/2022
#This script is meant to safe restart Jenkins on ubuntu

#Source or import standard.sh
source libstandard.sh

#Name of main target
Name='jenkins'

#Home directory
Home='.'

#Log file name
LogFileName="SafeRestartJenkins.log"

#Set the log file location and name
setlogs

#Username
JENKINS_USERNAME=$(cat JENKINS_USERNAME)
#Password
JENKINS_PASSWORD=$(cat JENKINS_PASSWORD)

#The main function
main(){
    #Update local apt repo database
    aptupdatelog

    #Install jq if not already
    aptinstalllog "jq"

    #Install curl if not already
    aptinstalllog "curl"

    #Start the service if not already
    systemctl start jenkins > /dev/null 2>&1 && logokay "Successfully started ${Name}" || { logerror "Failure starting ${Name}" && exiterror ; }

    #Get a Jenkins crumb and a session cookie
    curl -s -c JenkinsSessionCookie -X GET "http://localhost:8080/crumbIssuer/api/json" --user $JENKINS_USERNAME:$JENKINS_PASSWORD | jq -r .crumb > JenkinsLastCrumb && logokay "Successfully obtained a crumb and a session cookie for ${Name}" || { logerror "Failure obtaining crumb and a session cookie for ${Name}" && exiterror ; }

    #Remote check the updateCenter jobs
    curl -s -g -b JenkinsSessionCookie -X GET "http://localhost:8080/updateCenter/api/json?tree=jobs[*]" -H "Jenkins-Crumb: $(cat JenkinsLastCrumb)" --user $JENKINS_USERNAME:$JENKINS_PASSWORD | jq -r . tee JenkinsExecution && test $(cat JenkinsExecution | wc -c) -eq 0 && logokay "Successfully executed configure groovy script for ${Name}" || { logerror "Failure executing configure groovy script for ${Name}" && cat JenkinsExecution && rm JenkinsExecution && exiterror ; }
}

#Log start
logokay "Running the safe restart ${Name} script"

#Check for admin permissions
admincheck

#Call the main function
main

#Log successs
logokay "Ran the safe restart ${Name} script successfully"

#Exit successs
exit 0