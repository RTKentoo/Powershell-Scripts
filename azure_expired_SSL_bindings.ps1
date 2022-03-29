$date = (((get-date).ToUniversalTime()).ToString("yyyyMMdd"))
$expireDate = ((Get-Date).AddDays(180))
$fileName = "C:\users\ktaylor\Documents\Azure_Webapps_SSLBinding_Expiry_${date}.csv"
$allCerts = Get-AzKeyVaultCertificate -VaultName gfsp-infrastructure-kv


Set-AzContext -SubscriptionName Production
$apps = Get-AzWebApp
foreach($cert in $allCerts) {


        foreach($app in $apps) {
            if( ($app | Get-azwebappsslbinding).Thumbprint -eq "4a4d3a7a8ba275c04a97dda6ede9fdca9132b1c2" ) {
                $siteName   = ($app | Get-AzWebAppSslBinding).Name
                $results = [PSCUSTOMOBJECT]@{
                    Name            = $app.name
                    ResourceGroup   = $app.resourceGroup
                    SiteName        = $siteName
                    Thumbprint      = $certThumbprint
                    Expires         = $cert.Expires
                }
                $results | Export-CSV -Append -Path $fileName -NoType
            } else {}
        }  
}         