#!/bin/bash

function print_usage()
{
    echo "Use the _prepare-terraform script with the following options"
    echo "       -h  this help message"
    echo "       -f  first-run  this would create the necessary service principal and resources for Terraform's remote state"
    echo ""
    echo "Note: This scripts is expected to be used as part the ./provision-environment.sh script!"
}

# To have a cross-platform function to change the text to lower text
# zsh on Mac does not support ${var,,}
function to_lower()
{
    echo $(echo "$1" |  tr '[:upper:]' '[:lower:]' )
}

function parse_args()
{
  red=`tput setaf 1`
  green=`tput setaf 2`
  yellow=`tput setaf 3`
  reset=`tput sgr0`
  die() { echo "$*" >&2; exit 2; }  # complain to STDERR and exit with error
  needs_arg() { if [ -z "$OPTARG" ]; then die "No arg for --$OPT option"; fi; }

  # PARSE ARGUMENTS
  # -f - first run

  FIRST_RUN=0
  NO_CLOBBER=0
  while getopts "hf" opt; do
    case ${opt} in
      h ) # process option h
        print_usage
        exit 1
        ;;
      f ) # process option f
        FIRST_RUN=1
        ;;
      n ) # process option n
        NO_CLOBBER=1
        ;;
      ? )
        print_usage
        exit 1
        ;;
    esac
  done

  # echo "FIRST_RUN: $FIRST_RUN"
  # echo "NO_CLOBBER: $NO_CLOBBER"
  # echo ""
}

function validate_environment()
{
  # check if svc_ppl_Name is valid
  Name_Size=${#svc_ppl_Name}
  if [[ $Name_Size -lt 3 || $Name_Size -gt 18 ]]
  then
    echo "Please set svc_ppl_Name first and make sure it is between 5 and 18 characters in length with no special characters."
    echo $svc_ppl_Name
    echo $Name_Size
    exit 1
  fi

  # set enviroment to sp if not set
  if [ -z $svc_ppl_ShortName ]
  then
    export svc_ppl_ShortName=sp
  fi


  # set location to centralus if not set
  if [ -z $svc_ppl_Location ]
  then
    export svc_ppl_Location=centralus
  fi

  # set enviroment to dev if not set
  if [ -z $svc_ppl_Environment ]
  then
    export svc_ppl_Environment=dev
  fi


  if [ -z $svc_ppl_TenantName ]
  then
    export svc_ppl_TenantName=cse
  fi

  # Check length of environment name
  Name_Size=${#svc_ppl_Environment}
  if [[ $Name_Size -gt 4 ]]
  then
    echo "Please make sure 'environment' is < 5 characters in length with no special characters."
    echo $svc_ppl_Environment
    echo $Name_Size
    exit 1
  fi

}

# use the template TF variables file to generate
# a new terraform.tfvars file with this run values.
function create_tfvars()
{
  TF_VARS_FILE_PATH='../enterprise_scale/construction_sets/aks/online/aks_secure_baseline/configuration/terraform.tfvars'

  echo "location=\"$svc_ppl_Location\"" >> $TF_VARS_FILE_PATH
  echo "name=\"$svc_ppl_Name\"" >> $TF_VARS_FILE_PATH
  echo "shortname=\"$svc_ppl_ShortName\"" >> $TF_VARS_FILE_PATH
  echo "env=\"$svc_ppl_Environment\"" >> $TF_VARS_FILE_PATH
  echo "tenant_name=\"$svc_ppl_TenantName\"" >> $TF_VARS_FILE_PATH
  echo "tenant_id=\"$TENANT_ID\"" >> $TF_VARS_FILE_PATH
  echo "subscription_id=\"$SUBSCRIPTION_ID\"" >> $TF_VARS_FILE_PATH
  echo "client_id=\"$CLIENT_ID\"" >> $TF_VARS_FILE_PATH
  echo "client_secret=\"$CLIENT_SECRET\"" >> $TF_VARS_FILE_PATH

  echo -e "${green}\tterraform.tfvars created${reset}"
}

function create_from_keyvault()
{
    # ============== CREATE TFVARS =================

    # store az info into variables
    export TENANT_ID=$(echo $ACCOUNT | jq -r ".tenantId")
    export SUB_ID=$(echo $ACCOUNT | jq -r ".id")

    export CLIENT_SECRET=$(az keyvault secret show --vault-name $KEYVAULT_NAME --name SPTfClientSecret | jq -r ".value")
    export CLIENT_ID=$(az keyvault secret show --vault-name $KEYVAULT_NAME --name SPTfClientId | jq -r ".value")

    if [ $NO_CLOBBER -eq 0 ]
    then
        # create terraform.tfvars and replace template values
        create_tfvars
    fi
}

# TODO: the secrets should be pushed into KeyVault by this script *not* by terraform.
function create_new_deployment()
{
  # ============== CREATE TFVARS =================
  # store az info into variables
  export TENANT_ID=$(echo $ACCOUNT | jq -r ".tenantId")
  export SUBSCRIPTION_ID=$(echo $ACCOUNT | jq -r ".id")
  export CLIENT_SECRET=$(az ad sp create-for-rbac --skip-assignment -n http://${svc_ppl_Name}-sp-${svc_ppl_Environment} --query password -o tsv)
  export CLIENT_ID=$(az ad sp show --id http://${svc_ppl_Name}-sp-${svc_ppl_Environment} --query appId -o tsv)

  create_tfvars

  # ============== SP PERMISSIONS =================
  # TODO: To be addressed in a future issue if we need these MSGraph permissions
  # More info at https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/guides/service_principal_configuration#method-2-api-access-with-admin-consent

  # Get MSGraphId
  export graphId=$(az ad sp list --query "[?appDisplayName=='Microsoft Graph'].appId | [0]" --all)
  graphId=$(eval echo $graphId)
  echo "Service MSGraph AppID: " $graphId

  # Get MSGraph Permission variables

  export appRoleAppReadWriteAll=$(az ad sp show --id $graphId --query "appRoles[?value=='Application.ReadWrite.All'].id | [0]")
  appRoleAppReadWriteAll=$(eval echo $appRoleAppReadWriteAll)
  echo "Application- Application.ReadWrite.All ID: " $appRoleAppReadWriteAll

  export appRoleDirReadAll=$(az ad sp show --id $graphId --query "appRoles[?value=='Directory.ReadWrite.All'].id | [0]")
  appRoleDirReadAll=$(eval echo $appRoleDirReadAll)
  echo "application- Directory.Read.All id:" $appRoleDirReadAll

  # Add App persmission
  az ad app permission add --id $CLIENT_ID --api $graphId --api-permissions $appRoleDirReadAll=Role $appRoleAppReadWriteAll=Role

  # Make permissions effective
  az ad app permission grant --id $CLIENT_ID --api $graphId

  # Admin consent
  # az ad app permission admin-consent --id $CLIENT_ID

  # Add Contributor and User Access Administrator Roles required by CAF
  export servicePrincipalObjId=$(az ad sp show --id $CLIENT_ID --query objectId -o tsv)
  servicePrincipalObjId=$(eval echo $servicePrincipalObjId)
  echo "Service Principal Object ID: " $servicePrincipalObjId

  az role assignment create --assignee $servicePrincipalObjId --role "Contributor" --subscription $SUBSCRIPTION_ID
  az role assignment create --assignee $servicePrincipalObjId --role "User Access Administrator" --subscription $SUBSCRIPTION_ID

  # ============== CREATE RESOURCES =================

  # create tf_state resource group
  echo "Creating the Deployment Resource Group"
  if ! (az group list --output tsv | grep $TFRG_NAME > /dev/null || az group create --name ${TFRG_NAME} --location ${svc_ppl_Location} -o table)
  then
      echo "ERROR: failed to create the resource group"
      exit 1
  fi
  echo "Created Resource Group: ${TFRG_NAME} in ${svc_ppl_Location}"

  # create storage account for state file
  export TFSUB_ID=$(az account show -o tsv --query id)

  # STORAGE ACCOUNT NAME IS BUILT IN validate_environment
  tmp_name="citfstate"
  export TFCI_NAME=$(to_lower $tmp_name)

  echo "Creating Deployment Storage Account and State Container"


  if ! (az storage account list --output tsv | grep $TFSA_NAME > /dev/null || az storage account create --resource-group $TFRG_NAME --name $TFSA_NAME --sku Standard_LRS --encryption-services blob -o table)
  then
      echo "ERROR: Failed to create Storage Account"
      exit 1
  fi
  echo "Storage Account Created."
  sleep 20s

  # retrieve storage account access key
  if ! ARM_ACCESS_KEY=$(az storage account keys list --resource-group $TFRG_NAME --account-name $TFSA_NAME --query [0].value -o tsv)
  then
      echo "ERROR: Failed to Retrieve Storage Account Access Key"
      exit 1
  fi
  echo "Storage Account Access Key retrieved!"

  if ! (az storage container list --account-name $TFSA_NAME | grep $TFCI_NAME > /dev/null || az storage container create --name $TFCI_NAME --account-name $TFSA_NAME --account-key $ARM_ACCESS_KEY -o table)
  then
      echo "ERROR: Failed to Retrieve Storage Container"
      exit 1
  fi
  echo "TF State Storage Account Container Created"
  export TFSA_CONTAINER=$(az storage container show --name ${TFCI_NAME} --account-name ${TFSA_NAME} --account-key ${ARM_ACCESS_KEY} --query name -o tsv)
  echo "TF Storage Container name = ${TFSA_CONTAINER}"

}

############################### MAIN ###################################
parse_args "$@"

validate_environment

if [ $NO_CLOBBER -eq 0 ]
then
  if [ $FIRST_RUN -eq 0 ]
  then
    create_from_keyvault
  else
    confirm_action "This will create new infrastructure.  Are you sure?"
    create_new_deployment
  fi
fi