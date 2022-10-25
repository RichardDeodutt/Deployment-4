#!groovy

//Import modules used
import jenkins.model.*
import hudson.security.*
import hudson.util.*
import jenkins.install.*

//Locate the jenkins instance running
def JInstance = Jenkins.getInstance()

//Get the default admin user
User Jadmin = User.get('admin')

//Delete the default admin user
Jadmin.delete()

//Required to have a realm to create a new user
def JHudsonRealm = new HudsonPrivateSecurityRealm(false)

//Create the user with a username and password that's using a placeholder
JHudsonRealm.createAccount(~JenkinsUsername~, ~JenkinsPassword~)

//Apply the realm containing the created user to the running jenkins instance
JInstance.setSecurityRealm(JHudsonRealm)

//Needs a strategy to include admin access
def JStrategy = new FullControlOnceLoggedInAuthorizationStrategy()

//Extra Security
JStrategy.setAllowAnonymousRead(false)

//Apply the strategy containing the created user to the running jenkins instance
JInstance.setAuthorizationStrategy(JStrategy)

//Get the location config
JURLConfig = JenkinsLocationConfiguration.get()

//Set the location config, that's using a placeholder
JURLConfig.setUrl(~JenkinsIP~)

//Save the changes
JURLConfig.save()

//Set the state of installation to completed skipping setup
JInstance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)

//Save Applied Changes
JInstance.save()
