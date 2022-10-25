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

#The configuration for nginx
ConfigNginx="https://raw.githubusercontent.com/RichardDeodutt/Deployment-3/main/Configs/server-nginx-default"

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
    curl -s -c JenkinsSessionCookie -X GET http://localhost:8080/crumbIssuer/api/json --user "admin:$(cat /var/lib/jenkins/secrets/initialAdminPassword)" | jq -r .crumb > JenkinsLastCrumb && logokay "Successfully obtained a crumb and a session cookie for ${Name}" || { logerror "Failure obtaining crumb and a session cookie for ${Name}" && exiterror ; }

    #Get the Jenkins configure groovy script
    curl -s -X GET https://raw.githubusercontent.com/RichardDeodutt/Deployment-4/main/Configs/jenkins-configure.groovy -O && logokay "Successfully obtained configure groovy script for ${Name}" || { logerror "Failure obtaining configure groovy script for ${Name}" && exiterror ; }

    #Format Email
    cat JENKINS_EMAIL | sed 's/^/</;s/$/>/' > JENKINS_EMAIL_TEMP && echo "$(cat JENKINS_USERNAME) $(cat JENKINS_EMAIL_TEMP)" > JENKINS_EMAIL && rm JENKINS_EMAIL_TEMP && logokay "Successfully formatted email for ${Name}" || { logerror "Failure formatting email for ${Name}" && exiterror ; }

    #Format IP
    mv JENKINS_IP JENKINS_IP_TEMP && echo "http://$(cat JENKINS_IP_TEMP)/" > JENKINS_IP && rm JENKINS_IP_TEMP && logokay "Successfully formatted IP for ${Name}" || { logerror "Failure formatting IP for ${Name}" && exiterror ; }

    #Add Quotes to the Username, Password, Email and IP
    cat JENKINS_USERNAME | sed 's/^/"/;s/$/"/' > JENKINS_USERNAME_TEMP && cat JENKINS_PASSWORD | sed 's/^/"/;s/$/"/' > JENKINS_PASSWORD_TEMP && cat JENKINS_EMAIL | sed 's/^/"/;s/$/"/' > JENKINS_EMAIL_TEMP && cat JENKINS_IP | sed 's/^/"/;s/$/"/' > JENKINS_IP_TEMP && mv JENKINS_USERNAME_TEMP JENKINS_USERNAME && mv JENKINS_PASSWORD_TEMP JENKINS_PASSWORD && mv JENKINS_EMAIL_TEMP JENKINS_EMAIL && mv JENKINS_IP_TEMP JENKINS_IP && logokay "Successfully added quotes to the Username, Password and IP for ${Name}" || { logerror "Failure adding quotes to the Username, Password and IP for ${Name}" && exiterror ; }

    #Set the Username, Password, Email and IP for the configure groovy script placeholders
    cat "jenkins-configure.groovy" | sed "s/~JenkinsUsername~/$(cat JENKINS_USERNAME)/g" | sed "s/~JenkinsPassword~/$(cat JENKINS_PASSWORD)/g" | sed "s/~JenkinsEmail~/$(cat JENKINS_EMAIL)/g" | sed "s,~JenkinsIP~,$(cat JENKINS_IP),g" > "jenkins-configure.groovy" && logokay "Successfully set configure groovy script for ${Name}" || { logerror "Failure setting configure groovy script for ${Name}" && exiterror ; }

    #Get the list of recommended plugins
    curl -s -X GET https://raw.githubusercontent.com/jenkinsci/jenkins/master/core/src/main/resources/jenkins/install/platform-plugins.json -O && logokay "Successfully obtained the list of recommended plugins for ${Name}" || { logerror "Failure obtaining the list of recommended plugins for ${Name}" && exiterror ; }

    #Narrow the list of suggested plugins
    cat platform-plugins.json | grep suggested | cut -d ':' -f2 | cut -d ',' -f1 | sed 's/^[[:space:]]*//g' > SuggestedPlugins && logokay "Successfully narrowed the list of suggested plugins for ${Name}" || { logerror "Failure narrowing the list of suggested plugins for ${Name}" && exiterror ; }

    #Go through the list of suggested plugins and add them to the configure groovy script
    for (( i=1; i<=$(cat SuggestedPlugins | wc -l); i++ ))
    do
        Plugin=$(cat SuggestedPlugins | sed -n $i'p')
        echo "" >> "jenkins-configure.groovy"
        echo "Jenkins.instance.updateCenter.getPlugin($Plugin).deploy()" >> "jenkins-configure.groovy" && logokay "Successfully added $Plugin to the plugins install list for ${Name}" || { logerror "Failure adding $Plugin to the plugins install list for ${Name}" && exiterror ; }
    done

    echo "" >> "jenkins-configure.groovy" && logokay "Successfully added all plugins to the plugins install list for ${Name}" || { logerror "Failure adding all plugins to the plugins install list for ${Name}" && exiterror ; }

    cp "jenkins-configure.groovy" "jenkins-configure.groovy.tempback"

    #Remote execute the groovy script
    curl -s -b JenkinsSessionCookie -X POST http://localhost:8080/scriptText  -H "Jenkins-Crumb: $(cat JenkinsLastCrumb)" --user admin:$(cat /var/lib/jenkins/secrets/initialAdminPassword) --data-urlencode "script=$( < ./jenkins-configure.groovy)" > JenkinsExecution && test $(cat JenkinsExecution | wc -c) -eq 0 && logokay "Successfully executed configure groovy script for ${Name}" || { logerror "Failure executing configure groovy script for ${Name}" && cat JenkinsExecution && rm JenkinsExecution && exiterror ; }

    #Remove configure groovy script
    rm jenkins-configure.groovy && logokay "Successfully removed configure groovy script for ${Name}" || { logerror "Failure removing configure groovy script for ${Name}" && exiterror ; }

    #Remove initialAdminPassword and JenkinsExecution
    rm /var/lib/jenkins/secrets/initialAdminPassword ; rm JenkinsExecution && logokay "Successfully removed initialAdminPassword for ${Name}" || { logerror "Failure removing initialAdminPassword for ${Name}" && exiterror ; }
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