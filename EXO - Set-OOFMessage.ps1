<#
 	.SYNOPSIS
        Este script permite configurar el mensaje de "Fuera de Oficina" (Out-of-Office) en un mailbox en particular.
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
        Set-OOFMessage.ps1 -Credential $Cre –InternalMessage “C:\Internal.txt” –ExternalMessage “C:\external.txt” –Enable True
        El mensaje de OOF se encuentra en los archivos C:\Internal.txt y C:\external.txt.
#>
#requires -Version 2
Param
(
    [Parameter(Mandatory = $true)]
    [System.Management.Automation.PSCredential]$Credential,
    [String] $Identity,
    [Parameter(Mandatory=$true)][ValidateScript({Test-Path $_ -PathType 'Leaf'})]
    [String] $InternalMessage,
    [Parameter(Mandatory=$true)][ValidateScript({Test-Path $_ -PathType 'Leaf'})] 
    [String] $ExternalMessage,
    [Parameter(Mandatory=$true)]
    [Bool] $Enable
)


Begin {
    $exitingSnaping = Get-PSSnapin -Verbose:$false | Where-Object {$_.Name -eq "Microsoft.Exchange.Management.PowerShell.E2010"}
    $existingSession = Get-PSSession -Verbose:$false | Where-Object {(($_.ConfigurationName -eq "Microsoft.Exchange") -and ($_.ComputerName -notlike "*outlook.com" ))}
    If(($exitingSnaping -ne $null) -or ($existingSession -ne $null) ) {
        Write-Error "Por favor, ejecutar una instancia de PowerShell en lugar de ejecutar la Exchange Management Shell"
        Exit
    }
    Try {
		#Si la sesión remota de PowerShell no existe, crear una nuev sesión.
		$existingSession = Get-PSSession -Verbose:$false | Where-Object {($_.ConfigurationName -eq "Microsoft.Exchange") -and ($_.ComputerName -like "*outlook.com" )}
		If ($existingSession -eq $null) {
			$verboseMsg = "Creating a new session to https://ps.outlook.com/powershell."
			$pscmdlet.WriteVerbose($verboseMsg)
			$O365Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://ps.outlook.com/powershell" -Credential $Credential -Authentication Basic -AllowRedirection
			#Si la sesión fue creada,importarla.
			Import-PSSession -Session $O365Session -Verbose:$false
			$existingSession = $O365Session
		} Else {
			$verboseMsg = "Se encontró una sesión existente, la creación de una nueva sesión fue omitida."
			$pscmdlet.WriteVerbose($verboseMsg)
		}
    } Catch {
		Write-Error $Error[0]
        exit
	}
}

Process {
    $internal = Get-Content $InternalMessage
    $external = Get-Content $ExternalMessage
    $Mailbox = Get-Mailbox -Identity $Identity
    If($Enable -eq $true) {
        Set-MailboxAutoReplyConfiguration $Mailbox.PrimarySmtpAddress -AutoReplyState enabled -ExternalAudience all -InternalMessage "$internal" -ExternalMessage "$external"
    } Else {
        Set-MailboxAutoReplyConfiguration $Mailbox.PrimarySmtpAddress -AutoReplyState disabled
    }
    
}