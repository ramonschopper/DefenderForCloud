# DefenderForCloud

Instructions on how to enable Defender for Cloud at Scale

To provision this deployment to Azure use the following Azure CLI command:
```
az deployment mg create -n policyDeployment -f main.bicep -m b8a53dab-10d3-4ab4-8819-d608f0f31883 -l switzerlandnorth
```

To run this deployment Azure CLI and Bicep must be installed:
```
$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; Remove-Item .\AzureCLI.msi

az bicep install
```



To convert a bicep deployment into Azure Resource Manager Template run the following command:
```
az bicep build --file main.bicep
```