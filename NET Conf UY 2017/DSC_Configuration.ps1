#Definimos la IP del servidor
$IPdelServidor = '192.168.1.43'

#Establecemos la configuración del servidor
Configuration DSCLinuxWeb {
    Import-DSCResource -Module nx

    Node $IPdelServidor {
        nxPackage apache2Install {
            Name = "apache2"
            Ensure = "Present"
            PackageManager = "Apt"
        }

        nxService apache2Service {
            Name = "apache2"
            Controller = "init"
            Enabled = $true
            State = "Running"
        }    

        nxFile apache2File {
            Ensure = "Present"
            Type = "File"
            DestinationPath = "/var/www/index.html"
            Contents = '<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<title>Webpage on Linux</title>
<style type="text/css">
.barra {
    background-color: #3A539B;
    color: #FFFFFF;
    line-height: 20px;
    padding: 15px;
    padding-left: 35px;
    border-radius:25px;
}
body {
    font-family: Segoe UI Light,SegoeUILightWF,Arial,Sans-Serif;
}
</style>
</head>
<body>
<h2 class="barra">Este servidor Apache y la página web fueron instalados con PowerShell DSC</h3>
</body>
</html>'
        }
    }
}

#Generamos los archivos de configuración y los guardamos en una ruta específica
DSCLinuxWeb -OutputPath:"C:\DSCLinux"

#Iniciamos una sesión contra el servidor
$Node = $IPdelServidor
$Credential = Get-Credential
$opt = New-CimSessionOption -UseSsl:$true -SkipCACheck:$true -SkipCNCheck:$true -SkipRevocationCheck:$true
$Sess=New-CimSession -Credential:$credential -ComputerName:$Node -Port:5986 -Authentication:basic -SessionOption:$opt -OperationTimeoutSec:90

#Aplicamos la configuración
Start-DscConfiguration -Path:"C:\DSCLinux" -CimSession:$Sess -Wait -Verbose