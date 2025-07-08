#!/usr/bin/sh

# Create random string
guid=$(cat /proc/sys/kernel/random/uuid)
suffix=${guid//[-]/}
suffix=${suffix:0:18}

# Set the necessary variables
RESOURCE_GROUP="rg-dp100-l${suffix}"
REGION="eastus"
WORKSPACE_NAME="mlw-dp100-l${suffix}"
COMPUTE_INSTANCE="ci${suffix}"
COMPUTE_CLUSTER="aml-cluster"


# Create the resource group and workspace and set to default
echo "Create a resource group and set as default:"
az group create --name $RESOURCE_GROUP --location $REGION
az configure --defaults group=$RESOURCE_GROUP


echo "Create an Azure Machine Learning workspace:"
az ml workspace create --name $WORKSPACE_NAME --location $REGION
az configure --defaults workspace=$WORKSPACE_NAME 

# Create compute cluster
echo "Creating a compute cluster with name: " $COMPUTE_CLUSTER
az ml compute create --name ${COMPUTE_CLUSTER} --size STANDARD_DS11_V2 --max-instances 2 --type AmlCompute --location $REGION


# Create data asseta
echo "Creating a data asset with name: diabetes-folder"
az ml data create --name diabetes-folder --path ./data 

# Create components
echo "Creating components"
az ml component create --file ./fix-missing-data.yml 
az ml component create --file ./normalize-data.yml 
az ml component create --file ./train-decision-tree.yml 
az ml component create --file ./train-logistic-regression.yml 
