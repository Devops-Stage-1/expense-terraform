#!/bin/bash

ansible-pull -i localhost, -U https://github.com/Devops-Stage-1/expense-ansible get-secrets.yml -e vault_token=$vault_token -e component=$component -e env=$env

ansible-pull -i localhost, -U https://github.com/Devops-Stage-1/expense-ansible expense.yml -e @~/secrets.json -e role_name=$component -e env=$env

rm -f ~/secrets.json ~/newrelic.json