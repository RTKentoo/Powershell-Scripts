$subscription = Get-AzSubscription -SubscriptionId ""

$tags = Get-AzTag 

    foreach($tagName in $tags) {
        Get-AzTag -Name $tagName.Name | Select Name, Count, Values | Export-CSV -Path "./Azure_Tags.csv"  -Append -Force
    }
