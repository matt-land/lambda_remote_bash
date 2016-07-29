from __future__ import print_function

import json, subprocess

def lambda_handler(event, context):
    command = event['Command']
    print (command)
    out = subprocess.check_output(command, shell=True)
    return {"Response": out}