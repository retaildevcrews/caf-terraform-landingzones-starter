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

# Run the script
# Sample: ./provision-environment.sh -a testsp -t cse -f
./provision-environment.sh -a <myapp> -t <your tenant name> -f
```