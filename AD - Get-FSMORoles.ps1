function Get-FSMORoles
{
	<#
	.SYNOPSIS
		Recupera la información de los roles FSMO en el Dominio/Forest.
	.DESCRIPTION
		Recupera la información de los roles FSMO en el Dominio/Forest.
	.EXAMPLE
		Get-FSMORole
    .EXAMPLE
		Get-FSMORole -Credential (Get-Credential -Credential "CONTOSO\Admin")
    .NOTES
        Victor Silva
        blog.victorsilva.com.uy
        @vmsilvamolina
	#>
	[CmdletBinding()]
	Param (
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty
	)

	Begin {
		Try {
			# Carga el módulo de ActiveDirectory en caso de que no esté cargado.
			If (-not (Get-Module -Name ActiveDirectory)) { Import-Module -Name ActiveDirectory -ErrorAction 'Stop' -Verbose:$false }
		} Catch {
			Write-Warning -Message "[Begin] Error inesperado."
			Write-Warning -Message $Error[0]
		}
	} Process {
		Try {
			If ($PSBoundParameters['Credential']) {
                # Consulta con las credenciales asignadas
				$ForestRoles = Get-ADForest -Credential $Credential -ErrorAction 'Stop' -ErrorVariable ErrorGetADForest
				$DomainRoles = Get-ADDomain -Credential $Credential -ErrorAction 'Stop' -ErrorVariable ErrorGetADDomain
			} Else {
                # Consulta con las credenciales actuales
				$ForestRoles = Get-ADForest
				$DomainRoles = Get-ADDomain
			}
            # Definición de las propiedades
			$Properties = @{
				SchemaMaster = $ForestRoles.SchemaMaster
				DomainNamingMaster = $ForestRoles.DomainNamingMaster
				InfraStructureMaster = $DomainRoles.InfraStructureMaster
				RIDMaster = $DomainRoles.RIDMaster
				PDCEmulator = $DomainRoles.PDCEmulator
			}
			New-Object -TypeName PSObject -Property $Properties
		} Catch {
			Write-Warning -Message "[Process] Error inesperado"
			IF ($ErrorGetADForest) { Write-Warning -Message "[Process] Error al recuperar información del Forest."}
			IF ($ErrorGetADDomain) { Write-Warning -Message "[PROCESS] Error While retrieving Domain information"}
			Write-Warning -Message $Error[0]
		}
	}
}