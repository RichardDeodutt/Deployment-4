#!groovy

//Import modules used
import jenkins.model.*
import hudson.security.*
import hudson.util.*
import jenkins.install.*

//Locate the jenkins instance running
def JInstance = Jenkins.getInstance()

//Required to have a realm to create a new user
def hudsonRealm = new HudsonPrivateSecurityRealm(false)

//Create the user with a username and password that's using a placeholder
hudsonRealm.createAccount(~JenkinsUsername~, ~JenkinsPassword~)

//Apply the realm containing the created user to the running jenkins instance
JInstance.setSecurityRealm(hudsonRealm)

//Needs a strategy to include admin access
def strategy = new GlobalMatrixAuthorizationStrategy()

//Add the user to the strategy and give admin permissions
strategy.add(Jenkins.ADMINISTER, ~JenkinsUsername~)

//Apply the strategy containing the created user to the running jenkins instance
JInstance.setAuthorizationStrategy(strategy)

//Get the default admin user
User admin = User.get('admin')

//Delete the default admin user
admin.delete()

//Set the state of installation to completed skipping setup
JInstance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)

//Save Applied Changes
JInstance.save()