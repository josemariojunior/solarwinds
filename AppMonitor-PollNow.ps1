# PowerShell Script to perform a PollNow query using SWQL based on unresposive application monitor

# Load the SolarWinds SDK module
Import-Module SwisPowerShell
 
# If not, prompt for credentials and build one
if (-not $SwisConnection) {
    $SwisCreds = Get-Credential -Message "Enter Orion credentials to connect to '$SwisHost'"
    $SwisConnection = Connect-Swis -Hostname $SwisHost -Credential $SwisCreds
}
 
 
# Define the SQL query to get the list of Application IDs you want to poll
$query = "SELECT ApplicationID FROM Orion.APM.CurrentApplicationStatus WHERE availability = 12"
 
# Execute the query and get the list of Application IDs
$applicationIDs = Get-SwisData -SwisConnection $SwisConnection -Query $query
 
 
# Loop through each application ID and invoke the PollNow verb
foreach ($applicationID in $applicationIDs) {
    Invoke-SwisVerb -SwisConnection $SwisConnection -EntityName "Orion.APM.Application" -Verb "PollNow" -Arguments @($applicationID)
    Write-Host "Polled application with ID: $applicationID"      
}
