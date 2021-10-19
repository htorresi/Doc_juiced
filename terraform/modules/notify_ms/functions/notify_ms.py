# Send a notification the MS teams Deployment channel
# Triggered by SNS to receive pipeline notifications
# Deploy STARTED for byaani-app-develop
from __future__ import print_function
from urllib.error import HTTPError
import urllib.request, urllib.parse
import os, boto3, json, base64
import urllib3 
http = urllib3.PoolManager() 
import logging
import json

# Decrypt encrypted URL with KMS
def decrypt(encrypted_url):
   region = os.environ['AWS_REGION']
   try:
      kms = boto3.client('kms', region_name=region)
      plaintext = kms.decrypt(CiphertextBlob=base64.b64decode(encrypted_url))['Plaintext']
      return plaintext.decode()
   except Exception:
      logging.exception("Failed to decrypt URL with KMS")

def msg_notification(message, region):
   states = {'OK': '64a837', 'INSUFFICIENT_DATA': 'eded0c', 'ALARM': 'd63333'}
   if region.startswith("us-gov-"):
      cloudwatch_url = "https://console.amazonaws-us-gov.com/cloudwatch/home?region="
   else:
      cloudwatch_url = "https://console.aws.amazon.com/cloudwatch/home?region="
   
   logging.warning(message)
   attachments = {
      "@type": "MessageCard",
      "@context": "http://schema.org/extensions",
      "themeColor": states[message['NewStateValue']],
      "title": "AWS CloudWatch notification - " + message["AlarmName"],
      "text": ' ',
      "sections": [{
      "activityTitle": 'Alarm {} triggered'.format(message['AlarmName']), 
      "markdown": True,
      "facts": [
            {
               "name": "Date/Time",
               "value": message['StateChangeTime']
            },
            {
               "name": "Account",
               "value": message['AWSAccountId']
            },      
            {
               "name": "Alarm Name",
               "value": message['AlarmName']
            },
            {
               "name": "Alarm Description",
               "value": message['AlarmDescription']
            },
            {
               "name": "Alarm Reason",
               "value": message['NewStateReason']
            },
            {
               "name": "Old State",
               "value": message['OldStateValue']
            },
            {
               "name": "Current State",
               "value": message['NewStateValue']
            },
            {
               "name": "Link to Alarm",
               "value": cloudwatch_url + region + "#alarm:alarmFilter=ANY;name=" + urllib.parse.quote(message['AlarmName'])
            }
         ],
      }]
   }
   
   return attachments

# Send a message to a microsoft team channel
def notify_ms_teams( message, region):
   region = os.environ['REGION']
   ms_teams_url = os.environ['WEBHOOK_URL']
   # Decript MS Wehbook url
   if not ms_teams_url.startswith("http"):
      ms_teams_url = decrypt(ms_teams_url)
      logging.warning(ms_teams_url)

   if type(message) is str:
      try:
         message = json.loads(message)
      except json.JSONDecodeError as err:
         logging.exception(f'JSON decode error: {err}')
      msg = msg_notification(message,region)
      logging.warning(msg)
      encoded_msg = json.dumps(msg).encode('utf-8')
      logging.warning(message)
      try:
         result = http.request('POST',ms_teams_url, body=encoded_msg)
         logging.warning(result.data.decode('utf-8'))
         return json.dumps({"code": result.status, "info": result.data.decode('utf-8')})
      except HTTPError as e:
         logging.error("{}: result".format(e))
         
   return json.dumps({"code": e.status, "info": e.data.decode('utf-8')})
      
def lambda_handler(event, context):
   if 'LOG_EVENTS' in os.environ and os.environ['LOG_EVENTS'] == 'True':
      logging.warning('Event logging enabled: `{}`'.format(json.dumps(event)))
   
   message = event['Records'][0]['Sns']['Message']
   region = event['Records'][0]['Sns']['TopicArn'].split(":")[3]
   
   response = notify_ms_teams(message,region)
   
   if json.loads(response)["code"] != 200:
      logging.error("Error: received status `{}` using event `{}` and context `{}`".format(json.loads(response)["info"], event, context))

   return response