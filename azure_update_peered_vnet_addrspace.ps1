param (
    # Address Prefix range (CIDR Notation, e.g., 10.0.0.0/24 or 2607:f000:0000:00::/64)
    [Parameter(Mandatory = $true)]
    [String[]]
    $IPAddressRange,

    # Hub VNet Subscription Name
    [Parameter(Mandatory = $true)]
    [String]
    $HubVNetSubscriptionName,

    # Hub VNet Resource Group Name
    [Parameter(Mandatory = $true)]
    [String]
    $HubVNetRGName,

    # Hub VNet Name
    [Parameter(Mandatory = $true)]
    [String]
    $HubVNetName
)

#Set context to Hub VNet Subscription
Get-AzSubscription -SubscriptionName $HubVNetSubscriptionName | Set-AzContext
#end

#Get All Hub VNet Peerings and Hub VNet Object
$hubPeerings = Get-AzVirtualNetworkPeering -ResourceGroupName $HubVNetRGName -VirtualNetworkName $HubVNetName
$hubVNet = Get-AzVirtualNetwork -Name $HubVNetName -ResourceGroupName $HubVNetRGName
#end

#Remove All Hub VNet Peerings
Remove-AzVirtualNetworkPeering -VirtualNetworkName $HubVNetName -ResourceGroupName $HubVNetRGName -name $hubPeerings.Name -Force
#end

#Add IP address range to the hub vnet
$hubVNet.AddressSpace.AddressPrefixes.Add($IPAddressRange)
#end

#Apply configuration stored in $hubVnet
Set-AzVirtualNetwork -VirtualNetwork $hubVNet
#end

foreach ($vNetPeering in $hubPeerings)
{
    # Get remote vnet name
    $vNetFullId = $vNetPeering.RemoteVirtualNetwork.Id
    $vNetName = $vNetFullId.Substring($vNetFullId.LastIndexOf('/') + 1)

    # Pull remote vNet object
    $vNetObj = Get-AzVirtualNetwork -Name $vNetName

    # Get the peering from the remote vnet object
    $peeringName = $vNetObj.VirtualNetworkPeerings.Where({$_.RemoteVirtualNetwork.Id -like "*$($hubVNet.Name)"}).Name
    $peering = Get-AzVirtualNetworkPeering -ResourceGroupName $vNetObj.ResourceGroupName -VirtualNetworkName $vNetName -Name $peeringName

    # Reset to initiated state
    Set-AzVirtualNetworkPeering -VirtualNetworkPeering $peering

    # Re-create peering on hub
    Add-AzVirtualNetworkPeering -Name $vNetPeering.Name -VirtualNetwork $HubVNet -RemoteVirtualNetworkId $vNetFullId -AllowGatewayTransit
}
