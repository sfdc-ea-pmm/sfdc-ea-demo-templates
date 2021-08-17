##################################################################################################################
# Script to deploy template to non-scratch org
# Created by: Terrence Tse, ttse@salesforce.com
# Last Updated: Jun 4, 2020
##################################################################################################################

import json,sys,csv,os,re,argparse,logging,requests
from zipfile import ZipFile

from datetime import datetime

# constants
TIMESTAMP=datetime.now().strftime("%Y%m%d%H%M%S") #timestamp
S3_BUCKET_URL='https://ac-sdo-repo.s3-us-west-2.amazonaws.com'

def run(args):
    # print args
    logging.info('TIMESTAMP=%s' % TIMESTAMP)
    logging.info(args)

    logging.info("Creating sfdx_temp folder...")
    os.makedirs("sfdx_temp", exist_ok=True)
    
    logging.info("Deploying static resources...")
    os.system("sfdx force:source:deploy -u {alias} -p {path}".format(
        alias=args.targetuseralias,
        path=os.path.join(args.path, 'staticresources')
    ))

    logging.info("Deploying wave templates...")
    os.system("sfdx force:source:deploy -u {alias} -p {path}".format(
        alias=args.targetuseralias,
        path=os.path.join(args.path, 'waveTemplates', args.template)
    ))

    # logging.info("Uploading additional data...")

    # r = requests.get( ( "%s/%s/%s.zip" % (S3_BUCKET_URL,args.template,args.template) ), allow_redirects=True)
    # open( ('sfdx_temp/%s.zip' % args.template), 'wb').write(r.content)

    # dataset_folder =  ('sfdx_temp/%s' % args.template) 

    # with ZipFile(('sfdx_temp/%s.zip' % args.template), 'r') as zipObj:
    #     # Extract all the contents of zip file in current directory
    #     zipObj.extractall(dataset_folder)

    # for file in os.listdir( dataset_folder ):
    #     datasets_name = file.split(".")[0]
    #     if file.endswith(".csv"):
    #         os.system( ("sfdx shane:analytics:dataset:upload -u %s -n %s_SRC -f %s/%s.csv -m %s/%s.json -a SharedApp" % (args.targetuseralias, datasets_name, dataset_folder, datasets_name, dataset_folder, datasets_name) ))

    if args.createapp:
        # get template ID
        stream = os.popen( ("sfdx analytics:template:list -u %s" % args.targetuseralias) )
        output = stream.read().splitlines()
        header = re.split(r'\s{2,}',output[1])

        for row in output:
            if not (row.startswith("===") or row.startswith("───")):
                rowArr = re.split(r'\s{2,}',row)
                if rowArr[header.index("NAME")] == args.template:
                    template_id = rowArr[header.index("TEMPLATEID")]

        logging.info("Creating App with Template ID: %s..." % template_id)
        logging.info("Please be patient, it may take up to 15 mins")
        
        os.system( ("sfdx analytics:app:create -u %s -t %s -w 15" % (args.targetuseralias,template_id)) )

    logging.info("Source deployed to non-scratch org." )

if __name__ == "__main__":

    logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s',datefmt='%Y-%m-%d %I:%M:%S',level=logging.INFO)
    
    # Create the parser
    my_parser = argparse.ArgumentParser(prog='deployTemplate2NonScratchOrg',description='Deploy Einstein Analytics Template source into non-scratch org')

    # Add the arguments
    my_parser.add_argument('-u','--targetuseralias',required=True,type=str,help='username or alias for the target org; overrides default target org')
    my_parser.add_argument('-t','--template',required=True,type=str,help='specify template (api name) to deploy, should be same as folder name under waveTemplates/.')
    my_parser.add_argument('-c','--createapp',default=False,action='store_true',help='create app after source is deployed')
    my_parser.add_argument('-p','--path',type=str,default='../sfdc-ea-demo-templates/force-app/main/default',help='overide source deploy path')

    run(my_parser.parse_args())