param miResourceName string
param location string


resource umi 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: miResourceName
  location: location
}

output umiResourceId string = umi.id
output umiPrincipalId string = umi.properties.principalId
