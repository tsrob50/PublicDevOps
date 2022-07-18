// File to create a Bastion Host

param bastionPubIpName string

param bastionName string

param location string

param tags object

param vnetId string

var subnetId = '${vnetId}/subnets/AzureBastionSubnet'

resource pubIp 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: bastionPubIpName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2022-01-01' = {
  name: bastionName
  location: location
  tags: tags
  sku: {
    name: 'Basic'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig'
        properties: {
          privateIPAllocationMethod: 'dynamic'
          publicIPAddress: {
            id: pubIp.id
          }
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}
