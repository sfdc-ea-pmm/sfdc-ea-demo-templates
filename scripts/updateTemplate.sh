#!/bin/zsh
##################################################################################################################
# Automate commands to update template with dashboard changes and pull source from org to local
# Created by: Terrence Tse, ttse@salesforce.com
# Last Updated: Feb 19, 2020
##################################################################################################################

# constants
## API name of template
TEMPLATE_API_NAME="Einstein_Analytics_Starter_Pack"

## echo colors
ERROR='\033[0;31m' # Red
WARN='\033[1;33m' # Yellow
MSG='\033[1;36m' # Lighy Cyan
NC='\033[0m' # No Color

# get template ID
TEMPLATE_ID="$(sfdx analytics:template:list | grep $TEMPLATE_API_NAME | cut -d ' ' -f3)"

# Update Template
echo "${MSG}$(date "+%Y-%m-%d %H:%M:%S")|[INFO] Updating template ID: $TEMPLATE_ID...${NC}"
sfdx analytics:template:update -t $TEMPLATE_ID

# Pull latest source to local
echo "${MSG}$(date "+%Y-%m-%d %H:%M:%S")|[INFO] Pulling latest source to local...${NC}"
sfdx force:source:pull