targetScope = 'managementGroup'

param location string
param policy object
param policyDefinitionId string
param umiResourceId string
param umiPrincipalId string

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = [for scope in policy.scopes: {
  name: uniqueString('${policy.name}_${scope}')
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${umiResourceId}' : {}
    }
  }
  properties: {
    description: policy.policyDefinition.properties.description
    displayName: policy.displayName
    policyDefinitionId: policyDefinitionId
    parameters: policy.parameters
  }
}]

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (scope, i) in policy.scopes: if (!policy.identity == false) {
  name: guid('${policy.name}_${scope}_${i}')
  properties: {
    roleDefinitionId: policy.policyDefinition.properties.policyRule.then.details.roleDefinitionIds[0]
    principalId: umiPrincipalId
    principalType: 'ServicePrincipal'
  }
}]

resource remediationTask 'Microsoft.PolicyInsights/remediations@2021-10-01' = [for (scope, i) in policy.scopes: {
  name: guid('${policy.name}_${scope}_${i}')

  properties: {
    policyAssignmentId: policyAssignment[i].id
    policyDefinitionReferenceId: policyDefinitionId
  }
}]

output policyAssignments array = [for (scope, i) in policy.scopes: {
  policyAssignmentId: policyAssignment[i].id
  principalId: umiPrincipalId
}]
