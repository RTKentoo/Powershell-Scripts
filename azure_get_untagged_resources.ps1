$resources = Get-AzResource
foreach($resource in $resources)
{
    if ($resource.Tags -eq $null)
    {
        echo $resource.Name, $resource.ResourceType
    }
}