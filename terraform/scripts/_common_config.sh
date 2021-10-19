#!/bin/bash
# GZ 2/15/2021
# Usage: 
# Purpose: partial with common config for audit logs.

# gzc Encrypt Terraform Bucket
aws s3api put-bucket-encryption \
--bucket "${1}" \
--server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'

echo "put-bucket-encryption done!"

aws s3api put-public-access-block --bucket ${1} --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

echo "put-public-access-block done!"

cat > /tmp/lifecycle.json <<EOF
{
    "Rules": [
        {
            "ID"      : "access-logs",
            "Status": "Enabled",
            "Filter": {
                "Prefix": "access-logs/"
            },
            "Transitions" : [ {
                "Days"          : 30,
                "StorageClass" : "STANDARD_IA"
            }],
            "Transitions" : [ {
                "Days"          : 60,
                "StorageClass" : "GLACIER"
            }],
            "Expiration" : {
                "Days" : 180
            }
        } 
    ]
}
EOF

aws s3api put-bucket-lifecycle-configuration --bucket ${1} --lifecycle-configuration file:///tmp/lifecycle.json 

echo "put-bucket-lifecycle-configuration done!"

# eliminate temp file
rm /tmp/lifecycle.json
