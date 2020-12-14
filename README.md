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
 
 ## Build Tailscale container
Tailscale isn't officialy distributed via docker containers, therefore by defult this project will deploy one from my Docker Hub repo or you can build your own one. Thanks to @hamishforbes for the `Dockerfile` and `entrypoint.sh`.

`Docker`:
```
FROM alpine:3.12 AS build

ARG CHANNEL=stable
ARG VERSION=1.2.10
ARG ARCH=amd64

RUN mkdir /build
WORKDIR /build
RUN apk add --no-cache curl tar

RUN curl -vsLo tailscale.tar.gz "https://pkgs.tailscale.com/${CHANNEL}/tailscale_${VERSION}_${ARCH}.tgz" && \
    tar xvf tailscale.tar.gz && \
    mv "tailscale_${VERSION}_${ARCH}/tailscaled" . && \
    mv "tailscale_${VERSION}_${ARCH}/tailscale" .

FROM alpine:3.12

RUN apk add --no-cache iptables

COPY --from=build /build/tailscale /usr/bin/
COPY --from=build /build/tailscaled /usr/bin/

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]
```

`entrypoint.sh`:
```
# Create the tun device path if required
if [ ! -d /dev/net ]; then mkdir /dev/net; fi
if [ ! -e /dev/net/tun ]; then  mknod /dev/net/tun c 10 200; fi

# Wait 5s for the daemon to start and then run tailscale up to configure
/bin/sh -c "sleep 5; tailscale up --authkey=${TAILSCALE_AUTH} --advertise-tags=${TAILSCALE_TAGS}" &
exec /usr/bin/tailscaled --state=/tailscale/tailscaled.state
```

### Áchtung

Both Pi-hole and Tailscale are not originally build for "contenirisaion", not everyting is configurable via env vars or ConfigMaps and requires persistent storage, which means that it can be lost when AKS cluster or Pod is deleted. 

Things that require improvemenents or don't currently work:
- Pi-hole lists configuration at deployment (whitelist\blasklist\adlist) have been moved from flat files into a local database, this makes it harder to maintain them at the deployment stage. Still possible to inject via CLI commands;
- When AKS cluster or Pi-Hole\Tailscale Pod is re-deployed from scratch the last step of the `Deployment` section has to be repeated;