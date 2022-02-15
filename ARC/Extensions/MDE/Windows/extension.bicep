/*
SUMMARY: Module for installing the MDE extension
AUTHOR/S: JimmyKarlsson112
VERSION: 1.0.0
*/

targetScope = 'resourceGroup'

param arcserver string
param parBase64 string


resource vm 'Microsoft.HybridCompute/machines@2021-05-20' existing = {
  name: arcserver
}

resource mde 'Microsoft.HybridCompute/machines/extensions@2021-05-20' = {
  name: 'MDE.Windows'
  parent: vm
  location: resourceGroup().location
   properties: {
      autoUpgradeMinorVersion: true
      //enableAutomaticUpgrade: true
      publisher: 'Microsoft.Azure.AzureDefenderForServers'
      type: 'MDE.Windows'
      typeHandlerVersion: '1.0'
      settings: {
        azureResourceId: vm.id
        vNextEnabled: true
      }
      protectedSettings: {
        defenderForEndpointOnboardingScript: parBase64
      }
   }
}
