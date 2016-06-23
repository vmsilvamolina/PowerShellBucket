function Get-Option {
    Write-Host 'Exchange 2016 - Instalación de requisitos' -ForegroundColor Green
    Write-Host ''
    Write-Host '1 - Requisitos para el Mailbox Server'
    Write-Host '2 - Requisitos para el Edge Server'
    Write-Host ''
    $Opcion = Read-Host -Prompt 'Seleccione la opción correcta'

    switch ($Opcion) { 
        1 {
            Write-Host ''
            Write-host '1 - Requisitos para el Mailbox Server'
            Write-Host ''
            Write-host 'Instalando...'
            Install-WindowsFeature AS-HTTP-Activation, Desktop-Experience, NET-Framework-45-Features, RPC-over-HTTP-proxy, RSAT-Clustering, 
            RSAT-Clustering-CmdInterface, RSAT-Clustering-Mgmt, RSAT-Clustering-PowerShell, Web-Mgmt-Console, WAS-Process-Model, Web-Asp-Net45, 
            Web-Basic-Auth, Web-Client-Auth, Web-Digest-Auth, Web-Dir-Browsing, Web-Dyn-Compression, Web-Http-Errors, Web-Http-Logging, 
            Web-Http-Redirect, Web-Http-Tracing, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Lgcy-Mgmt-Console, Web-Metabase, Web-Mgmt-Console, 
            Web-Mgmt-Service, Web-Net-Ext45, Web-Request-Monitor, Web-Server, Web-Stat-Compression, Web-Static-Content, Web-Windows-Auth, 
            Web-WMI, Windows-Identity-Foundation -Restart

        } 2 {
            Write-Host ''
            Write-host '2 - Requisitos para el Edge Server'
            Write-Host ''
            Install-WindowsFeature ADLDS
        } default {
            Write-Host ''
            Write-host 'Por favor, seleccionar una opción correcta'
            Write-Host ''
            Write-Host ''
            Get-Option
        }
    }
}
cls
Get-Option
