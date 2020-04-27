#!/bin/zsh
##################################################################################################################
# Script to create source from template
# Created by: Terrence Tse, ttse@salesforce.com
# Last Updated: Apr 21, 2020
##################################################################################################################

# constants
TIMESTAMP=$(date "+%Y%m%d%H%M%S") # timestamp for logging

## echo colors
ERROR='\033[0;31m' # Red
WARN='\033[1;33m' # Yellow
MSG='\033[1;36m' # Light Cyan
NC='\033[0m' # No Color

#variables
SOURCE_ORG_ALIAS='' # Alias of authenticated Source Org to pull template from
PACKAGE_NAME='' # Name of package to retrieve

# Argument Usage
print_usage() {
  echo
    echo "Usage:"
    echo "  retrieveTemplapte.sh -u <TARGSOURCEET ORG ALIAS> -p <PACKAGE NAME> [ -d <DATASETS> ]"
    
    echo "Arguments:"
    echo "    -u    alias of source org to retrieve from"
    echo "    -p    name of package containing templates assets to retrieve"
    echo "    -d    [optional] space delimited list of dataset to extract. eg. DATASET_1 DATASET_2"
    echo "  "
    echo
}

while getopts 'd::p:u:' flag; do
  case "${flag}" in
    d) DATASETS="${OPTARG}";;
    p) PACKAGE_NAME="${OPTARG}";;
    u) SOURCE_ORG_ALIAS="${OPTARG}";;
    *) print_usage
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

# sfdx_temp directory for working files
echo "${MSG}$(date "+%Y-%m-%d %H:%M:%S")|[INFO] Creating sfdx_temp folder...${NC}"
mkdir -p sfdx_temp

sfdx force:mdapi:retrieve -u $SOURCE_ORG_ALIAS -r sfdx_temp -p $PACKAGE_NAME
 
 # uncompress retrieved zip
unzip -o sfdx_temp/unpackaged.zip -d sfdx_temp

echo "${MSG}$(date "+%Y-%m-%d %H:%M:%S")|[INFO] $PACKAGE_NAME package retrieved from $SOURCE_ORG_ALIAS and unzipped to sfdx_temp/.${NC}"

# download datasets as csvs if specified
if [ -z "$DATASETS" ]
then
  echo "${MSG}$(date "+%Y-%m-%d %H:%M:%S")|[INFO] No datasets specified.${NC}"
  exit 0
else
  mkdir -p sfdx_temp/csv/$PACKAGE_NAME/external_files
  arr=("${(@s/ /)DATASETS}")
  for s in "${arr[@]}"; do
    echo "${MSG}$(date "+%Y-%m-%d %H:%M:%S")|[INFO] Downloading dataset: $s${NC}"
    sfdx shane:analytics:dataset:download -u $SOURCE_ORG_ALIAS -t sfdx_temp/csv/$PACKAGE_NAME/external_files -b 10000 -n $s  
  done
  echo "${MSG}$(date "+%Y-%m-%d %H:%M:%S")|[INFO] Datasets downloaded to sfdx_temp/csv/$PACKAGE_NAME/external_files${NC}"
fi
