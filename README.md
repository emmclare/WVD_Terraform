## WVD_Terraform

This repo contains files to create a basic ARM WVD Deployment.
It is currently split into 3 files:

Host.tf

Infrastructure.tf

Variables.tf

### Host.tf
This contains the session host build details, including the vm extensions.  Can be used to deploy multiple session hosts by modifying rdsh_count variable in the variables file

### Infrastructure.tf
This builds the WVD infra, including the network components. It doesn't provision AD though and assumes that there is another VNet elsewhere with your DC in (referenced as ADVnet in variables).  We setup the peering during the build as it is required for the domain join.
* Storage account is also not included if used for profiles - may be added later
* Change the DNS server settings to point to your own DC (infrastructure.tf line 23).  
* I haven't applied the NSG to the subnet in this sample, but if using NSGs ensure that the following URLs are reachable and resolvable:
  https://docs.microsoft.com/en-us/azure/virtual-desktop/safe-url-list
* URL to configuration zip may need to be updated in future (in the vm dsc extension block)

### Variables.tf
All the configurable variables, mostly self explanatory. For sensitive inputs (eg domain creds) I haven't created a default value, but this could be done if wished. 

