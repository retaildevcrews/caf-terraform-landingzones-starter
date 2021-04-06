# NGSA Helm installation

### Prerequisites

- Infrastructure provisioned by Terraform CAF aks-secure-baseline project must already exist.
- Helm v3 ([Install Instructions](https://helm.sh/docs/intro/install/))


Change into the base directory of the repo

```bash

cd caf-terraform-landingzones-starter/enterprise_scale/construction_sets/aks/online/aks_secure_baseline/ngsa

export REPO_ROOT=$(pwd)

```

#### Login to Azure and select subscription

```bash

az login

# show your Azure accounts
az account list -o table

# select the Azure account
az account set -s {subscription name or Id}

```

## Install Helm 3

Install the latest version of Helm by download the latest [release](https://github.com/helm/helm/releases):

```bash

# mac os
OS=darwin-amd64 && \
REL=v3.3.4 && \ #Should be lastest release from https://github.com/helm/helm/releases
mkdir -p $HOME/.helm/bin && \
curl -sSL "https://get.helm.sh/helm-${REL}-${OS}.tar.gz" | tar xvz && \
chmod +x ${OS}/helm && mv ${OS}/helm $HOME/.helm/bin/helm
rm -R ${OS}

```

or

```bash

# Linux/WSL
OS=linux-amd64 && \
REL=v3.3.4 && \
mkdir -p $HOME/.helm/bin && \
curl -sSL "https://get.helm.sh/helm-${REL}-${OS}.tar.gz" | tar xvz && \
chmod +x ${OS}/helm && mv ${OS}/helm $HOME/.helm/bin/helm
rm -R ${OS}

```

Add the helm binary to your path and set Helm home:

```bash

export PATH=$PATH:$HOME/.helm/bin
export HELM_HOME=$HOME/.helm

```

>NOTE: This will only set the helm command during the existing terminal session. Copy the 2 lines above to your bash or zsh profile so that the helm command can be run any time.

Verify the installation with:

```bash

helm version

```

Add the required helm repositories

```bash

helm repo add stable https://charts.helm.sh/stable
helm repo update

```

## Add GitHub Packages (ghcr.io) to firewall white list

```bash
From Azure portal locate and navigate the vNet-Hub resource group created by Infrastructure Provisioning, e.g. vnet-hub-re1, then locate the egress firewall resource.

Go to packages application rule collection by navigating to:

[Egress Firwall] > [Setting] > [Rules(Classic)] > [Application rule collection] > [Packages]

Add the a new Target FQDN
```

| **name**  | **Source type** |      **Source**     | **Protocol:Port** | **Target FQDNs** |
|-----------|-----------------|---------------------|-------------------|------------------|
| ghcr      | IP Group        |same as Docker entry |     Https:443     |     ghcr.io      |

```bash
# Note: This step will be automated on a later Infrastructure Provisioning release.
# if you skip this step, the pod will not be able to download the image.
```


## Deploy NGSA with Helm
```bash
The NGSA application has been packed into a Helm chart for deployment into the cluster. The following instructions will walk you through the manual process of deployment of the helm chart and is recommended for development and testing.
```

```bash

Navigate to 
cd $REPO_ROOT/enterprise_scale/construction_sets/aks/online/aks_secure_baseline


# Create cluster secure baseline namespace
kubectl create namespace ngsa

# Install NGSA using the ngsa memory helm chart
helm install ngsa-aks ngsa -f ./ngsa/helm-config-ngsa-memory.yaml --namespace ngsa

# Verify that the application was succesfully deployed
kubectl get pods -n cluster-baseline-settings

# Check logs, you should see several entries with Status 200 for Healthz
kubectl logs <pod name> -n ngsa

# Uninstall NGSA using the ngsa helm chart
helm uninstall ngsa-aks --namespace ngsa

```
