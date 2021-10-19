#!/bin/bash
# RJM 2/9/2020 create back-end settings
# must be run an app folder in a project eg client/my-app or infrastructsure/vpc
# file must live in greenmarimba-infrastructure/provisioning/terraform/aws

# NOTE: each app must have its own state
# treat each project as an entirely distinct root configuration
# For overview of this approach see https://github.com/hashicorp/terraform/issues/8404

# NOTE ON STRUCTURE
# It's a little unwieldy to manage an entire stack with one terraform apply... Terraform will need to spend a lot of time refreshing and diffing everything even if you only want to update one project.

# So we treat each client project  as an entirely distinct root configuration. In this model you would remove the top-level main.tf, retaining all of the other module references described in my first suggestion above, and then work with each project directory separately:

# In both cases, some sort of automation (Atlas, Jenkins, etc) can be helpful to ensure that they get run consistently every time.

# In general I would advise breaking your configuration into smaller units (the second suggestion, possibly taking it one step further and having a separate config per application) because it's easier to work with smaller sets of resources than large ones.


# usage: ../../backend_config.sh 
# run this in side the project/environment folder eg terraform/aws/critical-climate/dev

# Tasks to run

# - Create TF state bucket
# - Create Table terraform_locks
# - CLI put-bucket-versioning
# - CLI put-bucket-acl
# - CLI put-bucket-logging
# - CLI put-bucket-policy
# - CLI put-bucket-encryption


if [[ -z "${AWS_PROFILE}" ]]; then
	echo ERROR: AWS_PROFILE is not set
	exit 1
fi

PROJECT_NAME=`basename $(dirname $PWD)`
ENVIRONMENT="${PWD##*/}" # use current dir name
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"

# RJM 3/25/20 get region
region=$(aws configure get ${AWS_PROFILE}.region)
# RJM 3/25/20 set bucket
#gzc 11/30/2020 #29 - Removed region to build the bucketname.
s3_bucket="terraform-tfstate-${ACCOUNT_ID}"
s3_bucket_status=$(aws s3 ls "${s3_bucket}" 2>&1)

echo Checking state bucket ${s3_bucket}...
aws s3 ls "s3://${s3_bucket}" 2>/dev/null 
if [ $? -eq 0 ]
then
  echo "ERROR: State Bucket already exists"
  exit
else
  echo "State bucket does not exist, continuing"
fi
printf "\n"


echo Creating TF state bucket ${s3_bucket}/projects/${PROJECT_NAME}/${ENVIRONMENT} in ${region}
read -n1 -r -p "Press space to continue..." key

# ignore LocationConstraint i us-east-1
if [ "${region}" = "us-east-1" ]; then
  aws s3api create-bucket --region "${region}" --bucket "${s3_bucket}"
else
  aws s3api create-bucket --region "${region}" --bucket "${s3_bucket}" --create-bucket-configuration LocationConstraint="${region}"
fi

echo "tf state bucket done!" 
# hgb #8 16/02/21 - Do not specific region in the following
# script if the region is 'us-east-1'
if [ "${region}" = "us-east-1" ]; then
aws dynamodb create-table \
	--table-name terraform_locks \
	--attribute-definitions AttributeName=LockID,AttributeType=S \
	--key-schema AttributeName=LockID,KeyType=HASH \
	--provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1
else
aws dynamodb create-table \
	--region "${region}" \
	--table-name terraform_locks \
	--attribute-definitions AttributeName=LockID,AttributeType=S \
	--key-schema AttributeName=LockID,KeyType=HASH \
	--provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1
fi

echo "dynamodb table done!"   

cat <<EOF > ./_backend_config.tf.snippet
# snippet for terraform backend state on S3
# add this to the end of main.tf for all main.tf in each apps/service folder
# Generated on `date +%F_%T` 
# from ${PWD}
terraform {
  backend "s3" {
    bucket         = "${s3_bucket}"
    key            = "projects/${PROJECT_NAME}/${ENVIRONMENT}/\[IMPORTANT-set-service-name\]" # bucket name for this project/app
    encrypt        = true
    dynamodb_table = "terraform_locks"
		region 				 = "${AWS_DEFAULT_REGION}"
  }
}
EOF

echo "See ./_backend_config.tf.snippet"

# S3 bucket versioning to allow for Terraform state recovery in the case of accidental deletions and human errors
# TODO RJM 4/2/2020 Need to implement!
aws s3api put-bucket-versioning --bucket "${s3_bucket}" \
 	--versioning-configuration Status=Enabled

echo "put-bucket-versioning done!" 

# gzc 11/30/2020 #29 - Enable Teraaform S3 Access Logging
aws s3api put-bucket-acl --bucket "${s3_bucket}" \
--grant-write URI=http://acs.amazonaws.com/groups/s3/LogDelivery --grant-read-acp URI=http://acs.amazonaws.com/groups/s3/LogDelivery

echo "put-bucket-acl done!" 

#get canonicalId
canonicalId=$(aws s3api list-buckets --query "Owner.ID")

#create file 
cat > /tmp/logging.json <<EOF
{
  "LoggingEnabled": {
    "TargetBucket": "${s3_bucket}",
    "TargetPrefix": "terraform/",
    "TargetGrants": [
      {
        "Grantee": {
          "Type": "CanonicalUser",
          "ID": ${canonicalId}
        },
        "Permission": "FULL_CONTROL"
      }
    ]
  }
}
EOF

# gzc 11/30/2020 #29 - Specify permissions for who can view and modify the logging parameters.
aws s3api put-bucket-logging --bucket "${s3_bucket}" --bucket-logging-status file:///tmp/logging.json

echo "put-bucket-logging done!" 

# gzc 11/30/2020 #29 - Checks whether S3 buckets have policies that require requests to use Secure Socket Layer (SSL)
#create file 
cat > /tmp/policy.json <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Effect":"Allow",
      "Principal":{
      "AWS":"arn:aws:iam::${ACCOUNT_ID}:root"
    },
    "Action":"s3:Get*",
    "Resource":"arn:aws:s3:::${s3_bucket}/*"},
    {
      "Effect":"Deny",
      "Principal":"*",
      "Action":"*",
      "Resource":"arn:aws:s3:::${s3_bucket}/*",
      "Condition":{
        "Bool":
        {
          "aws:SecureTransport":"false"
        }
      }
    }
  ]
}
EOF

aws s3api put-bucket-policy --bucket "${s3_bucket}" --policy file:///tmp/policy.json

echo "put-bucket-policy done!" 

# gzc 11/30/2020 #29 - Encrypt Terraform Bucket
aws s3api put-bucket-encryption \
--bucket "${s3_bucket}" \
--server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'

echo "put-bucket-encryption done!"

rm /tmp/logging.json 
rm /tmp/policy.json 