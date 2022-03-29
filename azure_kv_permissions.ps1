$subscription = "80031227-6198-4a96-bf00-6efd88bfef19"
$keyVaults = Get-AzKeyVault #-SubscriptionId $subscription
foreach ($vault in $keyVaults) {
    Set-AzKeyVaultAccessPolicy -VaultName $vault.vaultName `
    -UserPrincipalName 'ktaylor-a@genesis-fs.com' `
    -PermissionstoKeys Get, List, Update, Create, Import, Delete, Recover, Backup, Restore `
    -PermissionsToSecrets Get, List, Set, Delete, Recover, Backup, Restore `
    -PermissionsToCertificate Get, List, Update, Create, Import, Delete, Recover, Backup, Restore, ManageContacts, ManageIssuers, GetIssuers, ListIssuers, SetIssuers, DeleteIssuers 
}