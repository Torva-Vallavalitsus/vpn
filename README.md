# Tõrva Vallavalitsus VPN Setup Script

This PowerShell script automates the setup of a VPN connection for Tõrva Vallavalitsus. It is intended for use by automation system specialists who need access to devices on the internal network.

## Prerequisites

- Windows operating system
- PowerShell 5.1 or later
- Administrative privileges

## Quick Start

1. **Download the Script**: First, download the VPN setup script from the GitHub repository to your local machine.

   ```powershell
   Invoke-WebRequest -Uri https://raw.githubusercontent.com/Torva-Vallavalitsus/vpn/main/vpn.torva.ee.ps1 -OutFile "vpn.torva.ee.ps1"
   ```

2. **Run the Script**: Due to default PowerShell execution policies, you might encounter restrictions when trying to run scripts. To bypass these restrictions for this session only and avoid modifying system-wide policies, use the following command:

   ```powershell
   PowerShell -ExecutionPolicy Bypass -File .\vpn.torva.ee.ps1 -connectionName "PREFERRED_CONNECTION_NAME" -destinationPrefix "IP_ADDRESS_NETWORK/SUBNET_SIZE"
   ```
   where:
    - `PREFERRED_CONNECTION_NAME` is the name you want to give to the VPN connection.
    - `IP_ADDRESS_NETWORK/SUBNET_SIZE` is the IP address range of the internal network you want to access.
   
      For example (dummy values):
      ```powershell
        PowerShell -ExecutionPolicy Bypass -File .\vpn.torva.ee.ps1 -connectionName "Torva VPN" -destinationPrefix "192.168.2.0/24"
      ```
      
      This command will create a VPN connection named "Torva VPN" and route any traffic destined for an IP address in the range 192.168.2.1 to 192.168.2.255 to the VPN. You should replace the IP address range with the one provided to you.

3. **Connect to the VPN**: After running the script, you should see a new VPN connection named as specified. You can connect to this VPN connection using the Windows VPN settings. On the first connection, you will be prompted to enter your credentials which will be saved for future connections. You should have received these credentials along with the instructions that led you to this script.

4. **Access Internal Resources**: Once connected to the VPN, you should be able to access the devices on the internal network as needed. Try pinging your device.
     

## Script Functions

- **SSL Certificate Installation**: Automatically installs the necessary SSL certificate to your system.
- **VPN Profile Creation**: Creates a new VPN profile named as specified.
- **Routing Configuration**: Sets up routing to direct only necessary traffic through the VPN.
- **Default Gateway Modification**: Disables using the VPN as the default gateway to ensure only internal traffic is directed through the VPN.

## Notes

- Running scripts from the Internet can be dangerous. Always ensure that you trust the source of the scripts you execute.
- If your organization's policies do not allow you to change execution policies, please contact your IT department for assistance.

For further details on the script's functionality or if you encounter any issues, please review the code or contact support.
