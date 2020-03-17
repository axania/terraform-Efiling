
## Terraform installation


1. Dowload terraform for your OS https://www.terraform.io/downloads.html
2. Put terraform file in a PATH or simply copy it to /usr/bin/terraform for Linux OS
3. In order check that the system can find executable file, # which terraform 

---

## Install Azure Cli

1. Download and Install Azure CLI on the same machine with terraform https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest

---

## Clone a repository and Deploy new Infra

1. Clone the repo
2. cd terraform_sogema
3. go to the directory you have interest on
<<<<<<< master
3. az login 
3. terraforme init
4. terraform plan
5. terraform apply
=======
4. az login
  - for security purposes, we decided to not add the subscription_id in the terraform scripts. The analyst needs to login manually prior to launch the terraform. 
5. terraforme init
<<<<<<< master
6. terraform plan -var 'admin_password=12345678qwertyui'
 - add the correct password for the system-and-environment 
7. terraform apply -var 'admin_password=12345678qwertyui'
 - add the correct password for the system-and-environment 
>>>>>>> added the information on the README.md file for the terraform command line containing the password's variable
=======
6. terraform plan
7. terraform apply
>>>>>>> Revert "added the information on the README.md file for the terraform command line containing the password's variable"

---