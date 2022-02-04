# MDE

## Deployment ##
To support for MDE rollout. The Linux and Windows holds a bicep template that will rollout MDE.Linux/Windows extension on Arc Servers. 
You will need to gather the onboarding script and convert them to Base64. The scripts can be found in security.microsoft.com portal under 
**Settings--> EndPoints -->Device-->Onboarding**

## Troubleshooting ##
To gather any failed attempts and error message, utilize Get-ArcFailedMDE.ps1 that will gather all error messages for failed MDE extension and save to either Excel or CSV file.