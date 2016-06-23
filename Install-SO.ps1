Function Install-SO {
Param
(
[parameter(mandatory=$true)][ValidateNotNullOrEmpty()]$ISO,
[parameter(mandatory=$true)][ValidateNotNullOrEmpty()]$VHDX,
[parameter(mandatory=$true)][ValidateNotNullOrEmpty()]$SizeGB,
[parameter(mandatory=$false)][ValidateNotNullOrEmpty()]$Index
)

If($Index -eq $null){
    Mount-DiskImage -ImagePath $ISO
    $ISOImage = Get-DiskImage -ImagePath $ISO | Get-Volume
    $ISODrive = [string]$ISOImage.DriveLetter + ":"
    $IndexList = Get-WindowsImage -ImagePath $ISODrive\sources\install.wim
    $IndexList
    Dismount-DiskImage -ImagePath $ISO
    Write-Host "Seleccionar imagen (0 = Salir):" -NoNewline
    $Index = "-1"
    While($Index -eq "-1"){
        $Index = Read-host
        If ($Index -eq "0") {
            Write-Host "Terminando..."
            Exit
        }
    }
}

Mount-DiskImage -ImagePath $ISO
$ISOImage = Get-DiskImage -ImagePath $ISO | Get-Volume
$ISODrive = [string]$ISOImage.DriveLetter + ":"

$VMDisk = New-VHD –Path $VHDX -SizeBytes $SizeGB
Mount-DiskImage -ImagePath $VHDX
$VHDDisk = Get-DiskImage -ImagePath $VHDX | Get-Disk
$VHDDiskNumber = [string]$VHDDisk.Number

Initialize-Disk -Number $VHDDiskNumber -PartitionStyle MBR
$VHDDrive = New-Partition -DiskNumber $VHDDiskNumber -UseMaximumSize -AssignDriveLetter -IsActive | Format-Volume -Confirm:$false
$VHDVolume = [string]$VHDDrive.DriveLetter + ":"

Dism.exe /Apply-Image /ImageFile:$ISODrive\Sources\install.wim /index:$Index /ApplyDir:$VHDVolume\

BCDBoot.exe $VHDVolume\Windows /s $VHDVolume /f BIOS

Dismount-DiskImage -ImagePath $ISO
Dismount-DiskImage -ImagePath $VHDX

}

Install-SO -VHDX C:\VMS\Prueba.vhdx -ISO C:\ISOS\en_windows_server_2012_r2_x64_dvd_2707946.iso -SizeGB 42GB
