### RemoteApp - Casinos del estado ###
cls
Import-Module RemoteDesktop
Import-Module ActiveDirectory
$Sucursales = Import-Csv C:\Users\sorrego\Desktop\Sucursales_all.csv -Delimiter ";"
Write-host "RemoteApp" -ForegroundColor Blue
foreach ($Sucursal in $Sucursales) {
    #Obtengo el número correspondiente
    $numeroSucursal = $Sucursal.Numero
    $nombreSucursal = $Sucursal.Nombre
    #Imprimo (sólo por información) la sucursal en la que voy a trabajar
    Write-host "Sucursal: " $nombreSucursal $numeroSucursal -ForegroundColor Green
    #Genero las RemoteApp para cada ejecutable
    Write-host "    CliConta Apps" -ForegroundColor Green
    #CliConta
    [array]$exesCliConta = "app1","app2"
    [string]$grupoFiltroConta = "*"+$numeroSucursal+"CliConta"
    $GrupoCONTA = Get-ADGroup -filter {name -like $grupoFiltroConta}
    foreach ($exeCliConta in $exesCliConta) {
        if (Test-Path "E:\Sucursales\$numeroSucursal\CliConta\$exeCliConta.exe") {
            try {
                New-RDRemoteApp -Alias "$exeCliConta-$nombreSucursal" -DisplayName "$exeCliConta - $nombreSucursal" -FilePath "E:\Sucursales\$numeroSucursal\CliConta\$exeCliConta.exe" -ShowInWebAccess 1 -CollectionName "App Collection" -ConnectionBroker "remoteappserver.dgc.local" -UserGroups $GrupoCONTA.Name >> C:\users\sorrego\Desktop\Salida.txt
                Write-host "        $exeCliConta - $numeroSucursal agregada correctamente"
            } catch {
            Write-Error $Error[0]
            }
        } else {
            Write-host "        No existe el ejecutable $exeCliConta"
        }
    }
    Write-host "    CliMaq Apps" -ForegroundColor Green
    #CliMaq
    [array]$exesCliMaq = "app3", "app4"
    [string]$grupoFiltroMaq = "*"+$numeroSucursal+"CliMaq"
    $GrupoMAQ = Get-ADGroup -filter {name -like $grupoFiltroMaq}
    foreach ($exeCliMaq in $exesCliMaq) {
        if (Test-Path "E:\Sucursales\$numeroSucursal\CliMaq\$exeCliMaq.exe") {
            try {
                New-RDRemoteApp -Alias "$exeCliMaq-$numeroSucursal" -DisplayName "$exeCliMaq - $nombreSucursal" -FilePath "E:\Sucursales\$numeroSucursal\CliMaq\$exeCliMaq.exe" -ShowInWebAccess 1 -CollectionName "App Collection" -ConnectionBroker "remoteappserver.dgc.local" -UserGroups $GrupoMAQ.Name >> C:\users\sorrego\Desktop\Salida.txt
                Write-host "$exeCliMaq - $numeroSucursal agregada correctamente"
            } catch {
                Write-Error $Error[0]
            }
        } else {
            Write-host "        No existe el ejecutable $exeCliMaq"
        }
    }
    Write-host "    Grupo" -ForegroundColor Green
    Write-Host "        CliConta: $GrupoCONTA"
    Write-Host "        CliMaq: $GrupoMAQ"
}