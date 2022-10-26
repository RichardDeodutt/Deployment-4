#!/bin/bash

#Richard Deodutt
#10/24/2022
#This script is meant to configure Jenkins on ubuntu

#Source or import standard.sh
source libstandard.sh

#Name of main target
Name='jenkins'

#Home directory
Home='.'

#Log file name
LogFileName="ConfigureJenkins.log"

#Set the log file location and name
setlogs

#The configuration for Jenkins
ConfigJenkins="https://raw.githubusercontent.com/RichardDeodutt/Deployment-4/main/Configs/jenkins-configure.groovy"

#The filename of the configuration file for Jenkins
ConfigJenkinsFileName="jenkins-configure.groovy"

#The list of recommended plugins
RecommendedPluginsList="https://raw.githubusercontent.com/jenkinsci/jenkins/master/core/src/main/resources/jenkins/install/platform-plugins.json"

#Jenkins Original Password Location
InitialAdminPasswordLocation="/var/lib/jenkins/secrets/initialAdminPassword"
#Jenkins Original Password
InitialAdminPassword=$(cat $InitialAdminPasswordLocation)
#Formatted Username
JENKINS_USERNAME=$(cat JENKINS_USERNAME | sed 's/^/"/;s/$/"/')
#Formatted Password
JENKINS_PASSWORD=$(cat JENKINS_PASSWORD | sed 's/^/"/;s/$/"/')
#Formatted Email
JENKINS_EMAIL=$( printf "%s %s\n" $(cat JENKINS_USERNAME) $(cat JENKINS_EMAIL | sed 's/^/</;s/$/>/') | sed 's/^/"/;s/$/"/')
#Formatted IP
JENKINS_IP=$(echo "http://$(cat JENKINS_IP)/" | sed 's/^/"/;s/$/"/')
#Store the initial config for Jenkins here
LoadedInitialConfigJenkins=""

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
    curl -s -c JenkinsSessionCookie -X GET http://localhost:8080/crumbIssuer/api/json --user "admin:$InitialAdminPassword" | jq -r .crumb > JenkinsLastCrumb && logokay "Successfully obtained a crumb and a session cookie for ${Name}" || { logerror "Failure obtaining crumb and a session cookie for ${Name}" && exiterror ; }

    #Get the Jenkins configure groovy script
    curl -s -X GET $ConfigJenkins -O && logokay "Successfully obtained configure groovy script for ${Name}" || { logerror "Failure obtaining configure groovy script for ${Name}" && exiterror ; }

    #Load the initial configuration for Jenkins
    LoadedInitialConfigJenkins=$(cat $ConfigJenkinsFileName)

    echo "$LoadedInitialConfigJenkins" | sed "s/~JenkinsUsername~/$JENKINS_USERNAME/g" | sed "s/~JenkinsPassword~/$JENKINS_PASSWORD/g" | sed "s/~JenkinsEmail~/$JENKINS_EMAIL/g" | sed "s,~JenkinsIP~,$JENKINS_IP,g"

    #Set the Username, Password, Email and IP for the configure groovy script placeholders
    echo "$LoadedInitialConfigJenkins" | sed "s/~JenkinsUsername~/$JENKINS_USERNAME/g" | sed "s/~JenkinsPassword~/$JENKINS_PASSWORD/g" | sed "s/~JenkinsEmail~/$JENKINS_EMAIL/g" | sed "s,~JenkinsIP~,$JENKINS_IP,g" > $ConfigJenkinsFileName && logokay "Successfully set configure groovy script for ${Name}" || { logerror "Failure setting configure groovy script for ${Name}" && exiterror ; }

    #Get the list of recommended plugins
    curl -s -X GET $RecommendedPluginsList -O && logokay "Successfully obtained the list of recommended plugins for ${Name}" || { logerror "Failure obtaining the list of recommended plugins for ${Name}" && exiterror ; }

    #Narrow the list of suggested plugins
    cat platform-plugins.json | grep suggested | cut -d ':' -f2 | cut -d ',' -f1 | sed 's/^[[:space:]]*//g' | sed 's/"//g' > SuggestedPlugins && logokay "Successfully narrowed the list of suggested plugins for ${Name}" || { logerror "Failure narrowing the list of suggested plugins for ${Name}" && exiterror ; }

    #Go through the list of suggested plugins and add them to the configure groovy script
    for (( i=1; i<=$(cat SuggestedPlugins | wc -l); i++ ))
    do
        Plugin=$(cat SuggestedPlugins | sed -n $i'p' | sed 's/^/"/;s/$/"/')
        echo "" >> $ConfigJenkinsFileName
        echo "Jenkins.instance.updateCenter.getPlugin($Plugin).deploy()" >> $ConfigJenkinsFileName && logokay "Successfully added $Plugin to the plugins install list for ${Name}" || { logerror "Failure adding $Plugin to the plugins install list for ${Name}" && exiterror ; }
    done

    #Added all suggested plugins to the install list
    echo "" >> $ConfigJenkinsFileName && logokay "Successfully added all plugins to the plugins install list for ${Name}" || { logerror "Failure adding all plugins to the plugins install list for ${Name}" && exiterror ; }

    #Config script is completed
    echo "return null" >> $ConfigJenkinsFileName && echo "" >> $ConfigJenkinsFileName && logokay "Successfully completed config script for ${Name}" || { logerror "Failure completing config script for ${Name}" && exiterror ; }

    #Remote execute the groovy script
    curl -s -b JenkinsSessionCookie -X POST http://localhost:8080/scriptText -H "Jenkins-Crumb: $(cat JenkinsLastCrumb)" --user admin:$InitialAdminPassword --data-urlencode "script=$( < ./$ConfigJenkinsFileName)" > JenkinsExecution && test $(cat JenkinsExecution | wc -c) -eq 0 && logokay "Successfully executed configure groovy script for ${Name}" || { logerror "Failure executing configure groovy script for ${Name}" && cat JenkinsExecution && rm JenkinsExecution && exiterror ; }

    cp $ConfigJenkinsFileName $ConfigJenkinsFileName".back"

    #Remove configure groovy script
    rm $ConfigJenkinsFileName && logokay "Successfully removed configure groovy script for ${Name}" || { logerror "Failure removing configure groovy script for ${Name}" && exiterror ; }

    #Remove initialAdminPassword and JenkinsExecution
    rm $InitialAdminPasswordLocation ; rm JenkinsExecution && logokay "Successfully removed initialAdminPassword for ${Name}" || { logerror "Failure removing initialAdminPassword for ${Name}" && exiterror ; }
}

#Log start
logokay "Running the configure ${Name} script"

#Check for admin permissions
admincheck

#Call the main function
main

#Log successs
logokay "Ran the configure ${Name} script successfully"

#Exit successs
exit 0