targetScope = 'resourceGroup'

param vmname string

resource vm 'Microsoft.Compute/virtualMachineScaleSets@2021-11-01' existing = {
  name: vmname
}

resource mde 'Microsoft.Compute/virtualMachineScaleSets/extensions@2021-11-01' = {
  name: 'MDE.Linux'
  parent: vm
  location: vm.location
   properties: {
      autoUpgradeMinorVersion: true
      //enableAutomaticUpgrade: true
      publisher: 'Microsoft.Azure.AzureDefenderForServers'
      type: 'MDE.Linux'
      typeHandlerVersion: '1.0'
      settings: {
        azureResourceId: vm.id
      }
      protectedSettings: {
        defenderForEndpointOnboardingScript: ''
      }
   }
}
