$subscriptionId = "bd1d2c11-78e5-4a4b-9ebb-9fc0d81c2209"
$oldTagKey = "Environment"
$oldTagValue = "infradev"
$newTagKey = "env"
$newTag = @{$newTagKey=$oldTagValue}
$resourceGroups = Get-AzResourceGroup


Set-AzContext $subscriptionId

## New Tag - old tag value and new tag key (e.g. Environment:prod -> env:prod) ## 
foreach ($resourceGroup in $resourceGroups) {
    $resources = Get-AzResource -ResourceGroupName $resourceGroup.resourceGroupName
    if ($resourceGroup.Tags.$oldTagKey -eq $oldTagValue) {
        $resourceGroup.Tags.$newTagKey = $oldTagValue
        Set-AzResourceGroup -ResourceId $resource.resourceId -Tag $resource.Tags -Force
    }

    foreach ($resource in $resources) {
        if ($resource.Tags.$oldTagKey -eq $oldTagValue) {
            $resource.Tags.$newTagKey = $oldTagValue
            Set-AzResource -ResourceId $resource.resourceId -Tag $resource.Tags -Force
        }
    }
}


## Modify overlapping values for Environment ##
$tagKey = "env"
Set-AzContext -SubscriptionName "Production" 
foreach ($resourceGroup in $resourceGroups) {
    $resources = Get-AzResource -ResourceGroupName $resourceGroup.resourceGroupName
    if ($resourceGroup.Tags.$tagKey -ne "prod") {
        $resourceGroup.Tags.$tagKey = "prod"
        Set-AzResourceGroup -ResourceId $resource.resourceId -Tag $resource.Tags -Force
    }

    foreach ($resource in $resources) {
        if ($resource.Tags.$tagKey -ne "prod") {
            $resource.Tags.$tagKey = "prod"
            Set-AzResource -ResourceId $resource.resourceId -Tag $resource.Tags -Force
        }
    }
}


## Remove Specific Tags from all Resources and Resource Groups ##
Set-AzContext -SubscriptionName "Infrastructure Dev"
$tagToRemove = @{"cost"="COST";"key2"="value2"}
$resourceGroups = Get-AzResourceGroups

foreach ($rg in $resourceGroups) {
    $resources = Get-AzResource -ResourceGroupName $resourceGroup.resourceGroupName
    Update-AzTag -ResourceID $rs.id -Tag $tagToRemove -Operation Delete
    
    foreach ($rs in $resource) {
        Update-AzTag -ResourceID $rs.id -Tag $tagToRemove -Operation Delete
    }
}