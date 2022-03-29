$subscription = Get-AzSubscription -SubscriptionId "c34025c1-bdb6-444a-8d83-a169588a70aa"

$tags = Get-AzTag 

    foreach($tagName in $tags) {
        Get-AzTag -Name $tagName.Name | Select Name, Count, Values | Export-CSV -Path "./Azure_Tags.csv"  -Append -Force
    }