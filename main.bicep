// Target scope
targetScope = 'managementGroup'

// Location will be used for Log Analytics Workspace, User Assigned Managed Identity and all deployments
@description('Location of deployment')
param location string = 'switzerlandnorth'

// Subscription Id and Resource Group to deploy User Assigned Managed Identity and Log Analytics Workspace
param miSubscriptionId string = 'xxxxx'
param miResourceGroupName string = 'xxxxx'

// Name of the User Assigned Managed Identity
param umiName string = 'umi-chn-mdfc'

// Name of the Log Analytics Workspace
param lawName string = 'law-chn-mdfc'

// All Customs policies to be created and assigned contained in sub folder 'custom'
@description('List of policies')
param policies array =  [
  {
    name: 'defenderPlans'
    displayName: 'Enable Defender for all Subscriptions'
    policyDefinition: json(loadTextContent('./custom/defenderPlans.json'))
    parameters: {}
    identity: true
    scopes: [
      'b8a53dab-10d3-4ab4-8819-d608f0f31883'
    ]
  }
]

// Deploy User Assigned Managed Identity for Policy Remediation
module umi './resources/mi.bicep' = {
    name: 'umiDeploy'
    scope: resourceGroup(miSubscriptionId, miResourceGroupName)
    params: {
        miResourceName: umiName
        location: location
    }
}

// Deploy Log Analytics Workspace for Auto Provisioning
module law './resources/law.bicep' = {
  name: 'lawDeploy'
  scope: resourceGroup(miSubscriptionId, miResourceGroupName)
  params: {
      lawResourceName: lawName
      location: location
  }
}

// Assign the Azure Security Benchmark Initiative
param asbPolicyDefinitionId string = '/providers/Microsoft.Authorization/policySetDefinitions/1f3afdf9-d0c9-4c3d-847f-89da613e70a8'
resource asbPolicyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01'= {
  name: 'ASBGlobal'
  location: location
  properties: {
    displayName: 'Azure Security Benchmark'
    policyDefinitionId: asbPolicyDefinitionId
    enforcementMode: 'DoNotEnforce'
  }
}

// Assign the Defender for Cloud Auto Provisioning Policy
module provisionAssignment './resources/policy.bicep' = {
  name: 'provisionDefender'
  params: {
    location: location
    lawResourceId: law.outputs.lawResourceId
    umiResourceId: umi.outputs.umiResourceId
  }
}

// Create custom Policy Definitions under ./custom/
resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = [for policy in policies: {
  name: guid(policy.name)
  properties: {
    description: policy.policyDefinition.properties.description
    displayName: policy.policyDefinition.properties.displayName
    metadata: policy.policyDefinition.properties.metadata
    mode: policy.policyDefinition.properties.mode
    parameters: policy.policyDefinition.properties.parameters
    policyType: policy.policyDefinition.properties.policyType
    policyRule: policy.policyDefinition.properties.policyRule
  }
}]

// Assign custom Policy Definitions
module policyAssignment './resources/assignments.bicep' = [for (policy, i) in policies: {
  name: 'Assign_${take(policy.name, 40)}'
  params: {
    policy: policy
    location: location
    policyDefinitionId: policyDefinition[i].id
    umiResourceId: umi.outputs.umiResourceId
    umiPrincipalId: umi.outputs.umiPrincipalId
  }
  dependsOn: [
    policyDefinition
  ]
}]
