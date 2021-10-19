#gzc 02/09/2021 #35 - Proyect SB - daloopa master
provider "aws" {
  region  =  var.region
  profile = "sellmark"
  version = ">= 0.13.5" 
}

data "aws_caller_identity" "current" {}

# Specifies object tags key and value. This applies to all resources created by this module.
locals {
  tags = {
      Owner       = data.aws_caller_identity.current.user_id
      Environment = "master"
      Name        = "Secure Baseline"
      Terraform   = true
      Purpose     = "Secure baseline configuration based on CIS Amazon Web Services Foundations."
    }
}

module "secure_baseline" {
  source                                      = "nozaq/secure-baseline/aws"
  version                                     = "0.23.1"
  account_type                                = var.account_type
  # Bucket name must be unique in the account where it will created.
  audit_log_bucket_name                       = "audit-logs-${data.aws_caller_identity.current.account_id}-${var.region}"
  aws_account_id                              = data.aws_caller_identity.current.account_id
  region                                      = var.region
  support_iam_role_principal_arns             = var.support_iam_role_principal_arns
  #start password properties
  allow_users_to_change_password              = var.allow_users_to_change_password #true
  minimum_password_length                     =	var.minimum_password_length #14
  max_password_age                            = var.max_password_age #90
  password_reuse_prevention                   = var.password_reuse_prevention #24
  require_lowercase_characters                = var.require_lowercase_characters #true
  require_numbers                             = var.require_numbers #true
  require_symbols                             = var.require_symbols #true
  require_uppercase_characters                = var.require_uppercase_characters #true
  create_password_policy                      = var.create_password_policy #true
  #end password properties

  #guardduty invitation
  member_accounts                             = var.member_accounts
  guardduty_disable_email_notification        = var.guardduty_disable_email_notification


  audit_log_lifecycle_glacier_transition_days = var.audit_log_lifecycle_glacier_transition_days #90
  cloudtrail_cloudwatch_logs_group_name       = "CISBenchmark"
  tags                                        = local.tags
  # Setting it to true means all audit logs are automatically deleted
  #   when you run `terraform destroy`.
  # Note that it might be inappropriate for highly secured environment.
  audit_log_bucket_force_destroy              = var.audit_log_bucket_force_destroy #false
  providers = {
    aws                = aws
    aws.ap-northeast-1 = aws.ap-northeast-1
    aws.ap-northeast-2 = aws.ap-northeast-2
    aws.ap-south-1     = aws.ap-south-1
    aws.ap-southeast-1 = aws.ap-southeast-1
    aws.ap-southeast-2 = aws.ap-southeast-2
    aws.ca-central-1   = aws.ca-central-1
    aws.eu-central-1   = aws.eu-central-1
    aws.eu-north-1     = aws.eu-north-1
    aws.eu-west-1      = aws.eu-west-1
    aws.eu-west-2      = aws.eu-west-2
    aws.eu-west-3      = aws.eu-west-3
    aws.sa-east-1      = aws.sa-east-1
    aws.us-east-1      = aws.us-east-1
    aws.us-east-2      = aws.us-east-2
    aws.us-west-1      = aws.us-west-1
    aws.us-west-2      = aws.us-west-2
  }
} 

# snippet for terraform backend state on S3
# add this to the end of main.tf for all main.tf in each apps/service folder

terraform {
  backend "s3" {
    bucket         = "terraform-tfstate-947619834730"
    key            = "projects/sellmark/global/organization/master" # bucket name for this project/app
    encrypt        = true
    dynamodb_table = "terraform_locks"
		region 				 = "us-east-2" #N.Virginia
  }
}