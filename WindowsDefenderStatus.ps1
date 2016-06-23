###############################################################################
#
#  WindowsDefenderStatus - Victor Silva - 4/2/15
#
###############################################################################
$Web = Invoke-WebRequest –Uri http://www.microsoft.com/security/portal/definitions/whatsnew.aspx
$Lista = $Web.ParsedHTML.getElementsByTagName("option") | select InnerText

$LastDefinition = $Lista[0].innerText
$UmbralDefinition = $Lista[2].innerText

$LocalDefinition = Get-ItemProperty -Path 'Registry::HKLM\SOFTWARE\Microsoft\Windows Defender\Signature Updates' -Name AVSignatureVersion | Select-Object -ExpandProperty AVSignatureVersion

If ($LocalDefinition -ge $LastDefinition) {
    Write-Host "Windows Defender acutlaizado al último update" -ForegroundColor Green
    Write-Host ""
} else {
    If ($LocalDefinition -gt $UmbralDefinition) {
        Write-Host "WindowsDefender hay nuevas definiciones" -ForegroundColor Yellow
        Write-Host ""
    } else {
        Write-Host "WindowsDefender desactualizado" -ForegroundColor Red
        Write-Host ""
    }
}