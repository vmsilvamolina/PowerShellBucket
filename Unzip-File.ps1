<#
 	.SYNOPSIS
        Descomprime un archivo desde la consola de PowerShell.
    .DESCRIPTION
        Descomprime un archivo desde la consola de PowerShell.
    .PARAMETER  FileName
        Nombre y ruta del archivo que se desea descomprimir.
    .PARAMETER Destination
        Ruta y nombre donde se guardrán los archivos luego de la descompresión.
    .EXAMPLE
        Set-OOFMessage.ps1 -Credential $Cre –InternalMessage “C:\Internal.txt” –ExternalMessage “C:\external.txt” –Enable True
        El mensaje de OOF se encuentra en los archivos C:\Internal.txt y C:\external.txt.
#>
Param
(
    [Parameter(Mandatory=$true)][ValidateScript({Test-Path $_ -PathType 'Leaf'})]
    [String] $FileName,
    [Parameter(Mandatory=$true)][ValidateScript({Test-Path $_ -PathType 'Leaf'})] 
    [String] $Destination
)


Begin {
    $Unzip = New-Object -ComObject Shell.Application

    
    Try {
	
    } Catch {
		Write-Error $Error[0]
        exit
	}
}

Process {
    $ZipFile = $Unzip.NameSpace($FileName)
    $Final = $Unzip.namespace($Destination)
    $Final.Copyhere($ZipFile.items())

   
}

End {

}