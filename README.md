# pihole-tailscale
The idea of this project is to have a private Pi-hole instance that is reachable when you're not at home and runs in a environment that is more reliable than a RaspberryPi connected over home broadband. 

Tailscale is an implementation of a WireGuard protocol with some light-house service to simplify device registration and peers autodiscovery. It allows to buld a peer-to-peer overlay mesh network between the Pi-hole instance and the devices you might want to use it as a resolver. There are clients available for Windows/Linux/macOS/Andoid/iOS platforms. It will also handle DNS client config switching on the device. More details on how it works: https://tailscale.com/blog/how-tailscale-works/

Terraform project in this repository deploys a Pi-hole container with a Tailscale sidecar on Azure Kubernetes Services cluster. The Pi-hole DNS resolver and Web Admin UI is avilable for clients on you private Tailscale network this helps to reduce attack surface without manually whitelisting evechanging client IPs.

*AKS is cerataonly an overkill here but it helps with another goal of points of this project which is to play with AKS and Tailscale.* :grin:

## Requirements
- Accounts on:
	- Microsoft Azure;
	- Tailscale;
- Tools:
	- Terrform;
	- Azure CLI;

## Deployment
### Create an Azure Active Directory service principal account
AKS cluster requires AAD service principal (or a managed identity) to interact with the Azure API and to dynamically create and manage other Azure resources.

Use Azure CLI to create the account without any default assignments:
```sh
az ad sp create-for-rbac --skip-assignment
```
Necesarry permissions will be delegated to the account during cluster provisioning.

Update `terraform.tfvars` file variables:
- `aks_service_principal_app_id`
- `aks_service_principal_password`
### Create Tailscale account and obtain pre-authentication key
`Solo` plan is free and will allow to register up to 100 devices. Once you have an account, get a reusable client pre-authentication key via admin panel: https://login.tailscale.com/admin/authkeys
This key will be used by the Tailscale sidecar containers to register with the light-house.
Save the key in `tailscale_secret_TAILSCALE_AUTH` in the `terraform.tfvars` file.
### Define Pi-hole Web Admin password
Define the password for the Pi-hole Web Admin UI via `pihole_secret_WEBPASSWORD` variable in `terraform.tfvars` file.
  
## Deployment
1. Initialise and deploy the project (takes 15 - 20 minutes):
````shell-session
$ terraform init
$ terraform apply
````
2. Once deployment is complete obtain Pi-hole container IP within Tailscale network via the admin panel (machine name is `pihole-*`): https://login.tailscale.com/admin/machines
3. Configure the Pi-hole container IP in Tailscale overlay network as a Nameserver via the admin panel: https://login.tailscale.com/admin/dns

Now you can register you client devices, once connected it will reconfigure your device DNS client to use the Pi-hole via the Tailscale overlay network.
 
 