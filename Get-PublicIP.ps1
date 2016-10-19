Function Get-PublicIP {
    $IPAddress = (Invoke-WebRequest 'http://myexternalip.com/raw').Content -replace "`n"
    $IPAddress
}