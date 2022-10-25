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

    #Add Quotes to the Username and Password
    cat JENKINS_USERNAME | sed 's/^/"/;s/$/"/' > JENKINS_USERNAME_TEMP && cat JENKINS_PASSWORD | sed 's/^/"/;s/$/"/' > JENKINS_PASSWORD_TEMP && mv JENKINS_USERNAME_TEMP JENKINS_USERNAME && mv JENKINS_PASSWORD_TEMP JENKINS_PASSWORD && logokay "Successfully added quotes to the Username and Password for ${Name}" || { logerror "Failure adding quotes to the Username and Password for ${Name}" && exiterror ; }

    #Set the Username and Password for the configure groovy script placeholders
    cat "jenkins-configure.groovy" | sed "s/~JenkinsUsername~/$(cat JENKINS_USERNAME)/g" | sed "s/~JenkinsPassword~/$(cat JENKINS_PASSWORD)/g" > "jenkins-configure.groovy" && logokay "Successfully set configure groovy script for ${Name}" || { logerror "Failure setting configure groovy script for ${Name}" && exiterror ; }

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