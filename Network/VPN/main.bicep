
@description('CIDR block representing the address space of the Azure VNet')
param location string =  resourceGroup().location

@description('Base prefix of all resources')
param BaseName string 

@description('CIDR block representing the address space of the Azure VNet')
param azureVNetAddressPrefix string

@description('Optional. Specifies the name of the Public IP used by the Virtual Network Gateway. If it\'s not provided, a \'-pip\' suffix will be appended to the gateway\'s name.')
param gatewayPipName string = '${BaseName}-pip1'

@description('Optional. Specifies the name of the Public IP used by the Virtual Network Gateway when active-active configuration is required. If it\'s not provided, a \'-pip\' suffix will be appended to the gateway\'s name.')
param activeGatewayPipName string = '${BaseName}-pip2'

@description('CIDR block for gateway subnet, subset of azureVNetAddressPrefix address space')
param gatewaySubnetPrefix string
param dnsservers array

param VPNlocalGatewayIpAddress1 string
param VPNlocalGatewayIpAddress2 string

param VPNlocalAddressPrefix1 string
param VPNlocalAddressPrefix2 string

param remoteasn1 string
param remoteasn2 string

param bgpPeeringAddress1 string
param bgpPeeringAddress2 string

param asn string = '65515'


@description('The Sku of the Gateway. This must be one of Basic, VPNGW1, VPNGW2 or VPNGW3.')
@allowed([
  'VPNGW1'
  'VPNGW2'
  'VPNGW3'
  'VpnGw1AZ'
  'VpnGw2AZ'
  'VpnGw3AZ'
])
param virtualNetworkGatewaySku string = 'VpnGw1AZ'

param VPNsharedKey string = 'badanka123'

//// Variables
var isActiveActiveValid = true

var virtualGatewayPipNameVar = isActiveActiveValid ? [
  gatewayPipName
  activeGatewayPipName
] : [
  gatewayPipName
]


var bgpSettings = {
  asn: asn
}

// Potential configurations (active-active vs active-passive)
var ipConfiguration = isActiveActiveValid ? [
  {
    properties: {
      privateIPAllocationMethod: 'Dynamic'
      subnet: {
        id: '${BaseName_VNET.id}/subnets/GatewaySubnet'
      }
      publicIPAddress: {
        id: az.resourceId('Microsoft.Network/publicIPAddresses', gatewayPipName)
      }
    }
    name: 'vNetGatewayConfig1'
  }
  {
    properties: {
      privateIPAllocationMethod: 'Dynamic'
      subnet: {
        id: '${BaseName_VNET.id}/subnets/GatewaySubnet'
      }
      publicIPAddress: {
        id: isActiveActiveValid ? az.resourceId('Microsoft.Network/publicIPAddresses', activeGatewayPipName) : az.resourceId('Microsoft.Network/publicIPAddresses', gatewayPipName)
      }
    }
    name: 'vNetGatewayConfig2'
  }
] : [
  {
    properties: {
      privateIPAllocationMethod: 'Dynamic'
      subnet: {
        id: '${BaseName_VNET.id}/subnets/GatewaySubnet'
      }
      publicIPAddress: {
        id: az.resourceId('Microsoft.Network/publicIPAddresses', gatewayPipName)
      }
    }
    name: 'vNetGatewayConfig1'
  }
]

resource BaseName_VNET 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: toLower('${BaseName}-VNET')
  location: location
  properties: {
    dhcpOptions: {
      dnsServers: dnsservers
    }
    addressSpace: {
      addressPrefixes: [
        azureVNetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: gatewaySubnetPrefix
        }
      }
    ]
  }
  dependsOn: [
  ]
}


resource virtualNetworkGateway 'Microsoft.Network/virtualNetworkGateways@2021-08-01' = {
  name: toLower('${BaseName}-VPN-GW')
  location: location
  properties: {
    ipConfigurations: ipConfiguration
    activeActive: isActiveActiveValid
    enableBgp: true
    bgpSettings: bgpSettings 
    sku: {
      name: virtualNetworkGatewaySku
      tier: virtualNetworkGatewaySku
    }
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
  }
  dependsOn: [
  ]
}


resource BaseName_VPN_LGW1 'Microsoft.Network/localNetworkGateways@2021-02-01' =  {
  name: toLower('${BaseName}-VPN-LGW1')
  location: location
  properties: {
     bgpSettings: {
       asn: remoteasn1
       bgpPeeringAddress: bgpPeeringAddress1
     }
    localNetworkAddressSpace: {
      addressPrefixes: [
        VPNlocalAddressPrefix1
      ]
    }
    gatewayIpAddress: VPNlocalGatewayIpAddress1
  }
}

resource BaseName_VPN_LGW2 'Microsoft.Network/localNetworkGateways@2021-02-01' = {
  name: toLower('${BaseName}-VPN-LGW2')
  location: location
  properties: {
     bgpSettings: {
       asn: remoteasn2
       bgpPeeringAddress: bgpPeeringAddress2
     }
    localNetworkAddressSpace: {
      addressPrefixes: [
        VPNlocalAddressPrefix2
      ]
    }
    gatewayIpAddress: VPNlocalGatewayIpAddress2
  }
}

resource BaseName_VPN_Con1 'Microsoft.Network/connections@2021-02-01' = {
  name: toLower('${BaseName}-VPN-Con1')
  location: location
  properties: {
    virtualNetworkGateway1: {
      id: virtualNetworkGateway.id
    }
    localNetworkGateway2: {
      id: BaseName_VPN_LGW1.id
    }
    connectionType: 'IPsec'
    routingWeight: 10
    sharedKey: VPNsharedKey
    enableBgp: true
  }
  dependsOn: [
  ]
} 

resource BaseName_VPN_Con2 'Microsoft.Network/connections@2021-02-01' = {
  name: toLower('${BaseName}-VPN-Con2')
  location: location
  properties: {
    virtualNetworkGateway1: {
      id: virtualNetworkGateway.id
    }
    localNetworkGateway2: {
      id: BaseName_VPN_LGW2.id
    }
    connectionType: 'IPsec'
    routingWeight: 10
    sharedKey: VPNsharedKey
    enableBgp: true
  }
  dependsOn: [
  ]
} 





// Public IPs
@batchSize(1)
resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2022-07-01' = [for (virtualGatewayPublicIpName, index) in virtualGatewayPipNameVar: {
  name: virtualGatewayPublicIpName
  location: location
  zones: [
    1
    2
    3
  ]
  sku: {
   name: 'Standard'
   tier: 'Regional'
  }
  properties: {
   publicIPAllocationMethod: 'Static'
  }
}]
