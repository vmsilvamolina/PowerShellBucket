# Instalar feature Containers
Install-WindowsFeature Containers

# Reiniciar el servidor
Restart-Computer -Force

Get-NetAdapter
New-NetIPAddress –InterfaceAlias “Ethernet” -IPAddress “192.168.0.10” –PrefixLength 24 -DefaultGateway 192.168.0.1
Set-DnsClientServerAddress -InterfaceAlias “Wired Ethernet Connection” -ServerAddresses 8.8.8.8


# Descargar, instalary configurar Docker Engine
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

#############################

docker version

docker images
docker search nanoserver

# Descarga la imagen de Nano Server (245 MB)
docker pull microsoft/nanoserver

#############################

docker run -it microsoft/nanoserver powershell