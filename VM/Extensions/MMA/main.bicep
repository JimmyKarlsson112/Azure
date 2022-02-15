targetScope = 'resourceGroup'

param parAzureservers array =  [
  'azure-server01'
  'azure-server02'
]

param parWorkspaceid string = 'xxx-xxx-xxx-xxx'
@secure()
param parWorkspacekey string = 'xxx-xxx-xxx-xxx'


module vmextension 'vmextension.bicep' = [for server in parAzureservers: {
  name: '${server}-extension'
  params: {
     vmname: server
     workspaceid: parWorkspaceid
     workspacekey: parWorkspacekey
  }
}]

