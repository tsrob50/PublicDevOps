// File to create a virtual network 

param location string

param tags object

param vnetName string

param addressPrefixes array

param ipSubnets array

resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: [for ipSubnet in ipSubnets: {
      name: ipSubnet.name
      properties: {
        addressPrefix: ipSubnet.subnetPrefix
      }
    }]
  }
}

output vnetId string = vnet.id
