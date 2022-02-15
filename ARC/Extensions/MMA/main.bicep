targetScope = 'resourceGroup'

param parArcservers array = [
  'arc-server01'
  'arc-server02'
]
param parWorkspaceid string = 'xxx-xxx-xxx-xxx'
@secure()
param parWorkspacekey string = 'xxx-xxx-xxx-xxx'

module arcextension 'arcextension.bicep' = [for server in parArcservers: {
  name: '${server}-extension'
  params: {
     vmname: server
     workspaceid: parWorkspaceid
     workspacekey: parWorkspacekey
  }
}]

