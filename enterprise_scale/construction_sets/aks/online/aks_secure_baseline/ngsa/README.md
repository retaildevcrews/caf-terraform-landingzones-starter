# NGSA Helm installation

### Prerequisites

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
helm repo add kedacore https://kedacore.github.io/charts
helm repo add jetstack https://charts.jetstack.io
helm repo update

```

## Deploy NGSA with Helm

```bash
# <<<<<<<<<<<<<<<<<<<< TODO >>>>>>>>>>>>>>>>>>>>

#  This description needs to be updated 

```
The NGSA application has been packed into a Helm chart for deployment into the cluster. The following instructions will walk you through the manual process of deployment of the helm chart and is recommended for development and testing. Alternatively, the helm chart can be deployed in a GitOps CICD approach. GitOps allows the automated deployment of the application to the cluster using FluxCD in which the configuration of the application is stored in Git.([NGSA-CD](https://github.com/retaildevcrews/ngsa-cd)).

```bash

cd $REPO_ROOT/enterprise_scale/construction_sets/aks/online/aks_secure_baseline/ngsa

export CHART_REPO=$(pwd)


```bash

# Install NGSA using the upstream ngsa image from GitHub Container Registry

helm install ngsa-aks ngsa -f chart.yaml --namespace ngsa 

# Note: Above command creates a ngsa cosmos deployment named ngsa-aks

## <<<<<<<<<<<<<<<<<<<<<   TODO    >>>>>>>>>>>>>>>>>>>>>
#   needs to be memory deployment instead cosmos 


```
