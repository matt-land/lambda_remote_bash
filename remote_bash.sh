#!/usr/bin/env bash
# requires aws cli tools
# and a set of AWS API keys to be installed
if [ -z ${1} ]; then
  echo "Error: command required"
  echo "usage: remote_bash.sh \"command -arg1 -arg2\""
  exit 1
fi
eval "aws lambda invoke --function-name remote_bash --payload '{\"Command\": \"$1\"}' ./temp.out > /dev/null 2>&1"
# echo $STR
cat ./temp.out | python -c 'import json, sys; obj=json.load(sys.stdin); print(obj["Response"])'
rm ./temp.out
