# Hub and Spoke generated with Github Co-Pilot
Generate a hub and spoke with Expressroute gateway (no connection configured) and a simple VM in the Spoke network

To deploy create a resource group and deploy template
```
New-AzResourceGroup -Name "hubspoke" -Location swedencentral
New-AzResourceGroupDeployment -Name "1" -ResourceGroupName hubspoke -TemplateFile .\main.bicep -Verbose
```

