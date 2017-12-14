## Simple WOL script
## Written by Maurice Lok-Hin
## This script constructs a WOL packet and broadcasts it.
## To do : do some mojojojo with string formatting to accept MAC addresses in multiple formats.


<#
.Synopsis
   This function sends a wakeup frame to a machine
.DESCRIPTION
   This function sends a wakeup frame to a machine
.EXAMPLE
   Send-WOL -BroadcastAddress 192.168.0.255 -TargetMac AB:CD:EF:00:11:22
#>

Function Send-WOL
{
[CmdletBinding()]
Param(
[Parameter()]
[string]$BroadcastAddress,

[Parameter()]
[string]$TargetMac
)

# Create the endpoint, we use UDP port 9
$IPEP = [System.Net.IPEndPoint]::new([IPAddress]$BroadcastAddress,9)

# Socket Settings
$AdFam = [System.Net.Sockets.AddressFamily]::InterNetwork
$SType = [System.Net.Sockets.SocketType]::Dgram
$PType = [System.Net.Sockets.ProtocolType]::Udp

# Create the UDP client
$Client = [System.Net.Sockets.UdpClient]::new()
$Client.EnableBroadcast = $true # This has to be switched on of course

# The packet is very simple : first 6 bytes are 0xFF, the we repeat the MAC Address 16(!!!) times.
# First part, create a list (which will be converted to an array later)
$Packet = [System.Collections.Generic.List[byte]]::new() # Byte list, to be converted to an array, to hold the bytes

# Now we create the header (6 bytes with a 0xFF value) using a FOR loop
for ($i = 0; $i -lt 6; $i++)
{ 
    $Packet.Add([byte]255)
}

# Now we split the MAC Address and convert the "string" to a hexvalue 
$MacSplit = $TargetMac.Split(':',[System.StringSplitOptions]::RemoveEmptyEntries)

# And here we add these bytes to a list. Since we need it 16 times we just loop through the code 16 times.
for ($i = 0; $i -lt 16; $i++)
{ 
   foreach ($M in $MacSplit)
    {
        $MString = [string]::Format('0x{0}',$M)
        $Packet.Add([byte]$MString)
    } 
}

# Now we convert the list to an array...
$MagicPacket = $Packet.ToArray() # Convert the list to an array

# And finally we send the packet
$Client.Send($MagicPacket,$MagicPacket.Length,$IPEP)
}