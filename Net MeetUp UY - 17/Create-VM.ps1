Function Create-VM {
Param
(
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$VMName,                      # DC01
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$VMFolder,                    # Carpeta destino (Ej: C:\VMS)
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$OSDisk,                      # Ruta del parent disk: C:\Meetup\VHDs\Master2012.vhdx
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$Memory,                      # Cantidad de memoria (en MB)
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$CPU                          # Cantidad de CPUs
)

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
    # Revisar los recursos requeridos para crear el VHD maestro
    $OSDiskUNC = "\\" + $VMHost + "\" + $OSDisk.Replace(":","$")
    $VHDFolder = $VMsFolder + "\" + $VMName + "\Virtual Hard Disks"
    $VHDFolderUNC = "\\" + $VMHost + "\" + $VHDFolder.Replace(":","$")
    $OSVHDFormat = $OSDisk.Split(".")[$OSDisk.Split(".").Count - 1]
    If (!(Test-Path $OSDiskUNC)) {
        Write-Host "El disco maestro: $OSDisk no existe" -ForegroundColor Red
    }
    # Revisar que no exista la VM
    If (!(Get-VM -Name $VMName -ComputerName $VMHost -ErrorAction SilentlyContinue)) {
        # Revisar que no exista el disco
        If (!(Test-Path "$VHDFolderUNC\$VMName.$OSVHDFormat")) {
            # Switch
            New-VMSwitch -Name SW-Interno -SwitchType Internal | Out-Null
            # Creando la VM
            New-VM -Name $VMName -ComputerName $VMHost -Path $VMsFolder -NoVHD -SwitchName SW-Interno | Out-Null
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
            #Iniciar la VM
            Start-VM -VMName $VMName -ComputerName $VMHost
        } Else {
            Write-Host "El disco: $VHDFolder\$VMName.$OSVHDFormat ya existe" -ForegroundColor Red
        }
    } Else {
        Write-Host "La VM ya existe" -ForegroundColor Red
    }
}
}

Create-VM -VMName MeetUp -VMFolder C:\VMS -OSDisk C:\VMS\Meetup_Disk.vhdx -Memory 2048 -CPU 2