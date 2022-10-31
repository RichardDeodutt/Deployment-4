# Deployment-4

Set up a CI/CD pipeline from start to finish using a Jenkins server and deploying with Terraform. 

My goal was to automate as much as I can, from setting up an ec2 with a Jenkins server all the way to having it do a build on the jenkins server. 

To achieve this goal I used Github, Github Actions, Terraform and some Bash scripting. 

# Secrets/Variables

- AWS_ACCESS_KEY_ID

- AWS_SECRET_ACCESS_KEY

- AWS_SSH_KEY_BASE64

- JENKINS_USERNAME

- JENKINS_PASSWORD

- JENKINS_EMAIL

- USER_GITHUB_USERNAME

- USER_GITHUB_TOKEN

- JENKINS_JOB_NAME

- JENKINS_GITHUB_REPO_URL

- THIS_GITHUB_REPO_URL

- USER_GITHUB_SSH_KEY_BASE64

- USER_GITHUB_EMAIL