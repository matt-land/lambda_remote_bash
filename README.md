# Remote Bash 

### This is a demo of running arbitrary bash commands on AWS lambda, which is helpful in exploring the platform.


Create a python lambda called "remote_bash", and paste in the lambda_function.py code.
A sample config is provided.
Install aws cli tools if you haven't.
Run aws configure if you haven't.

## Usage:
./remote_bash.sh "df -h"
