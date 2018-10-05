#!/bin/bash

# $1 = github access token

az account set --subscription "Ranjith Linux Test Sub"

# 1. create github personal access token
# https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/

github_token="$1"

# 2. create acr repo

rg_name=appsvcbuildrg
acr_name=appsvcbuildacr

az group create \
    --name $rg_name \
    --location westus2

az acr create \
    --name $acr_name \
    --resource-group $rg_name \
    --sku Premium \
    --admin-enabled true \
    --location westus2

acr_password=`az acr credential show --name $acr_name --query passwords[0].value`
acr_password=`echo $acr_password | sed s/\"//g`
