#!/bin/bash
# GZ 2/15/2021
# Usage: ./create_audit_logs [memberAccountId1] [memberAccountId2] ... 

# Use the master acccount profile
if [[ -z "${AWS_PROFILE}" ]]; then
	echo ERROR: AWS_PROFILE is not set
	exit 1
fi

#colors
yellow='\033[1;33m'
green='\033[0;32m'
nc='\033[0m' # No Color

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
region=$(aws configure get ${AWS_PROFILE}.region)

################## Create the Master access log ##################

s3_bucket_access_logs="access-logs-${ACCOUNT_ID}-${region}"

#get canonicalId
canonicalId=$(aws s3api list-buckets --query "Owner.ID")

echo Creating bucket ${s3_bucket_access_logs} in ${region}

# Validate if bucket exists.
s3_bucket_status=$(aws s3 ls "${s3_bucket_access_logs}" 2>&1)

aws s3 ls "s3://${s3_bucket_access_logs}" 2>/dev/null 


if [ $? -eq 0 ]
then
  echo -e "${yellow}Bucket already exists${nc}"
else
  # ignore LocationConstraint i us-east-1
  if [ "${region}" = "us-east-1" ]; then
    aws s3api create-bucket  --region "${region}" --bucket "${s3_bucket_access_logs}" --grant-full-control  id=${canonicalId} --grant-write URI=http://acs.amazonaws.com/groups/s3/LogDelivery --grant-read-acp URI=http://acs.amazonaws.com/groups/s3/LogDelivery
  else
    aws s3api create-bucket  --region "${region}" --bucket "${s3_bucket_access_logs}" --create-bucket-configuration LocationConstraint="${region}" --grant-full-control  id=${canonicalId} --grant-write URI=http://acs.amazonaws.com/groups/s3/LogDelivery --grant-read-acp URI=http://acs.amazonaws.com/groups/s3/LogDelivery
  fi

  echo -e "${green}bucket done!${nc}" 
fi

echo Starting bucket configuration...

# call common config for the bucket created 
source _common_config.sh ${s3_bucket_access_logs}

# build accountId list to create the audit logs for master & member accounts 
accounts_list="${ACCOUNT_ID} ${@}"


# Create the master/member audit logs
for var in $accounts_list
do
  echo Create logs for  account "$var"
  
  ################## Create audit access logs ##################
  
  s3_bucket_audit_access_logs="audit-logs-${var}-${region}-access-logs"
  
  echo Creating bucket ${s3_bucket_audit_access_logs} in ${region}

  # Validate if bucket exists.
  s3_bucket_status=$(aws s3 ls "${s3_bucket_audit_access_logs}" 2>&1)
  
  aws s3 ls "s3://${s3_bucket_audit_access_logs}" 2>/dev/null 

  if [ $? -eq 0 ]
  then
    echo -e "${yellow}Bucket already exists${nc}"
  else
    # ignore LocationConstraint i us-east-1
    if [ "${region}" = "us-east-1" ]; then
      aws s3api create-bucket --region "${region}" --bucket "${s3_bucket_audit_access_logs}" --grant-full-control  id=${canonicalId} --grant-write URI=http://acs.amazonaws.com/groups/s3/LogDelivery --grant-read-acp URI=http://acs.amazonaws.com/groups/s3/LogDelivery
    else
      aws s3api create-bucket --region "${region}" --bucket "${s3_bucket_audit_access_logs}" --create-bucket-configuration LocationConstraint="${region}" --grant-full-control  id=${canonicalId} --grant-write URI=http://acs.amazonaws.com/groups/s3/LogDelivery --grant-read-acp URI=http://acs.amazonaws.com/groups/s3/LogDelivery
    fi

    echo -e "${green}bucket done!${nc}"
  fi

  echo Starting bucket configuration...

  #create file 
  cat > /tmp/logging_audit_access_logs.json <<EOF
{
  "LoggingEnabled": {
    "TargetBucket": "${s3_bucket_access_logs}",
    "TargetPrefix": "${ACCOUNT_ID}",
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

  # Specify permissions for who can view and modify the logging parameters.
  aws s3api put-bucket-logging --bucket "${s3_bucket_audit_access_logs}" --bucket-logging-status file:///tmp/logging_audit_access_logs.json

  echo "put-bucket-logging done!"

  # test get-bucket-logging
  #aws s3api get-bucket-logging --bucket ${s3_bucket_audit_access_logs}

  #echo "get-bucket-logging done!"


  cat > /tmp/policy_audit_access_logs.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${s3_bucket_audit_access_logs}/*",
                "arn:aws:s3:::${s3_bucket_audit_access_logs}"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        }
    ]
}
EOF

  aws s3api put-bucket-policy --bucket "${s3_bucket_audit_access_logs}" --policy file:///tmp/policy_audit_access_logs.json

  echo "put-bucket-policy done!"

  # call common config for the bucket created 
  source _common_config.sh ${s3_bucket_audit_access_logs}


  ################## Create audit log ##################

  s3_bucket_audit_logs="audit-logs-${var}-${region}"

  echo Creating bucket ${s3_bucket_audit_logs} in ${region}
 
  # Validate if bucket exists.
  s3_bucket_status=$(aws s3 ls "${s3_bucket_audit_logs}" 2>&1)

  aws s3 ls "s3://${s3_bucket_audit_logs}" 2>/dev/null 

  if [ $? -eq 0 ]
  then
    echo -e "${yellow}Bucket already exists${nc}"
  else 
    # ignore LocationConstraint i us-east-1
    if [ "${region}" = "us-east-1" ]; then
      aws s3api create-bucket --region "${region}" --bucket "${s3_bucket_audit_logs}" --grant-full-control  id=${canonicalId}
    else
      aws s3api create-bucket --region "${region}" --bucket "${s3_bucket_audit_logs}" --create-bucket-configuration LocationConstraint="${region}" --grant-full-control  id=${canonicalId}
    fi
    echo -e "${green}bucket done!${nc}" 
  fi

  echo Starting bucket configuration...

  # Added policy audit logs only for member accounts
  if [ "${var}" != "${ACCOUNT_ID}" ]; then
  
      cat > /tmp/policy_audit_logs.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheckForConfig",
            "Effect": "Allow",
            "Principal": {
                "Service": "config.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${s3_bucket_audit_logs}"
        },
        {
            "Sid": "AWSCloudTrailWriteForConfig",
            "Effect": "Allow",
            "Principal": {
                "Service": "config.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${s3_bucket_audit_logs}/config/AWSLogs/${var}/Config/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        },
        {
            "Sid": "AWSCloudTrailHeadForConfig",
            "Effect": "Allow",
            "Principal": {
                "Service": "config.amazonaws.com"
            },
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::${s3_bucket_audit_logs}"
        },
        {
            "Sid": "AWSCloudTrailAclCheckForCloudTrail",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${s3_bucket_audit_logs}"
        },
        {
            "Sid": "",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${s3_bucket_audit_logs}/*",
                "arn:aws:s3:::${s3_bucket_audit_logs}"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        },
        {
            "Sid": "AWSCloudTrailAclCheckForConfig",
            "Effect": "Allow",
            "Principal": {
                "Service": "config.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${s3_bucket_audit_logs}"
        },
        {
            "Sid": "AWSCloudTrailWriteForConfig",
            "Effect": "Allow",
            "Principal": {
                "Service": "config.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${s3_bucket_audit_logs}/config/AWSLogs/${var}/Config/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        },
        {
            "Sid": "statement1",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var}:user/admin"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${s3_bucket_audit_logs}/*"
        },
        {
            "Sid": "Stmt1546414471931",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var}:user/admin"
            },
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::${s3_bucket_audit_logs}"
        }
    ]
}

EOF
    
    aws s3api put-bucket-policy --bucket "${s3_bucket_audit_logs}" --policy file:///tmp/policy_audit_logs.json

    rm /tmp/policy_audit_logs.json 
    echo "put-bucket-policy done!"
  
  fi

  #create file 
  cat > /tmp/logging_audit_logs.json <<EOF
{
  "LoggingEnabled": {
    "TargetBucket": "${s3_bucket_audit_access_logs}",
    "TargetPrefix": "",
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

  # Specify permissions for who can view and modify the logging parameters.
  aws s3api put-bucket-logging --bucket "${s3_bucket_audit_logs}" --bucket-logging-status file:///tmp/logging_audit_logs.json

  echo "put-bucket-logging done!"

  # test get-bucket-logging
  #aws s3api get-bucket-logging --bucket ${s3_bucket_audit_logs}

  #echo "get-bucket-logging done!"
 
  # S3 bucket versioning to allow for Terraform state recovery in the case of accidental deletions and human errors
  aws s3api put-bucket-versioning --bucket "${s3_bucket_audit_logs}" \
 	--versioning-configuration Status=Enabled

  echo "put-bucket-versioning enabled done!" 

  # call common config for the bucket created 
  source _common_config.sh ${s3_bucket_audit_logs}

  # eliminate temp files
  rm /tmp/logging_audit_access_logs.json
  rm /tmp/policy_audit_access_logs.json
  rm /tmp/logging_audit_logs.json
done

