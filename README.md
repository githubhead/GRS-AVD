# Azure Virtual Desktop POC Infrastructure

This repository is an initial proof of concept (POC) to deploy Azure Virtual Desktop (AVD) using Terraform. 

The repo follows a standard layout with the majority of the modules present in the modules folder. You can deploy to dev, uat, and prod environments by defining tfvars for each. 
Eventually the network and storage modules will be split into their own repository so that those resources are managed and deployed independently from the compute. The order in which deployment should be done given the existing dependencies is thus
Network
Storage
Compute

As of this writing, the repo leverages Terraform Workspaces to publish to multiple environments. The deployment steps when deploying locally (i.e. not through a pipeline) include:
1. List the Terraform workspaces
terraform workspace list  

2. Switch to the space where you wish to deploy
terraform workspace dev

3. Create a plan
terraform plan --var-file=environments/dev/dev.tfvars -var "az_subscription_id=<>"  -target=module.avd_network 

4. Apply the Terraform plan
terraform apply --var-file=environments/dev/dev.tfvars -var "az_subscription_id=<>"  -target=module.avd_network -auto-approve



