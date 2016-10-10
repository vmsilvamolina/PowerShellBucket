<#
 	.SYNOPSIS
        Función para excluir servidores del scope de SCCM a la hora de realizar la instalación de los agentes.
    .DESCRIPTION
        <Función para excluir servidores del scope de SCCM a la hora de realizar la instalación de los agentes.
    .PARAMETER  Server
        Indicar el o los servidores que van a ser excluidos de la implementación de los agentes.
    .EXAMPLE
        Set-SCCMExcludeServer.ps1 -Server $Server
        
#>

Param
(
    [Parameter(Mandatory=$true)][String] $Server
)

$RegistryPath = "HKEY_LOCAL_MACHINE/Software/Microsoft/SMS/Components/SMS_DISCOVERY_DATA_MANAGER"
$Name = "ExcludeServers"

New-ItemProperty -Path $RegistryPath -Name $Name -Value $Server -PropertyType DWORD -Force | Out-Null
Write-Verbose "Server: $Server excluded!"
