<#
 	.SYNOPSIS
        Este script permite realizar la configuración necesaria para el rol de IIS ARR.
    .DESCRIPTION
        Este script permite configurar el mensaje de "Fuera de Oficina" (Out-of-Office) en un mailbox en particular.
    .PARAMETER  Credential
        Indicar las credenciales que se deben usar para conectar a Exchange Online por medio de PowerShell.
    .PARAMETER Identity
        Indicar la identidad (Mailbox) del elemento al que se le asignaráel mensaje de OOF.
    .PARAMETER  InternalmMessage
        Este parámetro especifica el archivo con el mensaje interno del OOF.
    .PARAMETER  ExternalMessage
        Este parámetro especifica el archivo con el mensaje externo del OOF.
    .PARAMETER  Enable
        Este párametro especifica si se habilita o no el OOF.
    .EXAMPLE
        Set-ARRSkype4BCOnfig.ps1 -.
#>
#requires -Version 2
Param
(
    [Parameter(Mandatory = $true)]
    [String]$ARRConfigFile = 'C:\Windows\System32\inetsrv\config\applicationHost.config',
    $MsiFolder = 'C:/msi',
    [String]$SFBPool,
    [String]$SFBPoolURL,
    [String]$WACServer,
    [String]$WACURL
)

$ARRFile = 'C:\Users\Victor\Desktop\applicationHost.config'

Begin {
    Create-Item $MsiFolder -Type Directory
    Invoke-WebRequest 'http://download.microsoft.com/download/C/F/F/CFF3A0B8-99D4-41A2-AE1A-496C08BEB904/WebPlatformInstaller_amd64_en-US.msi' -OutFile $MsiFolder/WebPlatformInstaller_amd64_en-US.msi
    Start-Process "$MsiFolder/WebPlatformInstaller_amd64_en-US.msi" '/qn' -PassThru | Wait-Process
    cd 'C:/Program Files/Microsoft/Web Platform Installer'
    .\WebpiCmd.exe /Install /Products:'UrlRewrite2,ARRv3_0' /AcceptEULA /Log:$MsiFolder/WebpiCmd.log

    }
    Try {

    } Catch {
		Write-Error $Error[0]
        exit
	}
}

Process {
    
}

End {

}