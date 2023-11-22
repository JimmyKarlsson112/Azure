
param location string = 'swedencentral'
param vmSize string = 'Standard_DS2_v2'
param availabilitySetName string = 'myAvailabilitySet'
@secure()
param password string

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: 'myVNet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: 'mySubnet'
  parent: vnet
  properties: {
    addressPrefix: '10.0.0.0/24'
  }
}

resource availabilitySet 'Microsoft.Compute/availabilitySets@2023-07-01' = {
  name: availabilitySetName
  location: location
  sku: {
    name: 'Aligned'
  }
  properties: {
    platformFaultDomainCount: 2
    platformUpdateDomainCount: 2
    proximityPlacementGroup: {
      id: proximityPlacementGroup.id
    }
  }
}

//write a proximity group
resource proximityPlacementGroup 'Microsoft.Compute/proximityPlacementGroups@2023-07-01' = {
  name: 'myProximityPlacementGroup'
  location: location
  properties: {
    proximityPlacementGroupType: 'Standard'
    intent: {
       vmSizes: [
         vmSize
       ]
    }
  }
  zones: [
    1
    ]
}



resource vm1 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: 'vm1'
  location: location
  dependsOn: [
    vnet
    subnet
    availabilitySet
  ]
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
    }
    osProfile: {
      computerName: 'vm1'
      adminUsername: 'adminUser'
      adminPassword: password
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', 'myNIC1')
        }
      ]
    }
    availabilitySet: {
      id: availabilitySet.id
    }
  }
}

resource vm2 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: 'vm2'
  location: location
  dependsOn: [
    vnet
    subnet
    availabilitySet
  ]
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
    }
    osProfile: {
      computerName: 'vm2'
      adminUsername: 'adminUser'
      adminPassword: password
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', 'myNIC2')
        }
      ]
    }
    availabilitySet: {
      id: availabilitySet.id
    }
  }
}

resource vm3 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: 'vm3'
  location: location
  zones: [
    2
  ]
  dependsOn: [
    vnet
    subnet
  ]
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
    }
    osProfile: {
      computerName: 'vm3'
      adminUsername: 'adminUser'
      adminPassword: password
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', 'myNIC3')
        }
      ]
    }
  }
}

resource nic1 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: 'myNIC1'
  location: location
  dependsOn: [
    vnet
    subnet
  ]
  properties: {
    ipConfigurations: [
      {
        name: 'myIPConfig1'
        properties: {
          subnet: {
            id: subnet.id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource nic2 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: 'myNIC2'
  location: location
  dependsOn: [
    vnet
    subnet
  ]
  properties: {
    ipConfigurations: [
      {
        name: 'myIPConfig2'
        properties: {
          subnet: {
            id: subnet.id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource nic3 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: 'myNIC3'
  location: location
  dependsOn: [
    vnet
    subnet
  ]
  properties: {
    ipConfigurations: [
      {
        name: 'myIPConfig3'
        properties: {
          subnet: {
            id: subnet.id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}
