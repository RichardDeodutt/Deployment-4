#!groovy

import jenkins.model.*
import hudson.util.*
import jenkins.install.*

def JInstance = Jenkins.getInstance()

JInstance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)