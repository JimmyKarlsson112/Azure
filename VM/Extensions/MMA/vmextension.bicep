targetScope = 'resourceGroup'

param vmname string = 'test'
param workspaceid string = '6417fc08-ca7f-4609-a065-af9b84b51ec1'
@secure()
param workspacekey string = '12nrFn9qOPDm1MeRPigJtymhpL2rlPuEMll5sdVrhmQzOxdE1YZe1ojxKbPsUCi+gfOcqGpKd10qgtTc1tKt0g=='

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
