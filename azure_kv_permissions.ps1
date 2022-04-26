$subscription = ""
$keyVaults = Get-AzKeyVault #-SubscriptionId $subscription
foreach ($vault in $keyVaults) {
    Set-AzKeyVaultAccessPolicy -VaultName $vault.vaultName `
    -UserPrincipalName '' `
    -PermissionstoKeys Get, List, Update, Create, Import, Delete, Recover, Backup, Restore `
    -PermissionsToSecrets Get, List, Set, Delete, Recover, Backup, Restore `
    -PermissionsToCertificate Get, List, Update, Create, Import, Delete, Recover, Backup, Restore, ManageContacts, ManageIssuers, GetIssuers, ListIssuers, SetIssuers, DeleteIssuers 
}
