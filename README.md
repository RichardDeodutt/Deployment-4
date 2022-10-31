# Deployment-4

Set up a CI/CD pipeline from start to finish using a Jenkins server and deploying with Terraform. 

My goal was to automate as much as I can, from setting up an ec2 with a Jenkins server all the way to having it do a build on the jenkins server. 

To achieve this goal I used Github, Github Actions, Terraform and some Bash scripting. 

# Process

## The First Step

<details>

<summary>Create an EC2 with Jenkins installed</summary>

<br>

- I used a GitHub Actions work flow to achieve this along with GitHub Secrets to create variables and pass arugments or replace place holders such as `~User~`. 

- The workflow [Deploy-Jenkins](https://github.com/RichardDeodutt/Deployment-4/blob/main/.github/workflows/Deploy-Jenkins.yml) will use the terraform files for [Jenkins](https://github.com/RichardDeodutt/Deployment-4/tree/main/Terraform/Jenkins) to create a EC2 and install Jenkins along with everything the server should have in it such as Terraform. It uses `SSH` and [Bash scripts](https://github.com/RichardDeodutt/Deployment-4/tree/main/Scripts) to install Jenkins and the other software needed. This assumes you already have a `keypair` created and a `security group` with port `22` and `80` open to use. You need to change the `keypair` and `security group` names in the terraform files to yours along with using your `region`. 

- To store the state file I used a `S3 bucket` and a `Dynamodb table` to store a `statelock`. There are more terraform files for the [Backend](https://github.com/RichardDeodutt/Deployment-4/tree/main/Terraform/Remote-S3) to create it but this needs to be changed to be `unique`, it can't be the same as mine. I created the workflow [Init-Remote-Statefile](https://github.com/RichardDeodutt/Deployment-4/blob/main/.github/workflows/Init-Remote-Statefile.yml) to initialize the backend. 

- Using the state file I created a workflow [Release-Jenkins](https://github.com/RichardDeodutt/Deployment-4/blob/main/.github/workflows/Release-Jenkins.yml) to `destroy` the infrastructure when done with it. 

- I created a workflow [Redeploy-Jenkins](https://github.com/RichardDeodutt/Deployment-4/blob/main/.github/workflows/Redeploy-Jenkins.yml) to saved time if I wanted to `restart from scratch` by first `destroying` the infrastructure and then `creating` it again. It `recreates` everything from scratch. 

- The workflows that deploy the Jenkins server do some inital configurations using the Jenkins API, Jenkins CLI and a generated [Groovy script](https://github.com/RichardDeodutt/Deployment-4/blob/main/Configs/jenkins-configure.groovy) to setup things such as the username, password and plugins. 

- (Nginx)[https://github.com/RichardDeodutt/Deployment-4/blob/main/Configs/server-nginx-default] is used as a reverse proxy to use port 80. 

</details>

## The Second Step

<details>

<summary>Configure the Jenkins Server</summary>

<br>

- I created a workflow [Post-Config-Jenkins](https://github.com/RichardDeodutt/Deployment-4/blob/main/.github/workflows/Post-Config-Jenkins.yml) to configure Jenkins so you don't have to use the web UI. It uses SSH to run scripts that uses the Jenkins CLI and some [xml templates](https://github.com/RichardDeodutt/Deployment-4/tree/main/Configs).

- It creates the [Secrets](https://github.com/RichardDeodutt/Deployment-4/blob/main/Configs/credential-secret-jenkins-default.xml) and [Credentials](https://github.com/RichardDeodutt/Deployment-4/blob/main/Configs/credential-cred-jenkins-default.xml) and also the [build job or project](https://github.com/RichardDeodutt/Deployment-4/blob/main/Configs/job-build-jenkins-default.xml) for Deployment-4 while making sure it `dosn't run automatically` by canceling the first auto build. 

</details>

## The Third Step

<details>

<summary>Control the Jenkins Server</summary>

<br>

- I made a workflow [Execute-Jenkins-Build-Job](https://github.com/RichardDeodutt/Deployment-4/blob/main/.github/workflows/Execute-Jenkins-Build-Job.yml) that allows me to run the `build job`  without using the web UI all from the `Github Actions` page. I could use a `webhook` and `update` the `forked repository` to automatically have it `build` but this workflow gived me the ability to run the build `whenever` I want. 

- I also made a workflow [Update-Forked-Repo](https://github.com/RichardDeodutt/Deployment-4/blob/main/.github/workflows/Update-Forked-Repo.yml) that allow me to automatically update the forked repo with the changes in the [Modified-Application-Files](https://github.com/RichardDeodutt/Deployment-4/tree/main/Modified-Application-Files) directory. I make the changes `manually` to `Modified-Application-Files` and once this repository is `updated` I can run this workflow to `update` the `forked` repository automatically. 

- There is also a workflow [Build-and-Test](https://github.com/RichardDeodutt/Deployment-4/blob/main/.github/workflows/Build-and-Test.yml) I made to do unit tests on the scripts to make sure they don't break accidentally. 

- The scripts in the [Runners](https://github.com/RichardDeodutt/Deployment-4/tree/main/Runners) directory run the scrips in the [Scripts](https://github.com/RichardDeodutt/Deployment-4/tree/main/Scripts) directory. 

</details>

# Secrets/Variables

<details>

<summary>Show Secrets/Variables</summary>

<br>

- AWS_ACCESS_KEY_ID 

    - AWS IAM User with AdministratorAccess, their Access Key ID. 

        Secrets/Variables:

        ```
        AWS_ACCESS_KEY_ID
        ```

        Example Below: 

        ```
        AKIAXIDF5EYC4GKLMXNZ
        ```

- AWS_SECRET_ACCESS_KEY 

    - AWS IAM User with AdministratorAccess, their Secret Access Key ID. 

        Secrets/Variables:

        ```
        AWS_SECRET_ACCESS_KEY
        ```

        Example Below: 

        ```
        nhsi9mxRJfZYUx/HKS4jJ1rK4tcbJwH+pzg3I+nD
        ```

- AWS_SSH_KEY_BASE64 

    - AWS SSH Key Pair to SSH into the Jenkins Server EC2 in base64 format using the base64 command. 

        Secrets/Variables:

        ```
        AWS_SSH_KEY_BASE64
        ```

        Example Below: 

        ```
        cat ~/.ssh/Tokyo.pem | base64
        ```

- JENKINS_USERNAME 

    - Desired Jenkins username to create the Jenkins Server with. 

        Secrets/Variables:

        ```
        JENKINS_USERNAME
        ```

        Example Below: 

        ```
        Jeff
        ```

- JENKINS_PASSWORD 

    - Desired Jenkins password to create the Jenkins Server with. 

        Secrets/Variables:

        ```
        JENKINS_PASSWORD
        ```

        Example Below: 

        ```
        password1234
        ```

- JENKINS_EMAIL 

    - Desired Jenkins admin email to create the Jenkins Server with. 

        Secrets/Variables:

        ```
        JENKINS_EMAIL
        ```

        Example Below: 

        ```
        Jeff@gmail.com
        ```

- USER_GITHUB_USERNAME 

    - Your Github Username to access your forked repo. 

        Secrets/Variables:

        ```
        USER_GITHUB_USERNAME
        ```

        Example Below: 

        ```
        BossJeff
        ```

- USER_GITHUB_TOKEN 

    - Your Github Personal Access token to access your forked repo. 

        Secrets/Variables:

        ```
        USER_GITHUB_TOKEN
        ```

        Example Below: 

        ```
        ghp_l5W2WQ0vrQIOaNmApxv2ygBIvDXoxj2EllWd
        ```

- JENKINS_JOB_NAME 

    - The name of the Build Job or Project Jenkins uses. 

        Secrets/Variables:

        ```
        JENKINS_JOB_NAME
        ```

        Example Below: 

        ```
        Deployment-4
        ```

- JENKINS_GITHUB_REPO_URL 

    - The url of the forked repo. 

        Secrets/Variables:

        ```
        JENKINS_GITHUB_REPO_URL
        ```

        Example Below: 

        ```
        https://github.com/RichardDeodutt/kuralabs_deployment_4
        ```

- THIS_GITHUB_REPO_URL

    - The url of this repo or if this is a fork of the original then the url of this forked repo. 

        Secrets/Variables:

        ```
        THIS_GITHUB_REPO_URL
        ```

        Example Below: 

        ```
        https://github.com/RichardDeodutt/Deployment-4
        ```

- USER_GITHUB_SSH_KEY_BASE64

    - Your GitHub SSH key to do a push in base64 format using the base64 command. 

        Secrets/Variables:

        ```
        USER_GITHUB_SSH_KEY_BASE64
        ```

        Example Below: 

        ```
        cat ~/.ssh/id_rsa | base64
        ```

- USER_GITHUB_EMAIL

    - Your GitHub email to author a commit can be the same as the JENKINS_EMAIL. 

        Secrets/Variables:

        ```
        USER_GITHUB_EMAIL
        ```

        Example Below: 

        ```
        Jeff@gmail.com
        ```

</details>

# Diagram

<details>

<summary>Show Diagram</summary>

<br>

<p align="center">
<a href="https://github.com/RichardDeodutt/Deployment-4/blob/main/Images/Diagram.drawio.png"><img src="https://github.com/RichardDeodutt/Deployment-4/blob/main/Images/Diagram.drawio.png" />
</p>

</details>

# Issues 

- Sometimes apt fails because of broken packages or other reason making this system unstable.

- Sometimes the Jenkins server plugin downloads can fail for unknown reasons and it times out, currently a unhandled situation. There seems to be issues with dependencies so you have to manually go to the Jenkins Server and fix them. 

- Jenkins Server seems to become unresponsive during cypress test it might be because of not enough resources so I used a c5.xlarge which is not free tier to avoid this. Can't avoid a issue with the cypress test. 

# Improvements 

- With some more times I can work on the Issues

- Make more Secrets/Variables for things like the Backend so editing the files won't be necessary. 

- Maybe I could use Ansible to do the configuration of Jenkins. 

- Improve the Terraform files to create the secuirty group and keypair and other resources it needs for the Jenkins Server. 

- Making this system less unstable. 

- Tidy up the code to be more readable