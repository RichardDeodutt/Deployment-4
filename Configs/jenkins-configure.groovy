#!groovy

//Import modules used
import jenkins.model.*
import hudson.security.*
import hudson.util.*
import jenkins.install.*

//Locate the jenkins instance running
def JInstance = Jenkins.getInstance()

//Required to have a realm to create a new user
def JHudsonRealm = new HudsonPrivateSecurityRealm(false)

//Create the user with a username and password that's using a placeholder
JHudsonRealm.createAccount(~JenkinsUsername~, ~JenkinsPassword~)

//Apply the realm containing the created user to the running jenkins instance
JInstance.setSecurityRealm(JHudsonRealm)

//Needs a strategy to include admin access
def JStrategy = new FullControlOnceLoggedInAuthorizationStrategy()

//Add the user to the strategy and give admin permissions
JStrategy.add(Jenkins.ADMINISTER, ~JenkinsUsername~)

//Extra Security
JStrategy.setAllowAnonymousRead(false)

//Apply the strategy containing the created user to the running jenkins instance
JInstance.setAuthorizationStrategy(JStrategy)

//Get the default admin user
User Jadmin = User.get('admin')

//Delete the default admin user
Jadmin.delete()

//Set the state of installation to completed skipping setup
JInstance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)

//Save Applied Changes
JInstance.save()