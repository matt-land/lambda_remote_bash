#!/usr/bin/env python3
# requires a set of AWS API keys to be installed
import boto3
import json
import sys
client = boto3.session.Session(profile_name='<fixme>').client('lambda')
try:
    cmd = sys.argv[1]
except:
    cmd = input("Enter bash command: ")
response = client.invoke(
    FunctionName='remote_bash',
    Payload=json.dumps({"Command": cmd}).encode(),
)


decoded = json.loads(response["Payload"].read())
if decoded.get('Response'):
    print(decoded['Response'])
else:
    print(decoded['errorMessage'])
    print(decoded['stackTrace'])
