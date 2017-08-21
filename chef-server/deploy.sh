#!/bin/sh

#
# Location of the script to upload the ARM templates to a storage account.
# The linked templates reference that storage account to executed 
#
TEMP_UPLOAD=../scripts/template_upload.sh

#
# Make sure the Resource Group is created
#
RG=ahm-chef-rg 
az group create -l westus -n $RG --tags='ahm=dev node=chef' --output=table

#
# Make sure the templates are uploaded to the storage account
# This uploads the files from the current directory
#
$TEMP_UPLOAD=
(cd ../parameters; $TEMP_UPLOAD)

#
# Run the template to get all of the chef VM's create
#--mode Complete 
azure group deployment create --resource-group $RG --parameters-file /home/colsen@DAA.LOCAL/src/ahm-standard-templates/parameters/parameters-DEV.json --template-file template.json --verbose 2>&1 | tee az.log

#
# Increase the size of the boot disks, chef needs /var to be bigger
# There are addition steps to do once the Vm is booted
# See: https://blogs.msdn.microsoft.com/cloud_solution_architect/2016/05/24/step-by-step-how-to-resize-a-linux-vm-os-disk-in-azure-arm/
#
az vm deallocate --resource-group $RG --name ahm-chef-srv
az disk update --resource-group $RG --name ahm-chef-srv-osdisk --size-gb 1024
az vm start --resource-group $RG --name ahm-chef-srv

az vm deallocate --resource-group $RG --name ahm-chef-auto 
az disk update --resource-group $RG --name ahm-chef-auto-osdisk --size-gb 1024
az vm start --resource-group $RG --name ahm-chef-auto 


echo "Need to complete the disks resize by hand"
echo "See: https://blogs.msdn.microsoft.com/cloud_solution_architect/2016/05/24/step-by-step-how-to-resize-a-linux-vm-os-disk-in-azure-arm/"
echo "For the instructions on using fdisk to change the partion and xfs_grow to change the FS"
