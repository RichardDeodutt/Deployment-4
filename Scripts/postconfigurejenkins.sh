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

#The configuration for Jenkins cred
ConfigCredJenkins="https://raw.githubusercontent.com/RichardDeodutt/Deployment-4/main/Configs/credential-cred-jenkins-default.xml"

#The configuration for Jenkins job
ConfigJobJenkins="https://raw.githubusercontent.com/RichardDeodutt/Deployment-4/main/Configs/job-build-jenkins-default.xml"

#The filename of the secret configuration file for Jenkins
ConfigSecretJenkinsFileName="credential-secret-jenkins-default.xml"

#The filename of the cred configuration file for Jenkins
ConfigCredJenkinsFileName="credential-cred-jenkins-default.xml"

#The filename of the job configuration file for Jenkins
ConfigJobJenkinsFileName="job-build-jenkins-default.xml"

#Username
JENKINS_USERNAME=$(cat JENKINS_USERNAME)
#Password
JENKINS_PASSWORD=$(cat JENKINS_PASSWORD)

#Formatted AWS_ACCESS_KEY_ID
AWS_ACCESS_KEY_ID=$(cat AWS_ACCESS_KEY_ID | sed 's/^/"/;s/$/"/')
#Id AWS_ACCESS_KEY_ID
Id_AWS_ACCESS_KEY_ID="AWS_ACCESS_KEY_ID"
#Description AWS_ACCESS_KEY_ID
Description_AWS_ACCESS_KEY_ID="AWS_ACCESS_KEY_ID"

#Formatted AWS_SECRET_ACCESS_KEY
AWS_SECRET_ACCESS_KEY=$(cat AWS_SECRET_ACCESS_KEY | sed 's/^/"/;s/$/"/')
#Id AWS_SECRET_ACCESS_KEY
Id_AWS_SECRET_ACCESS_KEY="AWS_SECRET_ACCESS_KEY"
#Description AWS_SECRET_ACCESS_KEY
Description_AWS_SECRET_ACCESS_KEY="AWS_SECRET_ACCESS_KEY"

#Formatted GITHUB_USERNAME
USER_GITHUB_USERNAME=$(cat USER_GITHUB_USERNAME | sed 's/^/"/;s/$/"/')
#Formatted GITHUB_TOKEN
USER_GITHUB_TOKEN=$(cat USER_GITHUB_USERNAME | sed 's/^/"/;s/$/"/')
#Id GITHUB_CRED
Id_GITHUB_CRED="GITHUB_CRED"
#Description GITHUB_CRED
Description_GITHUB_CRED="GITHUB_CRED"

#JENKINS_JOB_NAME
JENKINS_JOB_NAME=$(cat JENKINS_JOB_NAME)
#JENKINS_GITHUB_REPO_URL
JENKINS_GITHUB_REPO_URL=$(cat JENKINS_GITHUB_REPO_URL)
#JENKINS_GITHUB_REPO_OWNER
JENKINS_GITHUB_REPO_OWNER=$(echo $JENKINS_GITHUB_REPO_URL | cut -d "/" -f4)
#JENKINS_GITHUB_REPO_NAME
JENKINS_GITHUB_REPO_NAME=$(echo $JENKINS_GITHUB_REPO_URL | cut -d "/" -f5 | sed 's/.git//')

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
    LoadedInitialConfigJenkins=$(cat $ConfigSecretJenkinsFileName) && logokay "Successfully loaded secret configure file for ${Name}" || { logerror "Failure loading secret configure file for ${Name}" && exiterror ; }

    #Set the ID, Description and secret for the secret configure file placeholders for AWS_ACCESS_KEY_ID
    echo "$LoadedInitialConfigJenkins" | sed "s/~Id~/$Id_AWS_ACCESS_KEY_ID/g" | sed "s/~Description~/$Description_AWS_ACCESS_KEY_ID/g" | sed "s,~Secret~,$AWS_ACCESS_KEY_ID,g" > $ConfigSecretJenkinsFileName && logokay "Successfully set secret configure file for ${Name} AWS_ACCESS_KEY_ID" || { logerror "Failure setting secret configure file for ${Name} AWS_ACCESS_KEY_ID" && exiterror ; }

    #Remote send the secret config AWS_ACCESS_KEY_ID
    java -jar $JCJ -s "http://localhost:8080" -http -auth $JENKINS_USERNAME:$JENKINS_PASSWORD create-credentials-by-xml system::system::jenkins _ < $ConfigSecretJenkinsFileName > JenkinsExecution 2>&1 && logokay "Successfully executed send secret config for ${Name} AWS_ACCESS_KEY_ID" || { test $? -eq 1 && logwarning "Secret config for ${Name} AWS_ACCESS_KEY_ID already exists nothing changed" || { logerror "Failure executing send secret config for ${Name} AWS_ACCESS_KEY_ID" && cat JenkinsExecution && rm JenkinsExecution && exiterror ; } ; }

    #Get the Jenkins secret configure file
    curl -s -X GET $ConfigSecretJenkins -O && logokay "Successfully obtained secret configure file for ${Name}" || { logerror "Failure obtaining secret configure file for ${Name}" && exiterror ; }

    #Load the initial configuration for Jenkins
    LoadedInitialConfigJenkins=$(cat $ConfigSecretJenkinsFileName) && logokay "Successfully loaded secret configure file for ${Name}" || { logerror "Failure loading secret configure file for ${Name}" && exiterror ; }

    #Set the ID, Description and secret for the secret configure file placeholders for AWS_SECRET_ACCESS_KEY
    echo "$LoadedInitialConfigJenkins" | sed "s/~Id~/$Id_AWS_SECRET_ACCESS_KEY/g" | sed "s/~Description~/$Description_AWS_SECRET_ACCESS_KEY/g" | sed "s,~Secret~,$AWS_SECRET_ACCESS_KEY,g" > $ConfigSecretJenkinsFileName && logokay "Successfully set secret configure file for ${Name} AWS_SECRET_ACCESS_KEY" || { logerror "Failure setting secret configure file for ${Name} AWS_SECRET_ACCESS_KEY" && exiterror ; }

    #Remote send the secret config AWS_SECRET_ACCESS_KEY
    java -jar $JCJ -s "http://localhost:8080" -http -auth $JENKINS_USERNAME:$JENKINS_PASSWORD create-credentials-by-xml system::system::jenkins _ < $ConfigSecretJenkinsFileName > JenkinsExecution 2>&1 && logokay "Successfully executed send secret config for ${Name} AWS_SECRET_ACCESS_KEY" || { test $? -eq 1 && logwarning "Secret config for ${Name} AWS_SECRET_ACCESS_KEY already exists nothing changed" || { logerror "Failure executing send secret config for ${Name} AWS_SECRET_ACCESS_KEY" && cat JenkinsExecution && rm JenkinsExecution && exiterror ; } ; }

    #Remove secret configure file
    rm $ConfigSecretJenkinsFileName && logokay "Successfully removed secret configure file for ${Name}" || { logerror "Failure removing secret configure file for ${Name}" && exiterror ; }

    #Get the Jenkins cred configure file
    curl -s -X GET $ConfigCredJenkins -O && logokay "Successfully obtained cred configure file for ${Name}" || { logerror "Failure obtaining cred configure file for ${Name}" && exiterror ; }

    #Load the initial configuration for Jenkins
    LoadedInitialConfigJenkins=$(cat $ConfigCredJenkinsFileName) && logokay "Successfully loaded cred configure file for ${Name}" || { logerror "Failure loading cred configure file for ${Name}" && exiterror ; }

    #Set the ID, Description, Username and Password for the cred configure file placeholders for GITHUB_CRED
    echo "$LoadedInitialConfigJenkins" | sed "s/~Id~/$Id_GITHUB_CRED/g" | sed "s/~Description~/$Description_GITHUB_CRED/g" | sed "s,~Username~,$USER_GITHUB_USERNAME,g" | sed "s,~Password~,$USER_GITHUB_TOKEN,g" > $ConfigCredJenkinsFileName && logokay "Successfully set cred configure file for ${Name} GITHUB_CRED" || { logerror "Failure setting cred configure file for ${Name} GITHUB_CRED" && exiterror ; }

    #Remote send the cred config GITHUB_CRED
    java -jar $JCJ -s "http://localhost:8080" -http -auth $JENKINS_USERNAME:$JENKINS_PASSWORD create-credentials-by-xml system::system::jenkins _ < $ConfigCredJenkinsFileName > JenkinsExecution 2>&1 && logokay "Successfully executed send cred config for ${Name} GITHUB_CRED" || { test $? -eq 1 && logwarning "Cred config for ${Name} GITHUB_CRED already exists nothing changed" || { logerror "Failure executing send cred config for ${Name} GITHUB_CRED" && cat JenkinsExecution && rm JenkinsExecution && exiterror ; } ; }

    #Remove cred configure file
    rm $ConfigCredJenkinsFileName && logokay "Successfully removed cred configure file for ${Name}" || { logerror "Failure removing cred configure file for ${Name}" && exiterror ; }

    #Get the Jenkins job configure file
    curl -s -X GET $ConfigJobJenkins -O && logokay "Successfully obtained job configure file for ${Name}" || { logerror "Failure obtaining job configure file for ${Name}" && exiterror ; }

    #Load the initial configuration for Jenkins
    LoadedInitialConfigJenkins=$(cat $ConfigJobJenkinsFileName) && logokay "Successfully loaded job configure file for ${Name}" || { logerror "Failure loading job configure file for ${Name}" && exiterror ; }

    #Set the RepoOwner, RepoName and RepoURL for the job configure file placeholders
    echo "$LoadedInitialConfigJenkins" | sed "s/~RepoOwner~/$JENKINS_GITHUB_REPO_OWNER/g" | sed "s/~RepoName~/$JENKINS_GITHUB_REPO_NAME/g" | sed "s/~RepoURL~/$JENKINS_GITHUB_REPO_URL/g" > $ConfigJobJenkinsFileName && logokay "Successfully set job configure file for ${Name}" || { logerror "Failure setting job configure file for ${Name}" && exiterror ; }

    #Remote send the job config
    java -jar $JCJ -s "http://localhost:8080" -http -auth $JENKINS_USERNAME:$JENKINS_PASSWORD create-job $JENKINS_JOB_NAME < $ConfigJobJenkinsFileName > JenkinsExecution 2>&1 && logokay "Successfully executed send job config for ${Name}" || { test $? -eq 1 && logwarning "Job config for ${Name} already exists nothing changed" || { logerror "Failure executing send job config for ${Name}" && cat JenkinsExecution && rm JenkinsExecution && exiterror ; } ; }

    #Remove job configure file
    rm $ConfigJobJenkinsFileName && logokay "Successfully removed job configure file for ${Name}" || { logerror "Failure removing job configure file for ${Name}" && exiterror ; }
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