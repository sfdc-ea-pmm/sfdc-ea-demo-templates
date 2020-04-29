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
2. Open a terminal
    1. Install the Analytics plugin by running the command `sfdx plugins:install @salesforce/analytics`
    2. Install shane-sfdx-plugins for additional functionality `sfdx plugins:install shane-sfdx-plugins`
3. Authorize a dev hub `sfdx force:auth:web:login -d -a [ALIAS]`
    1. Login to a dev hub and you can close the window
4. Authorize any additional orgs with `sfdx force:auth:web:login -a [ALIAS]`
    1. Login to org and you can close the window
5. Check your authorized orgs by running `sfdx force:org:list`
6. Install git-lfs `brew install git-lfs`

## Usage
1. Clone this repo
2. Run `./scripts/initOrg.sh -t [TEMPLATE_API_NAME]` to create a new Scratch Org with assets from repo. (Scratch Orgs are defaulted to **expire in 1 day**, override with argument `./initOrg.sh -d 7`)
3. Do your development in the scratch org or VS Code.
    1. Edit dashboards in the org and pull source to local (see step 4i below)
    2. Edit template metadata in VS Code and push source to scratch org and update (see step 4ii below)
4. Use the commands 
    1. `SFDX: Push Source to Org` (VS Code) or `sfdx force:source:push` (Salesforce CLI) to push changes from local into the Scratch Org. For example changes to template metadata (i.e. template-info.json)
    2. `SFDX: Pull Source from Org` (VS Code) or `sfdx force:source:pull` (Salesforce CLI) to pull changes down from Scratch Org to local. For example, dashboard edits.
5. Run `./scripts/updateTemplate.sh` to update template with latest changes
6. Sync code with git

### Deploy template to non scratch org
1. Use `sfdx force:auth:web:login --setalias [ALIAS]` to add your non scratch org (First time only)
2. Run `./scripts/deployTemplatesNonScratch.sh -u <TARGET ORG ALIAS> -t <TEMPLATE API NAME>` to specified template into target org or Use the command `SFDX: Deploy Source to Org` if using VS Code

### Retreive template from a source org
Use the following to convert an existing app to a template to commit to source control or with the `deployTemplateNoScratch.sh` script this can also be used to migrate assets from one org to another.

#### Preq 
App in source org needs to be converted into a template and packaged first
1. Run `sfdx analytics:app:list -u [SOURCE ORG ALIAS]` to get the list of the apps
2. If the app was created from a template, you'll need to first decouple with `sfdx analytics:app:decouple -u [SOURCE ORG ALIAS] -f [FOLDER ID OF APP] -t [TEMPLATE ID]`
3. Run `sfdx analytics:template:create -u [SOURCE ORG ALIAS] -f [FOLDER ID OF APP]` to create a new template
    1. Or run `sfdx analytics:template:update -u [SOURCE ORG ALIAS] -t [TEMPLATE ID TO UPDATE]` to update an existing template
4. Go to Setup --> Manage Packages and create a new package with the Einstein Analytics assets. No need to upload. 

#### Retrieve the source
1. Run `./scripts/retrieveTemplate.sh -u [SOURCE ORG ALIAS] -p [PACKAGE NAME] -d [DATASETS optional]`
2. Once the script completes, the source for the selected packaged template will be available in the sfdx_temp folder. You will then have to manually move these folders into the `force-app/main/default` folder. There also a couple manual steps that need to be taken:
    1. Move the `external_files` folder into `waveTemplates\[TEMPLATE API NAME]`
    2. Move dataset XMD files into `external_files` from `waveTemplates\dataset_files` if datasets are not created by dataflow
    3. Create datasets schema files, by using Create Dataset UI in Analytics Studio.
        1. Create --> Dataset --> CSV File --> Upload File --> Next --> Make any changes if needed --> Back --> Data Schema File --> Download File
        2. Save file into same folder as CSV file. i.e. `../waveTemplates/[TEMPLATE API NAME]/external_files`
    3. Rename any datasets names that end with a # and update references
    4. Fix dot notations
3. Spin up a scratch org push into an non-scratch org to validate or deploy to a non-scratch org.

