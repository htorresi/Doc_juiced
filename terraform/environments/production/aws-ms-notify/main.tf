provider "aws" {
  region =  var.region
}

# Local variables
locals {
	common_tags = map(
      "Owner", var.owner,
      "Environment", var.environment,
      "App",var.app,
      "Terraform","true"
	)
}

resource "aws_kms_key" "this" {
  description = "KMS key for notify-ms test"
}

# Encrypt the URL, storing encryption here will show it in logs and in tfstate
# https://www.terraform.io/docs/state/sensitive-data.html
resource "aws_kms_ciphertext" "ms_url" {
    plaintext = var.ms_url
    key_id    = aws_kms_key.this.arn
  }

module "notify_ms" {
  source = "../../../modules/notify_ms"

  sns_topic_arn = var.sns_topic_arn

  sns_topic_name = var.sns_topic_name

  lambda_function_name = "${var.app}-notify-ms"

  webhook_url = aws_kms_ciphertext.ms_url.ciphertext_blob

  kms_key_arn = aws_kms_key.this.arn

  lambda_description = var.lambda_description
  log_events         = true

  tags = merge(local.common_tags,map("Name","${var.app}-cloudwatch-alerts-to-ms"))
}

// store the stack state 
terraform {
  backend "s3" {
      bucket         = "terraform-tfstate-947619834730"
      key            = "projects/sellmark/aws-ms-notify" # bucket name for this project/app
      encrypt        = true
      dynamodb_table = "terraform_locks"
      region 				 = "us-east-2"
  }
}