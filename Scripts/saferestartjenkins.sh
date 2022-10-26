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

#List of pending jobs
PendingJobs="Some Jobs"

#Start Time of waitinf or plugins to install
StartEpoch="Unset"

#Timeout in seconds, 10 minutes
Timeout=600

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

    #Set the start time of waiting
    StartEpoch=$(date +%s)

    #Wait until all jobs are completed
    while [ -z "$PendingJobs" ]; do

    #Remote check the updateCenter jobs, refresh jobs and store to file
    curl -s -g -b JenkinsSessionCookie -X GET "http://localhost:8080/updateCenter/api/json?tree=jobs[*]" -H "Jenkins-Crumb: $(cat JenkinsLastCrumb)" --user $JENKINS_USERNAME:$JENKINS_PASSWORD | jq -r '. | .jobs | .[].status._class? // empty' | sed 's/hudson.model.UpdateCenter$DownloadJob$SuccessButRequiresRestart//g' | sed 's/hudson.model.UpdateCenter$DownloadJob$Success//g' | sed '/^$/d' > JenkinsExecution && logokay "Successfully checked jobs for ${Name}" || { logerror "Failure checking jobs for ${Name}" && cat JenkinsExecution && rm JenkinsExecution && exiterror ; }

    #Store the pending jobs as a variable and refresh it
    PendingJobs=$(cat JenkinsExecution)

    #Tell the user how many jobs are left
    logerror "$(echo "$PendingJobs" | wc -l) Jobs Left"

    #Check if we timed out
    if [ $(date +%s) -ge $(echo "$StartEpoch + $Timeout" | bc) ]; then

        #Exit if it times out
        logerror "Timedout waitig for all jobs for ${Name}" && cat JenkinsExecution && rm JenkinsExecution && exiterror ;

    fi

    done

    #Remote do a safe restart
    curl -s -g -b JenkinsSessionCookie -X GET "http://localhost:8080/safeRestart " -H "Jenkins-Crumb: $(cat JenkinsLastCrumb)" --user $JENKINS_USERNAME:$JENKINS_PASSWORD > JenkinsExecution && test $(cat JenkinsExecution | wc -c) -eq 0 && logokay "Successfully executed safe restart for ${Name}" || { logerror "Failure executing safe restart for ${Name}" && cat JenkinsExecution && rm JenkinsExecution && exiterror ; }
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