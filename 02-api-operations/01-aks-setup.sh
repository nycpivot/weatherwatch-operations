resource_group=weatherwatch
aks_region_code=eastus
weatherwatch_api_cluster=weatherwatch-api

az group create --name ${resource_group} --location ${aks_region_code}

az aks create --name ${weatherwatch_api_cluster} --resource-group ${resource_group} \
	    --node-count 1 --node-vm-size Standard_B2ms --kubernetes-version 1.28.5 \
	        --enable-managed-identity --enable-addons monitoring --enable-msi-auth-for-monitoring --generate-ssh-keys 

az aks get-credentials --name ${weatherwatch_api_cluster} --resource-group ${resource_group}
