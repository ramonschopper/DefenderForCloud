targetScope = 'managementGroup'

param location string
param umiResourceId string
param lawResourceId string

param provPolicyDefinitionId string = '/providers/Microsoft.Authorization/policyDefinitions/8e7da0a5-0a0e-4bbc-bfc0-7773c018b616'
resource provPolicyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01'= {
  name: 'provisionDefender'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${umiResourceId}' : {}
    }
  }
  properties: {
    displayName: 'Auto Provision Defender for Cloud'
    policyDefinitionId: provPolicyDefinitionId
    enforcementMode: 'DoNotEnforce'
    parameters: {
      logAnalytics: {
        value: lawResourceId
      }
    } 
  }
}

resource remediationTask 'Microsoft.PolicyInsights/remediations@2021-10-01' = {
  name: 'remediationAutoProvisioning'

  properties: {
    policyAssignmentId: provPolicyAssignment.id
    policyDefinitionReferenceId: provPolicyDefinitionId
  }
}
