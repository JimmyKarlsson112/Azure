# MDE

## Deployment ##
To support for MDE rollout. The Linux and Windows holds a bicep template that will rollout MDE.Linux/Windows extension on Arc Servers. 
You will need to gather the onboarding script and convert them to Base64. The scripts can be found in security.microsoft.com portal under 
**Settings--> EndPoints -->Device-->Onboarding**

## Scaleset gotchas ##
Adding the MDE extension to a current scale set, only the new vm instances will get the MDE installed. To remediate current VM instances you need to upgrade them (that will cause them to reboot)

