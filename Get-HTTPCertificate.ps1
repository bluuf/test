## sample function to grab a certificate from a website

Function global:Get-HTTPSCertificate
{
[CmdletBinding()]
Param(
    [Parameter(
        Mandatory = $true,
        Position = 0,
        HelpMessage = "URL where you want to get the certificate from",
        ValueFromPipelineByPropertyName = $true
    )]
    [string[]]$Uri

)
    Add-Type -AssemblyName System.Web
    $ResultList = [System.Collections.Generic.List[System.Object]]::new()
    foreach ($u in $Uri)
    {
        $ResultObject = [PSCustomObject] @{
            Uri = $u
            Certificate = $null
            }
        $wrq = [System.Net.WebRequest]::Create($u)
        try # we don't want to generate an error on a certificate error, we just need the certificate
        {
                # dummy GET just to get the certificate
                #$wrq.GetResponse()
                [void]$wrq.GetResponse()
        }
        catch {} # we don't want to do anything with the error. We just needed to connect to get the certificate
        if ($wrq.ServicePoint.Certificate -ne $null)
        {
            [System.Security.Cryptography.X509Certificates.X509Certificate2]$Cert = $wrq.ServicePoint.Certificate
            $ResultObject.Certificate = $Cert
            $wrq = $null
        }
        $ResultList.Add($ResultObject)
    }
    return $ResultList
}