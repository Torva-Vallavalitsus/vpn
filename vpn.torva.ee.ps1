param (
    [string]$destinationPrefix = "172.28.3.0/24" # Default value if not provided
)

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process PowerShell -ArgumentList "-ExecutionPolicy Bypass", "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "Running with elevated privileges"

$vpnName = "vpn.torva.ee"

# Check if the VPN connection already exists
try {
    $existingVpn = Get-VpnConnection -Name $vpnName -ErrorAction Stop
    Write-Output "VPN connection '$vpnName' already exists. Removing..."
    
    # Remove the existing VPN connection
    Remove-VpnConnection -Name $vpnName -Force
    Write-Output "Existing VPN connection '$vpnName' removed."
} catch {
    Write-Output "VPN connection '$vpnName' does not exist. Proceeding to create a new one."
}

# Adjusted Root Certificate (base64 encoded with PEM header and footer)
$certText = @"
-----BEGIN CERTIFICATE-----
MIIDiDCCAnCgAwIBAgIIKaDdr4L6wSkwDQYJKoZIhvcNAQELBQAwYjELMAkGA1UE
BhMCRUUxETAPBgNVBAgMCFZhbGdhbWFhMQ4wDAYDVQQHDAVUb3J2YTEMMAoGA1UE
CgwDVFZWMQswCQYDVQQLDAJJVDEVMBMGA1UEAwwMdnBuLnRvcnZhLmVlMB4XDTI0
MDMwMzA5MDQ1MloXDTM0MDMwMTA5MDQ1MlowYjELMAkGA1UEBhMCRUUxETAPBgNV
BAgMCFZhbGdhbWFhMQ4wDAYDVQQHDAVUb3J2YTEMMAoGA1UECgwDVFZWMQswCQYD
VQQLDAJJVDEVMBMGA1UEAwwMdnBuLnRvcnZhLmVlMIIBIjANBgkqhkiG9w0BAQEF
AAOCAQ8AMIIBCgKCAQEAlzBHZ9S4eojFA9Pz95LJILS/5NwswQ5Z2F1vSwmFgI9R
fl5iJZ/JNhflfdLj0DamH43dZQlvJ+ftWByNgUiqdZhcAznp89eOWLEUWCSwRzut
iMa2Zw3IVCR2YheaZVeE3xHcMkwzr2kkGI5Ps4wqsT66Jp27f7TAu1TbRO2K1pxb
L82XJciSjDfqfF6R7xdqb1f9IxZSkUR5yBjFHx0onHiorb+TCJgFu/xCASraGW0+
yt13HbB3BADtr6gZAGJNBRfD6iYa5lFoYGwKedE+5w/3N9d77CWc/AZvV0UJ7F6S
h/koVD9dHUoWEcy92eTKL2vlYdcTeeyqCMhBLa/pXQIDAQABo0IwQDAPBgNVHRMB
Af8EBTADAQH/MA4GA1UdDwEB/wQEAwIBBjAdBgNVHQ4EFgQUffjeHKA//gcPHjn9
+AZUyJDLceMwDQYJKoZIhvcNAQELBQADggEBAHry2zOiQc6hz9Dz2srkUeASS9kQ
28QEGXH8CxT3vXPwODh3znMAiiXPKY9GHSF8vihTfe/7t+y8A3AHTeA5ptd/n2M+
vsK8IDvCfqmiT+5QSWQ8CWru0W8NeHQeouqVWe2FKfXdfCxFCGgWHQ0FPD5POv0G
poDWCQXe7laypn64AcDVl4SpZL5VyIp71GGEKo9+RQu5y/MBmPYcX1bhBsqZw0Xl
845cx88R8bZ7uec+bs2Rzhd2oOBnObnfEfM8G1pOwH7OuIBLb8OtS/PnB363PjxR
1o4BVLUTkPqLFD8Jo229+jIQgsDz3dc7dc7DU3PzzU24xbm/Y+9vF6LMupI=
-----END CERTIFICATE-----
"@

# Remove the PEM header and footer
$certBase64 = $certText -replace '^-+BEGIN CERTIFICATE-+[\r\n]+' -replace '[\r\n]+-+END CERTIFICATE-+[\r\n]*$', ''

# Decode the base64 certificate content to byte array
$certBytes = [Convert]::FromBase64String($certBase64)

# Create a new X509 certificate object from the byte array
$x509 = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
$x509.Import($certBytes)

# Open the Root store of the LocalMachine
$store = New-Object System.Security.Cryptography.X509Certificates.X509Store "Root", "LocalMachine"
$store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)

# Add the certificate to the store
$store.Add($x509)

# Close the store
$store.Close()

# Create SSTP VPN Connection
Add-VpnConnection -Name $vpnName -ServerAddress $vpnName -TunnelType 'Sstp' -EncryptionLevel 'Required' -AuthenticationMethod MSChapv2 -SplitTunneling -RememberCredential 

# Add Route to VPN Connection
Add-VpnConnectionRoute -ConnectionName $vpnName -DestinationPrefix $destinationPrefix

# Path to the rasphone.pbk file
$pbkPath = "$env:USERPROFILE\AppData\Roaming\Microsoft\Network\Connections\Pbk\rasphone.pbk"

# Read the contents of the PBK file
$pbkContent = Get-Content -Path $pbkPath

# Find the index of the VPN connection
$vpnIndex = $pbkContent.IndexOf("[${vpnName}]")

if ($vpnIndex -ne -1) {
    # Initialize nextVpnIndex to just beyond the end of the file as a default
    $nextVpnIndex = $pbkContent.Length

    # Start looking for the next section header (another VPN connection start) after the current vpnIndex
    for ($i = $vpnIndex + 1; $i -lt $pbkContent.Length; $i++) {
        if ($pbkContent[$i] -match '^\[.*\]$') { # Look for a line that starts with '[' indicating a new section
            $nextVpnIndex = $i
            break
        }
    }

    # Modify the DisableClassBasedDefaultRoute setting for the VPN connection
    for ($i = $vpnIndex; $i -lt $nextVpnIndex; $i++) {
        if ($pbkContent[$i] -match "DisableClassBasedDefaultRoute=0") {
            $pbkContent[$i] = "DisableClassBasedDefaultRoute=1"
            Write-Host "Disabled class-based default route for $vpnName."
            break
        }
    }

    # Write the changes back to the PBK file
    $pbkContent | Set-Content -Path $pbkPath
} else {
    Write-Host "VPN connection '$vpnName' not found in PBK file."
}
