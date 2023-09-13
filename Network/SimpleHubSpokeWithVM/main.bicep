//Simple hub and spoke setup with ER Gateway generated by github copilot

@secure()
param vmpassword string
param vmuser string = 'azureuser'

// write a virtual network resource in bicep with gatewaysubnet and route server subnet
resource hub 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: 'hub'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/23'
      ]
      }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.0.0.0/26'
        }
      }
      {
        name: 'RouteServerSubnet'
        properties: {
          addressPrefix: '10.0.0.64/26'
        }
      }
      {
        name: 'vm'
        properties: {
          addressPrefix: '10.0.1.0/26'
        }
      }
    ]
    }
  }

// write a virtual network peering resource in bicep
resource hubtospoke 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-02-01' = {
  name: 'hubtospoke'
  parent: hub
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: spoke.id
    }
  }
}

resource spoketohub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-02-01' = {
  name: 'spoketohub'
  parent: spoke
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: hub.id
    }
  }
}


// write a virtual network resource in bicep with gatewaysubnet and route server subnet
resource spoke 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: 'spoke'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.2.0.0/23'
      ]
      }
    subnets: [
      {
        name: 'vm'
        properties: {
          addressPrefix: '10.2.0.0/26'
        }
      }
    ]
    }
  }

  resource gwhubrouteserverPublicIP 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
    name: 'hub-pip-gw'
    location: resourceGroup().location
    sku: {
      name: 'Standard'
       tier: 'Regional'
    }
     zones: [
      1
      2
      3
     ]
    properties: {
      publicIPAllocationMethod: 'Static'
      publicIPAddressVersion: 'IPv4'
    }
  }

  // write a virtual network gateway resource in bicep for expressroute



  // write a virtual network gateway resource in bicep
resource hubGateway 'Microsoft.Network/virtualNetworkGateways@2021-02-01' = {
  name: 'hubGateway'
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'ErGw1AZ'
      tier: 'ErGw1AZ'
    }
    gatewayType: 'ExpressRoute'
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
           publicIPAddress: {
             id: gwhubrouteserverPublicIP.id
           }
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${hub.id}/subnets/GatewaySubnet'
          }
        }
      }
    ]
  }
}



  //write a nic in bicep in spoke network with private IP
resource spokenic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: 'nic'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: '${spoke.id}/subnets/vm'
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

  //write a virtual machine in spoke subnet without public IP
resource spokevm 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: 'spokevm'
  location: resourceGroup().location
  properties: {
     hardwareProfile: {
       vmSize: 'Standard_B1s'
     }
      osProfile: {
         adminPassword: vmpassword
          adminUsername: vmuser
           computerName: 'spokevm'
      }
       storageProfile: {
         osDisk: {
          createOption: 'FromImage'
         }
          imageReference: {
             offer: 'UbuntuServer'
              publisher: 'Canonical'
               sku: '18.04-LTS'
                version: 'latest'
          }
       }
      networkProfile: {
         networkInterfaces: [
           {
             id: spokenic.id
           }
         ]
      }
  }
}
