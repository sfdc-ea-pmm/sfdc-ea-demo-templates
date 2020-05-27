#!/bin/zsh
##################################################################################################################
# Script to spin up Scratch Org and initialize the org with data for Template being developed
# Created by: Terrence Tse, ttse@salesforce.com
# Last Updated: Apr 21, 2020
##################################################################################################################

# constants
## timestamp
TIMESTAMP=$(date "+%Y%m%d%H%M%S")

## echo colors
ERROR='\033[0;31m' # Red
WARN='\033[1;33m' # Yellow
MSG='\033[1;36m' # Light Cyan
NC='\033[0m' # No Color

#variables
## Default org duration to 5 day if argument not set
ORG_DURATION=1

## Template to edit
TEMPLATE_API_NAME=''

# Argument Usage
print_usage() {
  echo
    echo "Usage:"
    echo "  initOrg.sh -d <DURATION> -t <TEMPLATE API NAME>"
    echo
    echo "Arguments:"
    echo "    -t    template api name to deploy, should be same as folder name under waveTemplates/"
    echo "    -d    [optional] set scratch org duration [default: $ORG_DURATION"
    echo
}

while getopts 'd::t:' flag; do
  case "${flag}" in
    d) ORG_DURATION="${OPTARG}" ;;
    t) TEMPLATE_API_NAME="${OPTARG}" ;;
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

# print args
echo "ORG_DURATION=${WARN}$ORG_DURATION${NC} TEMPLATE_API_NAME=${WARN}$TEMPLATE_API_NAME${NC}"

# sfdx_temp directory for working files
echo "${MSG}$(date "+%Y-%m-%d %H:%M:%S")|[INFO] Creating sfdx_temp folder...${NC}"
mkdir -p sfdx_temp

# create scratch org
echo "${MSG}$(date "+%Y-%m-%d %H:%M:%S")|[INFO] Creating Scratch Org with Duration: $ORG_DURATION Day(s)...${NC}"
sfdx force:org:create -f config/project-scratch-def.json -s -d $ORG_DURATION -w 60

# push source
echo "${MSG}$(date "+%Y-%m-%d %H:%M:%S")|[INFO] Pushing source...${NC}"
sfdx force:source:push -f

# load demo/testing Data
echo "${MSG}$(date "+%Y-%m-%d %H:%M:%S")|[INFO] Loading Demo/Testing Data...${NC}"
#prep unique Username in User csv
sed "s/{TIMESTAMP}/$TIMESTAMP/g" data/core/User.csv > sfdx_temp/User_Load.csv

## load csvs into core objects
sfdx force:data:bulk:upsert -s UserRole -f data/core/UserRole.csv -i Name -w 2
sfdx force:data:bulk:upsert -s User -f sfdx_temp/User_Load.csv -i External_Id__c -w 2
sfdx force:data:bulk:upsert -s Account -f data/core/Account.csv -i External_Id__c -w 5
sfdx force:data:bulk:upsert -s Opportunity -f data/core/Opportunity.csv -i External_Id__c -w 5

sfdx force:data:record:create -s Task -v "Subject='Sample Task'"
sfdx force:data:record:create -s Event -v "Subject='Sample Call' DurationInMinutes='1' ActivityDateTime='2019-01-01'"

sfdx force:data:record:create -s Case -v "Subject='Sample Case'"

sfdx force:data:record:create -s Campaign -v "Name='Sample Campaign'"

#sfdx force:data:record:create -s CampaignMember -v "LastName='Sample CampaignMember'"

sfdx force:data:record:create -s Lead -v "LastName='Sample Lead' Company='Sample Company'"

sfdx force:data:record:create -s Contact -v "LastName='Sample Contact'"

# clean up
echo "${MSG}$(date "+%Y-%m-%d %H:%M:%S")|[INFO] Clean up...${NC}"
rm -f sfdx_temp/User_Load.csv

# get template ID
TEMPLATE_ID="$(sfdx analytics:template:list | grep $TEMPLATE_API_NAME | sed 's/  /,/g' | cut -d ',' -f2)"

# create MASTER app
echo "${MSG}$(date "+%Y-%m-%d %H:%M:%S")|[INFO] Creating App with Template ID: $TEMPLATE_ID...${NC}"
echo "${MSG}$(date "+%Y-%m-%d %H:%M:%S")|[INFO] Please be patient, it may take up to 15m${NC}"
sfdx analytics:app:create -t $TEMPLATE_ID -w 15

# Check app creation status
echo "${MSG}$(date "+%Y-%m-%d %H:%M:%S")|[INFO] Checking status of app creation...${NC}"
app_create_status="$(sfdx analytics:app:list | grep $TEMPLATE_API_NAME | sed 's/  /,/g' | cut -d ',' -f4)"
    
if [ "$app_create_status" == "completedstatus" ];
then
    echo "${MSG}$(date "+%Y-%m-%d %H:%M:%S")|[INFO] App Created with status: ${app_create_status}"
elif [ "$app_create_status" == "failedstatus" ];
then
    echo "${ERROR}[ERROR] App Creation Failed.${NC}"
    # TODO: Do clean up and delete created org
    exit 1
else
    echo "${ERROR}[ERROR] Unexpected Status: ${app_create_status}"
    # TODO: Do clean up and delete created org
    exit 1
fi

# link folder to template
FOLDER_ID="$(sfdx analytics:app:list | grep $TEMPLATE_API_NAME | sed 's/  /,/g' | cut -d ',' -f3)"
echo "${MSG}$(date "+%Y-%m-%d %H:%M:%S")|[INFO] Linking App with Folder ID: $FOLDER_ID with Template ID: $TEMPLATE_ID...${NC}"
sfdx analytics:template:update -t $TEMPLATE_ID -f $FOLDER_ID

sfdx force:user:password:generate
sfdx force:user:display >> logs/loginInfo_$TIMESTAMP.txt

# open org
echo "${MSG}$(date "+%Y-%m-%d %H:%M:%S")|[INFO] Opening org...${NC}"
sfdx force:org:open -p /analytics/wave/wave.apexp#home