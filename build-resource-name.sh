#!/bin/bash

# THIS NAMING FILE MUST BE KEPT IN SYNC WITH ANY NAMING CONVENTIONS ENCODED IN TERRAFORM CODE

function print_usage()
{
    echo "Usage: build-resource-name with options "
    echo "       -h  this help message"
    echo "       -r  <resource type> (resourcegroup, storageaccount, cosmosaccount, keyvault, containerregistry)"
    echo "       -n  <application name> "
    echo "       -e  <environment> "        
    echo "       -t  <tenant abbrev name> "
}

# To have a cross-platform function to change the text to lower text
# zsh on Mac does not support ${var,,}
function to_lower()
{
    echo $(echo "$1" |  tr '[:upper:]' '[:lower:]' )
}

TYPE=""
NAME=""
ENV=""
TENANT=""

while getopts "hr:n:e:t:v" opt; do
    case ${opt} in
      h ) # process option h
        print_usage
        exit 1
        ;;
      r ) # process option t
        TYPE=${OPTARG}
        ;;
      n ) # process option n
        NAME=${OPTARG}
        ;;
      e ) # process option n
        ENV=${OPTARG}
        ;;
      t ) # process option n
        TENANT=${OPTARG}
        ;;
      ? ) 
        echo "Unrecognized option for build-resource-name.sh!"
        print_usage
        exit 1
        ;;
    esac
done

if [ -z $TYPE ]
then
    echo "Missing resource type"
    exit 1
fi

if [ -z $NAME ]
then
    echo "Missing resource name"
    exit 1
fi

if [ -z $ENV ]
then
    echo "Missing environment name"
    exit 1
fi

if [ -z $TENANT ]
then
    echo "Missing tenant name"
    exit 1
fi

case $TYPE in 
    resourcegroup )
        echo "rg-$(to_lower $NAME)-$(to_lower $TENANT)-$(to_lower $ENV)"
        ;;
    storageaccount )
        echo "$(to_lower $NAME)$(to_lower $TENANT)$(to_lower $ENV)"
        ;;
    cosmosaccount )
        echo "cdb-$(to_lower $NAME)-$(to_lower $TENANT)-$(to_lower $ENV)"
        ;;
    keyvault )
        echo "kv-$(to_lower $NAME)-$(to_lower $TENANT)-$(to_lower $ENV)"
        ;;
    containerregistry )
        echo "$(to_lower $NAME)$(to_lower $TENANT)$(to_lower $ENV)"
        ;;
    functionapp )
        echo "fa-$(to_lower $NAME)-$(to_lower $TENANT)-$(to_lower $ENV)"
        ;;        
esac
exit 0