### Share Folder - Casinos del estado ###

$Sucursales = Import-Csv C:\Users\sorrego\Desktop\Sucursales.csv -Delimiter ";"
Write-host "Share Folder" -ForegroundColor Blue
foreach ($Sucursal in $Sucursales) {
    #Obtengo el número correspondiente
    $numeroSucursal = $Sucursal.Numero
    $nombreSucursal = $Sucursal.Nombre
    #Imprimo (sólo por información) la sucursal en la que voy a trabajar
    Write-host "Sucursal: " $nombreSucursal $numeroSucursal -ForegroundColor Green
    #Creo el Share CliConta
    [string]$shareCliConta = $numeroSucursal+"CliConta”
    try {
    New-SMBShare –Name $shareCliConta –Path "E:\Sucursales\$numeroSucursal\CliConta" –FullAccess everyone >> C:\users\sorrego\Desktop\salida.txt
    } catch {
    Write-Error $Error[0]
    }
    Write-Host "    $shareCliConta creado correctamente"
    #CliMaq
    [string]$shareCliMaq = $numeroSucursal+"CliMaq”
    try {
    New-SMBShare –Name $shareCliMaq –Path “E:\Sucursales\$numeroSucursal\CliMaq” –FullAccess everyone >> C:\users\sorrego\Desktop\salida.txt
    } catch {
    Write-Error $Error[0]
    }
    Write-Host "    $shareCliMaq creado correctamente"
}