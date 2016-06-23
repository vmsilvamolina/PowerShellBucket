<#
 	.SYNOPSIS
        Función para convertir un archivo HTML en un archivo MHT.
    .DESCRIPTION
        Función para convertir un archivo HTML en un archivo MHT.
    .PARAMETER  HtmlFile
        Archivo HTML que se desea convertir.
    .PARAMETER Destino
        Ruta donde se creará el archivo MHT.
    .EXAMPLE
        ConvertTo-Mht -HtmlFile 'C:\Users\Victor\Reporte.html' -Destino 'C:\Users\Victor\Reporte.mht'
#>
Param
(
    [Parameter(Mandatory=$true)][ValidateScript({Test-Path $_ -PathType 'Leaf'})][String] $HtmlFile,
    [Parameter(Mandatory=$true)][String] $Destino
)

Begin {
    $ObjMessage= New-Object -ComObject CDO.Message
    $ObjMessage.CreateMHTMLBody($HTMLFile)
}
Process {
    $Strm=New-Object -ComObject ADODB.Stream
    $Strm.Type = 2
    $Strm.Charset = "US-ASCII"
    $Strm.Open()
    $Dsk=$ObjMessage.DataSource
    $Dsk.SaveToObject($Strm, "_Stream")
}
End {
    $Strm.SaveToFile($Destino,2)
}