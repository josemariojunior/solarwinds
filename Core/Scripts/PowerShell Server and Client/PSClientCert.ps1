# TCP Sender Script with TLS and Certificate Authentication
param (
    [string]$serverIp = "X.X.X.X",  # Server IP address
    [int]$port = 12346,               # Server port
    [string]$message = "Hello, Secure TCP Server!",  # Message to send
    [string]$certPath = "C:\INSTALL\testclient.pfx",  # Path to client certificate
    [string]$certPassword = "Password"  # Password for client certificate
)
try {
    # Load the client certificate
    $clientCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
    $clientCert.Import($certPath, $certPassword, 'DefaultKeySet')

    # Create a collection and add the client certificate
    $certCollection = New-Object System.Security.Cryptography.X509Certificates.X509CertificateCollection
    $certCollection.Add($clientCert)

    # Connect to the TCP server
    $client = New-Object System.Net.Sockets.TcpClient($serverIp, $port)
    $stream = $client.GetStream()

    # Create SslStream for TLS
    $sslStream = New-Object System.Net.Security.SslStream($stream, $false, { $true })

    # Authenticate as a client using the provided certificate (without the protocol argument)
    $sslStream.AuthenticateAsClient($serverIp, $certCollection, [System.Security.Authentication.SslProtocols]::Tls12, $false)

    if ($sslStream.IsAuthenticated) {
        Write-Host "Successfully authenticated over TLS with the server at $($serverIp):$($port)"

        # Create a stream writer to send the message
        $writer = New-Object System.IO.StreamWriter($sslStream)
        $writer.AutoFlush = $true

        # Send the message
        $writer.WriteLine($message)
        Write-Host "Message sent: $message"

        # Clean up the connection
        $writer.Close()
        $sslStream.Close()
        $client.Close()
        Write-Host "Connection closed."
    } else {
        Write-Host "TLS authentication failed."
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}
