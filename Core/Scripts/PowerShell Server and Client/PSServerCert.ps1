# TCP Server Script with TLS and Certificate Authentication
param (
    [string]$serverIp = "10.160.207.207",  # Server IP address
    [int]$port = 12346,               # Server port
    [string]$certPath = "C:\INSTALL\testserver.pfx",  # Path to server certificate
    [string]$certPassword = "Password1"  # Password for server certificate
)
try {
    # Load the server certificate
    $serverCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
    $serverCert.Import($certPath, $certPassword, 'DefaultKeySet')
    # Start TCP listener
    $listener = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Parse($serverIp), $port)
    $listener.Start()
    Write-Host "TCP Server started at $serverIp : $port, waiting for clients..."
    while ($true) {
        # Accept a new client
        $client = $listener.AcceptTcpClient()
        Write-Host "Client connected."
        # Get the client stream and wrap it in an SslStream
        $stream = $client.GetStream()
        $sslStream = New-Object System.Net.Security.SslStream($stream, $false, { $true })
        try {
            # Authenticate the client using the server's certificate
            $sslStream.AuthenticateAsServer($serverCert, $true, [System.Security.Authentication.SslProtocols]::Tls12, $false)
            if ($sslStream.IsAuthenticated) {
                Write-Host "TLS authentication successful with the client."
                # Read the message from the client
                $reader = New-Object System.IO.StreamReader($sslStream)
                $message = $reader.ReadLine()
                Write-Host "Received message from client: $message"
                # Clean up
                $reader.Close()
                $sslStream.Close()
                $client.Close()
                Write-Host "Connection with client closed."
            } else {
                Write-Host "TLS authentication failed with the client."
            }
        } catch {
            Write-Host "Error during TLS authentication: $($_.Exception.Message)"
            $sslStream.Close()
            $client.Close()
        }
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}
