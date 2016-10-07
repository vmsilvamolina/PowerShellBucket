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

)