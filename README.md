# Einstein Analytics Demo Templates
This repo contains the source for the Einstein Analytics Demo Templates.

## Development Model
Development and testing of the Einstein Analytics Assets should be done using scratch orgs with the repo acting as the source of truth. Once the code is finalized, it should be then either deployed into a Dev org for packaging or else where to be included as a greater deployment.

### Development Flow
[Image]

## Prerequisite
Before trying the steps detailed here, you need the following:
1. A working Salesforce Dev Hub org.
2. Prior experience with Salesforce DX and Salesforce CLI.
3. Basic understanding of Salesforce Einstein Analytics.
4. Setup environment as below.

## Environment Setup
1. Install Salesforce CLI from https://developer.salesforce.com/tools/sfdxcli. Follow the instructions on that page to download.
2. Open a terminal and install the Analytics plugin by running the command `sfdx plugins:install @salesforce/analytics`
3. Authorize a dev hub `sfdx force:auth:web:login -d -a [ALIAS]`
    1. Login to a dev hub and you can close the window

## Usage
1. Clone this repo
2. Run `./orgInit.sh` to create a new Scratch Org with assets from repo. (Scratch Orgs are defaulted to **expire in 1 day**, override with argument `./orgInit.sh 7`)
3. Do your development in the scratch org or VS Code.
    1. Edit dashboards in the org and pull source to local (see step 4i below)
    2. Edit template metadata in VS Code and push source to scratch org and update (see step 4ii below)
4. Use the commands 
    1. `SFDX: Push Source to Org` (VS Code) or `sfdx force:source:push` (Salesforce CLI) to push changes from local into the Scratch Org. For example changes to template metadata (i.e. template-info.json)
    2. `SFDX: Pull Source from Org` (VS Code) or `sfdx force:source:pull` (Salesforce CLI) to pull changes down from Scratch Org to local. For example, dashboard edits.
5. Run `./updateTemplate.sh` to update template with latest changes
6. Sync code with git

### Package Deployment Model (only if releasing through packaging)
1. Use `sfdx force:auth:web:login --setalias [ALIAS]` to add your dev org used for managing the package for this template (First time only)
2. Use the commands `SFDX: Deploy Source to Org` (VS Code) or `sfdx force:source:deploy -u [ALIAS] -p force-app/main/default/waveTemplates/[TEMPLATE NAME]` (Salesforce CLI) to deploy the latest changes to Dev org for packaging
3. Log into Dev org and create/update package with template assets
