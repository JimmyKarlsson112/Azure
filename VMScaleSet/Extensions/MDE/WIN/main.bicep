targetScope = 'resourceGroup'

param scalesets array =  [
  'mde'
]

module vmextension 'extension.bicep' = [for scaleset in scalesets: {
  name: '${scaleset}-mde'
  params: {
     vmname: scaleset
  }
}]
