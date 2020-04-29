#!/bin/zsh
##################################################################################################################
# Script to deploy template to non-scratch org
# Created by: Terrence Tse, ttse@salesforce.com
# Last Updated: Apr 26, 2020
##################################################################################################################

# constants
TIMESTAMP=$(date "+%Y%m%d%H%M%S") # timestamp for logging

## echo colors
ERROR='\033[0;31m' # Red
WARN='\033[1;33m' # Yellow
MSG='\033[1;36m' # Light Cyan
NC='\033[0m' # No Color

#variables
CREATE_APP=false #path to source to deploy
TARGET_ORG_ALIAS='' # Alias of authenticated Source Org to pull template from
TEMPLATE_API_NAME='' # Name of package to retrieve
PATH_TO_SOURCE='force-app/main/default/waveTemplates' #path to source to deploy

# Argument Usage
print_usage() {
    echo
    echo "Usage:"
    echo "  deployTemplateNonScratch.sh -u <TARGET ORG ALIAS> -t <TEMPLATE API NAME> [ -c ] [ -p <PATH TO SOURCE> ]"
    echo
    echo "Arguments:"
    echo "    -u    alias of target org to deploy to"
    echo "    -t    template api name to deploy, should be same as folder name under waveTemplates/"
    echo "    -c    [optional] set to create app after source is deployed"
    echo "    -p    [optional] overide path to source to deploy [default: $PATH_TO_SOURCE]"
    echo "e.g. `./scripts/deployTemplateNonScratch.sh -u targetSDO -t Key_Account_Management`"
    echo
}

while getopts 'chp::u:t:' flag; do
  case "${flag}" in
    c)  CREATE_APP=true;;
    p)  PATH_TO_SOURCE="${OPTARG}";;
    u)  TARGET_ORG_ALIAS="${OPTARG}";;
    t)  TEMPLATE_API_NAME="${OPTARG}";;
    h)  print_usage
        exit 0 ;;
    \?) print_usage
        exit 1 ;;
  esac
done

if ((OPTIND == 1))
then
    echo "${WARN}No arguments specified${NC}"
    print_usage
    exit 1
fi

shift $((OPTIND-1))

## delete existing template
# get template ID to delete
#TEMPLATE_ID="$(sfdx analytics:template:list -u $TARGET_ORG_ALIAS | grep $TEMPLATE_API_NAME | sed 's/ \{1,\}/,/g' | cut -d ',' -f2)"

#if [ "$TEMPLATE_ID" == "" ];
#then
#    echo "${MSG}$(date "+%Y-%m-%d %H:%M:%S")|[INFO] No existing template named $TEMPLATE_API_NAME found"
#else
#    echo "${MSG}$(date "+%Y-%m-%d %H:%M:%S")|[INFO] Template ID: $TEMPLATE_ID found.${NC}"
#    read -p " Proceed to delete? [Enter Y/y to proceed] " -n 1 -r
#    echo    # (optional) move to a new line
#    if [[ ! $REPLY =~ ^[Yy]$ ]]
#    then
#        exit 0
#    fi
#    echo "${MSG}$(date "+%Y-%m-%d %H:%M:%S")|[INFO] Deleting Template ID: $TEMPLATE_ID...${NC}"
#    sfdx analytics:template:delete -u $TARGET_ORG_ALIAS -t $TEMPLATE_ID
#fi

# sfdx_temp directory for working files
echo "${MSG}$(date "+%Y-%m-%d %H:%M:%S")|[INFO] Deploying source...${NC}"
sfdx force:source:deploy -u $TARGET_ORG_ALIAS -p $PATH_TO_SOURCE/$TEMPLATE_API_NAME

if [ $CREATE_APP = true ]
then
    # get template ID to create app
    TEMPLATE_ID="$(sfdx analytics:template:list -u $TARGET_ORG_ALIAS | grep $TEMPLATE_API_NAME | sed 's/ \{1,\}/,/g' | cut -d ',' -f2)"

    # create MASTER app
    echo "${MSG}$(date "+%Y-%m-%d %H:%M:%S")|[INFO] Creating App with Template ID: $TEMPLATE_ID...${NC}"
    echo "${MSG}$(date "+%Y-%m-%d %H:%M:%S")|[INFO] Please be patient, it may take up to 15m${NC}"
    sfdx analytics:app:create -u $TARGET_ORG_ALIAS -t $TEMPLATE_ID -w 15
fi