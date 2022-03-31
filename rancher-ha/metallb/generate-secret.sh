#!/bin/bash

kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey=$(openssl rand 128 | openssl enc -base64 -A) --dry-run=client -o yaml > secret.yaml

