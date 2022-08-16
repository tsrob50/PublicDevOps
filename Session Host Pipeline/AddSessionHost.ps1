# Pipeline Variables
variables:
- name: hostPoolRg
  value: "<HostPool>"
- name: hostPoolName
  value: "<HostPoolName>"
- name: laWorkspaceName
  value: "<LogAnalyticsWorkspaceName>"
- name: laWorkspaceRg
  value: "LogAnalyticsWorkspaceRG>"

# Get the Registration Key
# if no key, create one for 24 hours
$hostPoolRegKey = (Get-AzWvdRegistrationInfo -ResourceGroupName $(hostPoolRg) -HostPoolName $(hostPoolName)).token
if ($hostPoolRegKey -eq $null) {
   $hostPoolRegKey = (New-AzWvdRegistrationInfo -ResourceGroupName $(hostPoolRg) -HostPoolName $(hostPoolName) -ExpirationTime $((get-date).ToUniversalTime().AddDays(1).ToString('yyyy-MM-ddTHH:mm:ss.fffffffZ'))).Token
}
"##vso[task.setvariable variable=hostPoolRegKey;]$hostPoolRegKey"


# Get the Log Analytics Workspace Key
$laWorkspaceKey = (Get-AzOperationalInsightsWorkspaceSharedKey -ResourceGroupName $(laWorkspaceRg) -Name $(laWorkspaceName)).PrimarySharedKey
"##vso[task.setvariable variable=laWorkspaceKey;]$laWorkspaceKey"


# Get the VM Prefix
$vmPrefix = "SH" + (Get-Date -Format "MMddyyHHmm")
"##vso[task.setvariable variable=vmPrefix;]$vmPrefix"


# Override template parameters.
-hostpoolToken $(hostPoolRegKey) -administratorAccountPassword $(domainadd) -vmAdministratorAccountPassword $(LocalAdmin) -vmNamePrefix $(vmPrefix) -workspaceKey $(laWorkspaceKey)


# Enable Drain Mode
$sessionHosts = Get-AzWvdSessionHost -ResourceGroupName $(hostPoolRg) -HostPoolName $(hostPoolName) | Where-Object {$_.Name -like "*$(vmPrefix)*"}
foreach ($sessionHost in $sessionHosts) {
   $sessionHost = (($sessionHost.name).Split("/"))[1]
   Update-AzWvdSessionHost -ResourceGroupName $(hostPoolRg) -HostPoolName $(hostPoolName) -Name $sessionHost -AllowNewSession:$false 
}
