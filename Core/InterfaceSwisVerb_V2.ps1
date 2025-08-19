# This sample script demonstrates the use of two verbs provided for adding NPM interfaces:
# o  Orion.NPM.Intefaces.DiscoverInterfacesOnNode
# o  Orion.NPM.Interfaces.AddInterfacesOnNode
#
# Note: These verbs are provided by SWISv3 only.
#
# The script lists all interfaces on a specified node and adds only
# selected interfaces to monitor.
#
# Please update the hostname and credential setup below to match your
# configuration, as well as the nodeId variable to refer the existing node to use.

#Install-Module SwisPowerShell
Import-Module SwisPowerShell

# Connect to SWIS
$username = "admin"
$password = convertto-securestring -String "YourPassword" -AsPlainText -Force

$SWIS_Credentials = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password
$swis = Connect-Swis -Credential $SWIS_Credentials

# The node ID to discovery interfaces on
$nodesID = Get-SwisData $swis -Query 'SELECT NodeID FROM Orion.Nodes where Vendor like ''%HUAWEI%'' AND PolledStatus = 1' -Parameters @{}


foreach ($nodeID in $nodesID) {
    Write-Host "Executing NodeID: $($nodeID)"
    # Discover interfaces on the node
    $discovered = Invoke-SwisVerb $swis Orion.NPM.Interfaces DiscoverInterfacesOnNode $nodeID

    if ($discovered.Result -ne "Succeed") {
        Write-Host "Interface discovery failed."
    }
    else {
        # Add the remaining interfaces
        Invoke-SwisVerb $swis Orion.NPM.Interfaces AddInterfacesOnNode @($nodeID, $discovered.DiscoveredInterfaces, "AddDefaultPollers") | Out-Null
        Write-Host "Completed NodeID: $($nodeID)"
    }
}
