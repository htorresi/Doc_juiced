variable "region" {
   type        = string
   description = "AWS region"
   default     = "us-east-2"
}

variable "profile" {
   type        = string
   description = "AWS profile"
   default     = "sellmark-prod"
}

variable "owner" {
   type        = string
   description = "Owner name of the resource to create."
   default     = "audit"
}

variable "environment" {
   type        = string
   default     = "production"
}

variable "app" {
   type        = string
   default     = "sellmark" 
}

variable "ms_url" {
   default = "https://sellmark.webhook.office.com/webhookb2/f5eed9fc-ad66-47b2-9736-a9e3201af9b2@d79506fa-3d5f-4579-be69-5e81462cdd8a/IncomingWebhook/212d8e8e411442a589923fa3915c045b/18aa369d-788b-42f0-864e-cb39ed34e89e"
}

variable "sns_topic_name"{
   default = "ms-aws-notifications-topic"
}

variable "lambda_description"{
   default = "Lambda function which sends notifications to ms"
}

variable "sns_topic_arn"{
   default = "arn:aws:sns:us-east-2:947619834730:CISAlarm"
}

