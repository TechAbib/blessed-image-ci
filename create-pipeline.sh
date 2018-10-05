#!/bin/bash

# $1 = node version number
# $2 = github access token

az account set --subscription "Ranjith Linux Test Sub"

node_version="$1"
github_token="$2"

node_version_dash=`echo $node_version | sed 's/\./-/g'`
node_version_blank=`echo $node_version | sed 's/\.//g'`
rg_name=appsvcbuildrg
acr_name=appsvcbuildacr
task_name=node-${node_version_dash}-task
app_name=appsvcbuild-node-${node_version_dash}-app
plan_name=appsvcbuild-plan
webhook_name=appsvcbuildnode${node_version_blank}wh # may have conflicts

acr_password=`az acr credential show --name $acr_name --query passwords[0].value`
acr_password=`echo $acr_password | sed s/\"//g`

# 3. create acr task

az acr task create \
    --registry $acr_name \
    --name $task_name \
    --resource-group $rg_name \
    --image node:${node_version} \
    --context https://github.com/patricklee2/node-ci.git#master:${node_version} \
    --branch master \
    --file Dockerfile \
    --git-access-token $github_token \
    --base-image-trigger-enabled true \
    --commit-trigger-enabled true \
    --no-cache \
    --no-push false \
    --os Linux

az acr task run \
    --registry $acr_name \
    --name $task_name
 
# 4. make webapp

az appservice plan create \
    --name $plan_name \
    --resource-group $rg_name \
    --sku S1 \
    --is-linux

az webapp create \
    -n $app_name \
    -g $rg_name \
    -p $plan_name \
    --runtime "node|8.11"

az webapp config container set \
    --resource-group $rg_name \
    --name $app_name \
    --docker-custom-image-name "$acr_name.azurecr.io/node:${node_version}" \
    --docker-registry-server-url "https://$acr_name.azurecr.io" \
    --docker-registry-server-user $acr_name \
    --docker-registry-server-password $acr_password

az webapp deployment container config \
    --enable-cd true \
    --name $app_name \
    --resource-group $rg_name 

webhook_url=`az webapp deployment container show-cd-url --name $app_name --resource-group $rg_name --query CI_CD_URL`
webhook_url=`echo $webhook_url | sed s/\"//g`

# 5. add the webhook

az acr webhook create \
    --name $webhook_name \
    --resource-group $rg_name \
    --registry $acr_name \
    --actions push \
    --status enabled \
    --uri $webhook_url \
    --scope "node:${node_version}"
    
