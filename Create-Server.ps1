Function Create-Server {
Param
(
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$VMRole,                      # Rol de la VM (DomainController, etc)
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$VMName,                      # DC01
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$VMFolder,                    # Carpeta destino (Ej: C:\VMS)
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$OSDisk,                      # Ruta del parent disk: C:\SFBLab\VHDs\Master2012.vhdx
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$Memory,                      # Cantidad de memoria (en MB)
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$CPU,                         # Cantidad de CPUs
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$Password
)

#Funciones auxiliares
Function ConfigureServer {
Param
(
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$Path,
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$IP
)

$section = $IP.Split(".")
$Gateway = $section[0] + "." + $section[1] + "." + $section[2] + "." + "254"

@"
############ IP
# Configure a static IP address
New-NetIPAddress -IPAddress $IP -InterfaceAlias "Ethernet" -DefaultGateway $Gateway -AddressFamily IPv4 -PrefixLength 24
# Configure a network connection with a new DNS server address
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 127.0.0.1
############ Acceso remoto
(Get-WmiObject win32_TerminalServiceSetting -Namespace root\cimv2\TerminalServices).SetAllowTSConnections(1) 
Import-Module netsecurity -ea stop
Get-NetFirewallRule | ? {'$_'.DisplayName -like "Remote Desktop*"} | Set-NetFirewallRule -Enabled true 
############ Próximo inicio
reg add HKLM\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell /v ExecutionPolicy /t REG_SZ /d "Unrestricted" /f
New-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" -Name "ServerRole" -Value 'powershell.exe -Command `"& C:\SFBLab\Server-Role.ps1`"'
Restart-Computer
"@ | Out-File $Path
}

Function Server-Role {
Param
(
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$Path,
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$DomainName,
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$Pass
)

$DomainNetbiosName = $DomainName.Split(".")[0]

@"
############### AD DS
# Características necesarias
Import-Module ServerManager
Install-WindowsFeature -Name AD-Domain-Services –IncludeManagementTools
# DC (http://technet.microsoft.com/library/hh472162)
# Próximo inicio
New-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -Value "1"
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUsername" -Value "$DomainNetbiosName\Administrator"
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultPassword" -Value "$Pass"
regedit
pause
Install-ADDSForest -DatabasePath C:\Windows\NTDS -DomainMode Win2012R2 -NoDnsOnNetwork -DomainName $DomainName -DomainNetBIOSName $DomainNetbiosName -ForestMode Win2012R2 -LogPath C:\Windows\NTDS -SysvolPath C:\Windows\SYSVOL -SafeModeAdministratorPassword (ConvertTo-SecureString $Pass -AsPlainText -Force) -Force
Write-EventLog -LogName System -Source Server -EventId 12345 -Message 'Terminó la configuración inicial. Reiniciando el servidor.'
Restart-Computer
"@ | Out-File $Path
}

#Importar el modulo de Hyper-V
Try {
    Import-Module Hyper-V
} Catch {
    $Error[0]
    Exit
}

If ((Get-Module Hyper-V)) {
    If (!(Get-VMHost -ComputerName localhost -ErrorAction SilentlyContinue)) {
        Write-Host "Este servidor no es un host de Hyper-V" -ForegroundColor Red
        Exit
    } Else {
        $VMHost = Get-VMHost | select Name -ExpandProperty Name
    }
    $VMsFolder = $VMFolder
    # Revisar los recursos requeridos para crear Check required resources for creation exist
    $OSDiskUNC = "\\" + $VMHost + "\" + $OSDisk.Replace(":","$")
    $VHDFolder = $VMsFolder + "\" + $VMName + "\Virtual Hard Disks"
    $VHDFolderUNC = "\\" + $VMHost + "\" + $VHDFolder.Replace(":","$")
    $OSVHDFormat = $OSDisk.Split(".")[$OSDisk.Split(".").Count - 1]
    If (!(Test-Path $OSDiskUNC)) {
        Write-Host "El disco maestro (parent disk): $OSDisk no existe" -ForegroundColor Red
    }
    # Revisar que no exista la VM
    If (!(Get-VM -Name $VMName -ComputerName $VMHost -ErrorAction SilentlyContinue)) {
        # Revisar que no exista el disco
        If (!(Test-Path "$VHDFolderUNC\$VMName.$OSVHDFormat")) {
            # Revisar los SW
            If (!(Get-VMSwitch -SwitchType Internal)) {
                New-VMSwitch -Name SFB-Interno -SwitchType Internal
                $SWname = "SFB-Interno"
            } Else {
                If (!(Get-VMSwitch -Name SFB-Interno)) {
                    # Selecciono el primer SW interno que exista
                    $SWname = Get-VMSwitch -SwitchType Internal | select -First 1 -ExpandProperty Name
                } Else {
                    $SWname = "SFB-Interno"
                }
            }
            # Creando la VM
            New-VM -Name $VMName -ComputerName $VMHost -Path $VMsFolder -NoVHD -SwitchName $SWname | Out-Null
            # Configurando los CPUs
            Set-VMProcessor -VMName $VMName -ComputerName $VMHost -Count $CPU
            # Configurando la memoria
            [Int64]$VMmemory = $Memory
            $VMmemory = $VMmemory * 1048576
            Set-VMMemory -VMName $VMName -ComputerName $VMHost -DynamicMemoryEnabled $false -StartupBytes $VMmemory
            # Creación del disco diferencial
            New-VHD -ComputerName $VMHost -Path "$VHDFolder\$VMName.$OSVHDFormat" -ParentPath $OSDisk | Out-Null 
            # Montar el disco en el IDE 0:0
            Add-VMHardDiskDrive -VMName $VMName -ComputerName $VMHost -ControllerType IDE -ControllerNumber 0 -ControllerLocation 0 -Path "$VHDFolder\$VMName.$OSVHDFormat"
            # Montar el VHD para copiar los archivos: scripts y unattend.xml
            $Drive = (Mount-VHD -Path "$VHDFolderUNC\$VMName.$OSVHDFormat" -ErrorAction SilentlyContinue -PassThru | Get-Disk | Get-Partition).DriveLetter
            If ($Drive -ne $null) {
                # Generando el archivo unattend.xml
                @"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="specialize">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <ComputerName>$VMName</ComputerName>
            <TimeZone>S.A. Eastern Standard Time</TimeZone>
            <RegisteredOrganization>SFB Lab</RegisteredOrganization>
            <RegisteredOwner>Victor Silva</RegisteredOwner>
        </component>
        <component name="Microsoft-Windows-TerminalServices-LocalSessionManager" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <fDenyTSConnections>false</fDenyTSConnections>
        </component>
        <component name="Microsoft-Windows-TerminalServices-RDP-WinStationExtensions" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <UserAuthentication>0</UserAuthentication>
        </component>
    </settings>
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <UserAccounts>
                <AdministratorPassword>
                    <Value>$Password</Value>
                    <PlainText>true</PlainText>
                </AdministratorPassword>
            </UserAccounts>
            <AutoLogon>
                <Password>
                    <Value>$Password</Value>
                    <PlainText>true</PlainText>
                </Password>
                <Enabled>true</Enabled>
                <LogonCount>2</LogonCount>
                <Username>administrator</Username>
            </AutoLogon>
            <FirstLogonCommands>
                <SynchronousCommand wcm:action="add">
                    <CommandLine>powershell.exe -ExecutionPolicy Unrestricted &amp;&apos;C:\SFBLab\ConfigureServer.ps1&apos;</CommandLine>
                        <Order>1</Order>
                        <RequiresUserInput>false</RequiresUserInput>
                </SynchronousCommand>
            </FirstLogonCommands>
            <OOBE>
                <HideEULAPage>true</HideEULAPage>
                <SkipMachineOOBE>true</SkipMachineOOBE>
            </OOBE>
        </component>
    </settings>
</unattend>

"@ | Out-File "$Drive`:\unattend.xml" -Encoding ASCII
                # Comprobar que no existe la carpeta para guardar los scripts
                If (!(Test-Path "$Drive`:\SFBLab")) {
                    New-Item -Path "$Drive`:\SFBLab" -ItemType Directory | Out-Null
                }
                #Script para la configuración inicial
                ConfigureServer -Path "$Drive`:\SFBLab\ConfigureServer.ps1" -IP "10.20.10.1"
                # Generar el archivo según el rol (DomainController, etc)
                If ($VMRole -ge "DomainController") {
                    Server-Role -Path "$Drive`:\SFBLab\Server-Role.ps1" -DomainName "sfb.interno" -Pass "Password.01"
                }
                # Generando el cmd de limpieza (borra el unattend.xml)
                @"
@echo off
if exist %SystemDrive%\unattend.xml del %SystemDrive%\unattend.xml

"@ | Out-File "$Drive`:\SFBLab\SetupComplete.cmd" -Encoding ASCII
                # Desmontando el VHD
                Dismount-VHD -Path "$VHDFolderUNC\$VMName.$OSVHDFormat" -ErrorAction SilentlyContinue
                # Iniciando la VM
                Start-VM -VMName $VMName -ComputerName $VMHost
            } Else {
                Exit
            }
        } Else {
            Write-Host "El disco: $VHDFolder\$VMName.$OSVHDFormat ya existe" -ForegroundColor Red
        }
    } Else {
        Write-Host "La VM ya existe" -ForegroundColor Red
    }
}
}

Create-Server -VMRole DomainController -VMName DC01 -VMFolder C:\VMS -OSDisk C:\SFBLab\VHDs\Master2012.vhdx -Memory 2048 -CPU 2 -Password "Password.01"
