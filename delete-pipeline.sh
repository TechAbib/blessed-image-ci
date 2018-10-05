#!/bin/bash

# $1 = stack, php or node
# $1 = version number

az account set --subscription "Ranjith Linux Test Sub"

# delete

stack="$1"
version="$2"
version_dash=`echo $version | sed 's/\./-/g'`
version_blank=`echo $version | sed 's/\.//g'`
rg_name=appsvcbuildrg
acr_name=appsvcbuildacr
plan_name=appsvcbuild-plan

image_name=${stack}:${version}
task_name=appsvcbuild-${stack}-hostingstart-${version-dash}-task
site_name=appsvcbuild-${stack}-hostingstart-${version_dash}-site
webhook_name=appsvcbuild${stack}hostingstart${version_blank}wh

app_image_name=${stack}app:${version}
app_task_name=appsvcbuild-${stack}-app-${version-dash}-task
app_site_name=appsvcbuild-${stack}-app-${version_dash}-site
app_webhook_name=appsvcbuild${stack}app${version_blank}wh

az acr repository delete \
    --name $acr_name \
    --image $image_name \
    --yes

az acr task delete \
    --registry $acr_name \
    --name $task_name

az webapp delete \
    -n $site_name \
    -g $rg_name 

az acr webhook delete \
    --registry $acr_name \
    --name $webhook_name \
    --resource-group $rg_name 

az acr repository delete \
    --name $acr_name \
    --image $app_image_name \
    --yes

az acr task delete \
    --registry $acr_name \
    --name $app_task_name

az webapp delete \
    -n $app_site_name \
    -g $rg_name 

az acr webhook delete \
    --registry $acr_name \
    --name $app_webhook_name \
    --resource-group $rg_name 
