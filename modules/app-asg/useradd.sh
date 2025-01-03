#!/bin/bash

pip3.11 install ansible hvac &>> /tmp/ansible_install.log

ansible-pull -i localhost, -U https://github.com/Devops-Stage-1/expense-ansible get-secrets.yml -e vault_token=$vault_token -e component=$component -e env=$env &>> /tmp/secrets.log

ansible-pull -i localhost, -U https://github.com/Devops-Stage-1/expense-ansible expense.yml -e @~/secrets.json -e role_name=$component -e env=$env &>> /tmp/$component.log

rm -f ~/*.json