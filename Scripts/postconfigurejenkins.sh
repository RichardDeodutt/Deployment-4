#!/bin/bash

#Richard Deodutt
#10/24/2022
#This script is meant to post configure Jenkins on ubuntu

#Source or import standard.sh
source libstandard.sh

#Name of main target
Name='jenkins'

#Home directory
Home='.'

#Log file name
LogFileName="PostConfigureJenkins.log"

#Set the log file location and name
setlogs

#The configuration for Jenkins secret
ConfigSecretJenkins="https://raw.githubusercontent.com/RichardDeodutt/Deployment-4/main/Configs/credential-secret-jenkins-default.xml"

#The filename of the secret configuration file for Jenkins
ConfigSecretJenkinsFileName="credential-secret-jenkins-default.xml"

#Username
JENKINS_USERNAME=$(cat JENKINS_USERNAME)
#Password
JENKINS_PASSWORD=$(cat JENKINS_PASSWORD)

#Formatted AWS_ACCESS_KEY_ID
AWS_ACCESS_KEY_ID=$(cat AWS_ACCESS_KEY_ID | sed 's/^/"/;s/$/"/')
#Formatted Id AWS_ACCESS_KEY_ID
Id_AWS_ACCESS_KEY_ID="AWS_ACCESS_KEY_ID"
#Formatted Description AWS_ACCESS_KEY_ID
Description_AWS_ACCESS_KEY_ID="AWS_ACCESS_KEY_ID"

#Formatted AWS_SECRET_ACCESS_KEY
AWS_SECRET_ACCESS_KEY=$(cat AWS_SECRET_ACCESS_KEY | sed 's/^/"/;s/$/"/')
#Formatted Id AWS_SECRET_ACCESS_KEY
Id_AWS_SECRET_ACCESS_KEY="AWS_SECRET_ACCESS_KEY"
#Formatted Description AWS_SECRET_ACCESS_KEY
Description_AWS_SECRET_ACCESS_KEY="AWS_SECRET_ACCESS_KEY"

#Store the initial secret config for Jenkins here
LoadedInitialConfigJenkins=""

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

    #Get the Jenkins secret configure file
    curl -s -X GET $ConfigSecretJenkins -O && logokay "Successfully obtained secret configure file for ${Name}" || { logerror "Failure obtaining secret configure file for ${Name}" && exiterror ; }

    #Load the initial configuration for Jenkins
    LoadedInitialConfigJenkins=$(cat $ConfigSecretJenkinsFileName)

    #Set the ID, Description and secret for the secret configure file placeholders for AWS_ACCESS_KEY_ID
    echo "$LoadedInitialConfigJenkins" | sed "s/~Id~/$Id_AWS_ACCESS_KEY_ID/g" | sed "s/~Description~/$Description_AWS_ACCESS_KEY_ID/g" | sed "s/~Secret~/$AWS_ACCESS_KEY_ID/g" > $ConfigSecretJenkinsFileName && logokay "Successfully set secret configure file for ${Name} AWS_ACCESS_KEY_ID" || { logerror "Failure setting secret configure file for ${Name} AWS_ACCESS_KEY_ID" && exiterror ; }

    #Remote send the secret config AWS_ACCESS_KEY_ID
    java -jar $JCJ -s "http://localhost:8080" -http -auth $JENKINS_USERNAME:$JENKINS_PASSWORD create-credentials-by-xml system::system::jenkins _ < $ConfigSecretJenkinsFileName && logokay "Successfully executed send secret config for ${Name} AWS_ACCESS_KEY_ID" || { logerror "Failure executing send secret config for ${Name} AWS_ACCESS_KEY_ID" && exiterror ; }

    #Get the Jenkins secret configure file
    curl -s -X GET $ConfigSecretJenkins -O && logokay "Successfully obtained secret configure file for ${Name}" || { logerror "Failure obtaining secret configure file for ${Name}" && exiterror ; }

    #Load the initial configuration for Jenkins
    LoadedInitialConfigJenkins=$(cat $ConfigSecretJenkinsFileName)

    #Set the ID, Description and secret for the secret configure file placeholders for AWS_SECRET_ACCESS_KEY
    echo "$LoadedInitialConfigJenkins" | sed "s/~Id~/$Id_AWS_SECRET_ACCESS_KEY/g" | sed "s/~Description~/$Description_AWS_SECRET_ACCESS_KEY/g" | sed "s/~Secret~/$AWS_SECRET_ACCESS_KEY/g" > $ConfigSecretJenkinsFileName && logokay "Successfully set secret configure file for ${Name} AWS_SECRET_ACCESS_KEY" || { logerror "Failure setting secret configure file for ${Name} AWS_SECRET_ACCESS_KEY" && exiterror ; }

    #Remote send the secret config AWS_SECRET_ACCESS_KEY
    java -jar $JCJ -s "http://localhost:8080" -http -auth $JENKINS_USERNAME:$JENKINS_PASSWORD create-credentials-by-xml system::system::jenkins _ < $ConfigSecretJenkinsFileName && logokay "Successfully executed send secret config for ${Name} AWS_SECRET_ACCESS_KEY" || { logerror "Failure executing send secret config for ${Name} AWS_SECRET_ACCESS_KEY" && exiterror ; }

    #Remove secret configure file
    rm $ConfigSecretJenkinsFileName && logokay "Successfully removed secret configure file for ${Name}" || { logerror "Failure removing secret configure file for ${Name}" && exiterror ; }
}

#Log start
logokay "Running the post configure ${Name} script"

#Check for admin permissions
admincheck

#Call the main function
main

#Log successs
logokay "Ran the post configure ${Name} script successfully"

#Exit successs
exit 0