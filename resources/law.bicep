param lawResourceName string
param location string

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: lawResourceName
  location: location

  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

output lawResourceId string = logAnalytics.id
