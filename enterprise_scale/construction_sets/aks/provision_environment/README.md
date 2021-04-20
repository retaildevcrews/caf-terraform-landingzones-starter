# Script to provision an environment

## Introduction

This script automates the process of creating a service principal and a remote state resources for Terraform.

## Usage

Always start with the 'provision-environment.sh' script, the following is a list of parameters used by the script.
Parameter | Description | Default value | Required
----------|-------------|---------------|----------
-a \|--appname      | The application/instance name     | N/A | Yes
-e \|--env          | The deployment environment for the application (i.e., qa,dev) | dev | No
-f \|--first-run    | The first run would create the Terraform service principal and remote state resources vs reusing the existing ones | N/A | No
-l \|--location     | The Azure location    | centralus | No
-t \|--tenant-name  | The tenant name abbreviation | N/A | Yes

You also need to be logged into your Azure subscription and set a default subscription for the script to use.

Sample usage:

```bash
# Log into Azure
az login

# show your Azure accounts
az account list -o table

# select an Azure account
az account set -s {subscription name or id}
```

## First run, create a new infrastructure
```bash
# Run the script
# Sample: ./provision-environment.sh -a <alias>sp -t cse -f
# Including your alias in <app name> can help reduce environment collisions
app_name=<app name>
tenant_name=<your tenant name>
./provision-environment.sh -a $app_name -t $tenant_name -f
```

## Subsequent runs, update an existing infrastructure
```bash

Make sure 

The following parameters will be used to recreate the `terraform.tfstate` configuration file.

# Run the script, 
# Please note that the following parameters must be the same used when the infrastructure was created the very first time.
# Also note that -f parameter is not specified, this indicates that it is not first run.

app_name=<same app name >
tenant_name=<same tenant name>
location_name=<same location name>
env_name=<same environment name>

./provision-environment.sh -a $app_name -t $tenant_name
```

