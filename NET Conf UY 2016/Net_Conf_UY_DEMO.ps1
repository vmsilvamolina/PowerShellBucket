#### WINDOWS CONTAINERS: How to install and create Windows Server Containers ####

#### Windows Server ####

# Instalar feature Containers
Install-WindowsFeature Containers

# Reiniciar el servidor
Restart-Computer -Force

# Asignar IP al servidor (para el caso de Windows Core)
Get-NetAdapter
New-NetIPAddress –InterfaceAlias “Ethernet” -IPAddress “192.168.0.10” –PrefixLength 24 -DefaultGateway 192.168.0.1
Set-DnsClientServerAddress -InterfaceAlias “Ethernet” -ServerAddresses 8.8.8.8

# Descargar, instalar y configurar Docker Engine
Invoke-WebRequest "https://download.docker.com/components/engine/windows-server/cs-1.12/docker.zip" -OutFile "$env:TEMP\docker.zip" -UseBasicParsing
Expand-Archive -Path "$env:TEMP\docker.zip" -DestinationPath $env:ProgramFiles

# Para uso rápido (sin reinicio)
$env:path += ";C:\Program Files\docker"

# Para uso persistente (reinicio necesario)
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\Docker", [EnvironmentVariableTarget]::Machine)

# Registrar el servicio
dockerd.exe --register-service

#Iniciar el servicio de docker
Start-Service docker

#### Docker en Windows Server ####

# Revisar versión de Docker
docker version

# Ver imagenes de Containers locales
docker images

# Buscar imagen de Windows Nano Server
docker search nanoserver

# Descarga la imagen de Nano Server (245 MB)
docker pull microsoft/nanoserver

# Crear un container con la imagen Nano Server y administrarlo con PowerShell
docker run -it microsoft/nanoserver powershell
