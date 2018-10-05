#!/bin/bash

az account set --subscription "Ranjith Linux Test Sub"

# delete

rg_name=appsvcbuildrg
acr_name=appsvcbuildacr

az group delete \
    --name $rg_name \
    -y

az acr delete \
    --name $acr_name \
    --resource-group $rg_name 
    
