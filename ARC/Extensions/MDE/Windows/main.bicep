/*
SUMMARY: Executes a forloop over all specified Azure Arc machines to install MDE extension for Linux servers
DESCRIPTION: Important to note is that you will have to remove a failed MDE extension before deploying
AUTHOR/S: JimmyKarlsson112
VERSION: 1.0.0
*/

targetScope = 'resourceGroup'

param parArcServers array =  [
  'server1'
  'server2'
]
//Deployment string can be found by onboarding scrupt in security.microsoft.com portal for Linux servers - convert to base64 and pase here
param parBase64 string

module vmextension 'extension.bicep' = [for arcserver in parArcServers: {
  name: '${arcserver}-mde-deployment'
  params: {
    arcserver: arcserver
    parBase64: parBase64
  }
}]

