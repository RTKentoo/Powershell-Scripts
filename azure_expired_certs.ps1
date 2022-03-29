$webAppCertificates = Get-AzWebAppCertificate 
$now = Get-Date
#Get-AzKeyVault | Foreach-Object {
#    Get-AzKeyVaultCertificate -VaultName $_.VaultName | Select-Object VaultName, Name, Expires, @{
#    Name = 'ExpiresInXDays'
#    Expression = {($_.Expires - $now).Days}
#    }
#}

foreach ($cert in $webAppCertificates) {
    Get-AzWebAppCertificate -Thumbprint $cert.Thumbprint | Where-Object @{
        Name = "ExpiresInXDays"
        Expression = {($_.expirationDate - $now).Days}
    }
}