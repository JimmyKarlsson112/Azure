targetScope = 'resourceGroup'

param vmname string
param workspaceid string
@secure()
param workspacekey string 

resource vm 'Microsoft.Compute/virtualMachines@2021-07-01' existing = {
  name: vmname
}

resource oms 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' = {
  name: 'MicrosoftMonitoringAgent'
  parent: vm
  location: resourceGroup().location
   properties: {
      autoUpgradeMinorVersion: true
     // enableAutomaticUpgrade: true
      publisher: 'Microsoft.EnterpriseCloud.Monitoring'
      type: 'MicrosoftMonitoringAgent'
      typeHandlerVersion: '1.0'
      settings: {
        stopOnMultipleConnections: false
        workspaceId: workspaceid
      }
      protectedSettings: {
        workspaceKey: workspacekey
      }
   }
}
