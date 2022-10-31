#!/bin/bash

#Richard Deodutt
#10/31/2022
#This script is meant to execute a Jenkins build job on ubuntu

#Source or import standard.sh
source libstandard.sh

#Name of main target
Name='jenkins'

#Home directory
Home='.'

#Log file name
LogFileName="ExecuteJenkinsBuildJob.log"

#Set the log file location and name
setlogs

#Username
JENKINS_USERNAME=$(cat JENKINS_USERNAME)
#Password
JENKINS_PASSWORD=$(cat JENKINS_PASSWORD)

#JENKINS_JOB_NAME
JENKINS_JOB_NAME=$(cat JENKINS_JOB_NAME)

#Jenkins cli jar file name
JCJ="jenkins-cli.jar"

#The main function
main(){
    #Update local apt repo database
    aptupdatelog

    #Install jq if not already
    aptinstalllog "jq"

    #Install curl if not already
    aptinstalllog "curl"

    #Download jenkins-cli.ja if not already
    ls $JCJ > /dev/null 2>&1 && logokay "Successfully found $JCJ for ${Name}" || { curl -s "http://localhost:8080/jnlpJars/jenkins-cli.jar" -O -J && ls $JCJ > /dev/null 2>&1 && logokay "Successfully downloaded $JCJ for ${Name}" || { logerror "Failure obtaining $JCJ for ${Name}" && exiterror ; } ; }

    #Start the service if not already
    systemctl start jenkins > /dev/null 2>&1 && logokay "Successfully started ${Name}" || { logerror "Failure starting ${Name}" && exiterror ; }

    #Remote send the build job command
    java -jar $JCJ -s "http://localhost:8080" -http -auth $JENKINS_USERNAME:$JENKINS_PASSWORD build $JENKINS_JOB_NAME/main -s -v && logokay "Successfully executed build job for ${Name}" || { logerror "Failure executing build job for ${Name}" && exiterror ; }
}

#Log start
logokay "Running the execute ${Name} build job script"

#Check for admin permissions
admincheck

#Call the main function
main

#Log successs
logokay "Ran the execute ${Name} build job script successfully"

#Exit successs
exit 0