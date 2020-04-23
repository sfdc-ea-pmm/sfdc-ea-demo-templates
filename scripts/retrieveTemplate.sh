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
  printf "Usage: ..."
}

while getopts 'p:s:' flag; do
  case "${flag}" in
    p) PACKAGE_NAME="${OPTARG}";;
    s) SOURCE_ORG_ALIAS="${OPTARG}";;
    *) print_usage
       exit 1 ;;
  esac
done

# sfdx_temp directory for working files
echo "${MSG}$(date "+%Y-%m-%d %H:%M:%S")|[INFO] Creating sfdx_temp folder...${NC}"
mkdir sfdx_temp

sfdx force:mdapi:retrieve -u $SOURCE_ORG_ALIAS -r sfdx_temp -p $PACKAGE_NAME
 
unzip -o sfdx_temp/unpackaged.zip -d sfdx_temp

echo "${MSG}$(date "+%Y-%m-%d %H:%M:%S")|[INFO] $PACKAGE_NAME package retrieved from $SOURCE_ORG_ALIAS and unzipped to sfdx_temp/. Manaully merge into force-app/main/default.${NC}"