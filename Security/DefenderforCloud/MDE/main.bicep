//Enables the new Unified solutions for Windows 2012 R2 and Windows 2016 servers
targetScope = 'subscription'

resource test 'Microsoft.Security/settings@2022-05-01' = {
  name: 'WDATP_UNIFIED_SOLUTION'
  kind: 'DataExportSettings'
   properties: {
    enabled:  true
   }
}
