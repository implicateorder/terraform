#!/bin/bash

AWS_ACCESS_KEY_ID=$(cat ~/code/terraform/.secrets |grep ACCESS_KEY_ID|awk -F\: '{print $2}')
AWS_SECRET_ACCESS_KEY=$(cat ~/code/terraform/.secrets|grep SECRET_ACCESS_KEY|awk -F\: '{print $2}')
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
