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


# TODO: the secrets should be pushed into KeyVault by this script *not* by terraform.
function create_new_deployment()
{

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
    confirm_action "This will update current infrastructure.  Are you sure?"
  else
    confirm_action "This will create new infrastructure.  Are you sure?"
    create_new_deployment
  fi
fi