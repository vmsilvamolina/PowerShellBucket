#####################################################################
# 1.2 Agregar: gráficas con css y js? 
# 1.1 Hora inicio - hora finalizado
# 1.0 versión funcional
#####################################################################

#region Variables y parametros
cls
Set-Location "C:\Users\Victor\Desktop"
$ChecklistFile = (Get-Location).Path + "\CheckList.html"
[string]$Char = [char]9608
$CPUtime = 10
$CurrentTime = Get-Date -Format D
$Computers = "VSILVA"
[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")
#endregion

Function Set-PrintMessage {
Param($Module,$Process)

If ($Process -eq "Begin") {
    $BeginTime = Get-Date -Format hh:mm:ss
    Write-Host "########## AutoCheck - Hora de inicio: $BeginTime ##########" -ForegroundColor Green
}

If ($Process -eq "Start") {
    Write-Host ""
    Write-Host "Recolectando información de $Module..."
    Write-Host ""
}

If ($Process -eq "StartApplication") {
    Write-Host ""
    Write-Host "Recolectando información de la aplicación: $Module"
    Write-Host ""
}

If ($Process -eq "Info") {
    Write-Host "     Definir acciones sobre el módulo: $Module" -ForegroundColor Yellow
}
If ($Process -eq "StatusOK") {
    Write-Host "     Información de $Module - $Computer : Recolectada correctamente" -ForegroundColor Gray
}
If ($Process -eq "Error") {
    Write-Host "     Información de $Module - $Computer : Error de acceso" -ForegroundColor Red
}
If ($Process -eq "End") {
    Write-Host ""
    $EndTime = Get-Date -Format hh:mm:ss
    Write-Host "########## Hora de finalizado: $EndTime ##########" -ForegroundColor Green
}
}

Function Create-DoughnutChart() {
param([string]$FileName, $Used, $Free)
    
    #Crea el objeto gráfica
    $Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart
    $Chart.Width = 170
    $Chart.Height = 100
    
    #Crea el área de la gráfica para construir
    $ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
    $Chart.ChartAreas.Add($ChartArea)
    [void]$Chart.Series.Add("Data")
    
    #Agregar los valores a la gráfica
    $Dato1 = New-Object System.Windows.Forms.DataVisualization.Charting.DataPoint(0, $Used)
    $Dato1.AxisLabel = "$Used" + " GB"
    $Dato1.Color = [System.Drawing.ColorTranslator]::FromHtml("#A55353")
    $Chart.Series["Data"].Points.Add($Dato1)
    $Dato2 = New-Object System.Windows.Forms.DataVisualization.Charting.DataPoint(0, $Free)
    $Dato2.AxisLabel = "$Free" + " GB"
    $Dato2.Color = [System.Drawing.ColorTranslator]::FromHtml("#99CD4E")
    $Chart.Series["Data"].Points.Add($Dato2)
    
    #Defino la forma de la gráfica
    $Chart.Series["Data"].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Doughnut
    $Chart.Series["Data"]["PieLabelStyle"] = "Disabled"

    #Leyenda
    $Legend = New-Object system.Windows.Forms.DataVisualization.Charting.Legend
    $Legend.name = "Leyenda"
    $Chart.Legends.Add($Legend)
    
    #Guarda la gráfica como archivo .png
    $Chart.SaveImage($FileName + ".png","png")
}

Function Create-LineChart {
param([string]$FileName, $Values)

    #Crea el objeto gráfica
    $Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart
    $Chart.Width = 170
    $Chart.Height = 100

    #Crea el área de la gráfica para construir
    $ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
    $ChartArea.AxisX.Title = "Tiempo (s)"
    $ChartArea.AxisX.Interval = 5
    $ChartArea.AxisY.Interval = 10
    $ChartArea.AxisY.LabelStyle.Format = "{#}%"
    $Chart.ChartAreas.Add($ChartArea)
    [void]$Chart.Series.Add("Data")
    
    #Agrega los valores a la gráfica
    $Chart.Series["Data"].Points.DataBindXY($Values.Keys, $Values.Values)
    
    #Defino la forma de la gráfica
    $Chart.Series["Data"].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Line
    $Chart.Series["Data"].BorderWidth = 3
    $Chart.Series["Data"].Color = "#3A539B"

    #Guarda la gráfica como archivo .png
    $Chart.SaveImage($FileName + ".png","png")
}

Function Get-AutoChecklist {

If ((Test-Path $ChecklistFile) -eq $true) {
    Remove-Item $ChecklistFile
}

$Form.Controls.Add($GroupBoxRun)

$HTMLHeader = @" 
<!doctype html>
<html lang="es">
<head>
<meta charset="UTF-8">
<title>CheckList de Servidores</title>
<style type="text/css">

body {
    font-family: Segoe UI Light,SegoeUILightWF,Arial,Sans-Serif;
}

.barra {
    background-color: #3A539B;
    color: #FFFFFF;
    line-height: 20px;
    padding: 15px;
    padding-left: 35px;
    border-radius:25px;
}

.encabezado {
    color: #FFFFFF;
    line-height: 40px;
    padding: 25px;
    background: #00A2F4;
}

.message {
    margin-left: 30px
}

.diez {
    width: 10%
}

.veinte {
    width: 20%
}

.bold {
    font-weight: bold;
    font-size: larger;
}

.size {
    padding: 10px
}

.disk th {
    background-color:#247687;
	font-size: 12px;
}

table {
	color: black;
    margin: 10px;
    box-shadow: 1px 1px 6px #000;
    -moz-box-shadow: 1px 1px 6px #000;
    -webkit-box-shadow: 1px 1px 6px #000;
    border-collapse: separate;
    }

table td {
	font-size: 14px;
}

table th {
    background-color:#647687;
    color:#ffffff;
   	font-size: 14px;
	font-weight: bold;
}

.list table {
    margin-left:auto; 
    margin-right:auto;
}

.list td, .list th {
    padding:3px 7px 2px 7px;
}

h2{
    clear: both; 
    font-size: 130%;
}

h3{
    clear: both;
    font-size: 115%;
    margin-left: 20px;
    margin-top: 15px;
    margin-bottom: 5px;
}

p{
    margin-left: 20px; font-size: 14px;
}

div .column {
    width: 490px; 
    float: left;
}

div .second{
    margin-left: 20px;
}

div {
    padding-bottom: 40px;
    width: 1000px;
}

</style>
</head>
<body>
<div>
<h1 class="encabezado"> Reporte de Servidores - $CurrentTime</h1>
"@
$HtmlFile += $HTMLHeader
$HtmlFile | Out-File -Encoding utf8 -FilePath $ChecklistFile

Set-PrintMessage -Process Begin

####################################################################################
############ Información del sistema (unidades, tamaños y performance) #############
####################################################################################

If ($CheckBoxSystem.Checked -eq $true) {
    #Orientacion de columna
    $HtmlDisksHeader =@"
<div>
<section class="list">
<h2 class="barra">Información del sistema</h2>
<table>
<tr>
  <th class="diez">Servidor</th>
  <th>Datos de las unidades</th>
  <th>Memoria</th>
  <th>CPU</th>
</tr>
"@
    $HtmlFile += $HTMLDisksHeader
    #Recoleccion de Info
    Set-PrintMessage -Module Sistema -Process Start
    Foreach ($Computer in $Computers) {
        If (Test-Connection -ComputerName $Computer -Count 1 -Quiet) {
            ## Información de discos ##
            $DiskInfo = Get-WMIObject -ComputerName $Computer -Class Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3}  `
	        | Select-Object @{Name="Unidad";Expression={($_.Name)}},
                            @{Name="Total (GB)";Expression={([math]::Round($_.size/1gb))}},
                            @{Name="Libre (GB)";Expression={([math]::Round($_.freespace/1gb))}},
                            @{Name="% Uso";Expression={(100-([math]::Round($_.freespace/$_.size*100)))}},
                            @{Name="Grafica de uso";Expression={
                                $UsedPer= (($_.Size - $_.Freespace)/$_.Size)*100
                                $UsedPer = [math]::Round($UsedPer)
                                $UsedGraph = $Char * (($UsedPer * 20 )/100)
                                $FreeGraph = $Char * (20-(($UsedPer * 20 )/100))
                                "xopenspan style=xcomillascolor:#A55353xcomillasxclose{0}xopen/spanxclosexopenspan style=xcomillascolor:#99CD4Excomillasxclose{1}xopen/spanxclose" -f $UsedGraph,$FreeGraph}} | ConvertTo-HTML -fragment
            #Reemplazo de caracteres...
            $DiskInfo = $DiskInfo -replace "xopen","<"
            $DiskInfo = $DiskInfo -replace "xclose",">"
            $DiskInfo = $DiskInfo -replace "xcomillas",'"'
            ## Información de memoria ##
            $SystemInfo = Get-WmiObject -ComputerName $Computer -Class Win32_OperatingSystem  | Select-Object Name, TotalVisibleMemorySize, FreePhysicalMemory
            $TotalRAM = [Math]::Round($SystemInfo.TotalVisibleMemorySize/1MB, 1)
            $FreeRAM = [Math]::Round($SystemInfo.FreePhysicalMemory/1MB, 1)
            $UsedRAM = $TotalRAM - $FreeRAM
            Create-DoughnutChart -FileName ((Get-Location).Path + "\GraficaMemoria-$Computer") -Used $UsedRAM -Free $FreeRAM
            ## Información de CPU ##
            $CPUtotal = @{}
            for ($i=1; $i -le $CPUtime; $i++) {
                Start-Sleep -Seconds 1
                $CPU = Get-WmiObject -Class win32_processor -ComputerName $Computer | select LoadPercentage -ExpandProperty LoadPercentage -First 1
                $CPUtotal.Add($i, $CPU)
            }
            Create-LineChart -FileName ((Get-Location).Path + "\GraficaCPU-$Computer") -Values $CPUtotal
            
            $HtmlSystem = @"
<tr>
  <td class="bold size">$Computer</td>
  <td class="disk">$DiskInfo</td>
  <td> <img src=GraficaMemoria-$Computer.png alt="Gráfica Memoria"> </td>
  <td> <img src=GraficaCPU-$Computer.png alt="Gráfica CPU"> </td>
</tr>
"@
            Set-PrintMessage -Module Sistema -Process StatusOK
        }
        Else {
            $SystemInfo = "Sin acceso al servidor"
            $HtmlSystem = @"
<tr>
  <td class="bold size">$Computer</td>
  <td class="size">$SystemInfo</td>
</tr>
"@
            Set-PrintMessage -Module Sistema -Process Error
        }
        $HtmlFile += $HtmlSystem
    }
    $HtmlFile | Out-File $ChecklistFile -Force
    $HtmlSystemClose = @"
</table>
</section>
</div>
"@
    Add-Content -Path $ChecklistFile -Value $HtmlSystemClose
}

####################################################################################
############# Información de Antivirus (producto, definición, status) ##############
####################################################################################

<# Revisar si son servidores con Windows 2012 R2 y habilitar las siguientes reglas en el Firewall:

    COM+ Network Access (DCOM-In)
    COM+ Remote Administration (DCOM-In)

#>

If ($CheckBoxAntivirus.Checked -eq $true) {
    #Orientacion columna
    $HtmlAntivirusHeader =@"
<div class="column">
<section class="list">
<h2 class="barra">Antivirus</h2>
<table>
<tr>
  <th class="veinte">Servidor</th>
  <th>Información</th>
</tr>
"@
    Add-Content -Path $ChecklistFile -Value $HtmlAntivirusHeader
    #Recoleccion de Info
    Set-PrintMessage -Module Antivirus -Process Start
    $Web = Invoke-WebRequest –Uri http://www.microsoft.com/security/portal/definitions/whatsnew.aspx
    $Lista = @()
    $Lista = $Web.ParsedHTML.getElementsByTagName("option") | select InnerText
    Foreach ($Computer in $Computers) {
        If (Test-Connection -ComputerName $Computer -Count 1 -Quiet) {
            #Symantec
            If ((Test-Path "HKLM:\SOFTWARE\Symantec\Symantec Endpoint Protection") -eq $true) {
                [string]$RegistryPath = "SOFTWARE\Symantec\Symantec Endpoint Protection\CurrentVersion\Content"
                [string]$RegistryKeyName = "virusdefs"
                $RegAV = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Computer)
                $RegistryKey = $RegAV.opensubkey($RegistryPath,$true)
                $RegistryKeyValue = $RegistryKey.getvalue($RegistryKeyName)
                Set-PrintMessage -Module Antivirus -Process StatusOK
            #Microsoft (Essentials, EndPoint, etc)
            } ElseIf ((Test-Path "HKLM:\SOFTWARE\Microsoft\Microsoft Antimalware") -eq $true) {
                $LastDefinition = $Lista[0].innerText
                $UmbralDefinition = $Lista[19].innerText
                $LocalDefinition = Get-ItemProperty -Path 'Registry::HKLM\SOFTWARE\Microsoft\Microsoft Antimalware\Signature Updates' -Name AVSignatureVersion | Select-Object -ExpandProperty AVSignatureVersion
                $ProductName = Get-ItemProperty -Path 'Registry::HKLM\SOFTWARE\Microsoft\Microsoft Antimalware Setup\RememberedProperties' -Name PRODUCT_SKU | Select-Object -ExpandProperty PRODUCT_SKU
                If ($LocalDefinition -ge $LastDefinition) {
                    $AntivirusInfo = $ProductName + ": OK / Versión: " + $LocalDefinition
                    $HtmlAntivirus = @"
<tr>
  <td class="bold size">$Computer</td>
  <td class="size">$AntivirusInfo</td>
</tr>
"@
                } Else {
                    If ($LocalDefinition -gt $UmbralDefinition) {
                        $AntivirusInfo = $ProductName + ": Nuevas defs. / Versión: " + $LocalDefinition
                        $HtmlAntivirus = @"
<tr>
  <td class="bold size">$Computer</td>
  <td class="size">$AntivirusInfo</td>
</tr>
"@
                    } Else {
                        $AntivirusInfo = $ProductName + ": Desactualizado / Versión: " + $LocalDefinition
                        $HtmlAntivirus = @"
<tr>
  <td class="bold size">$Computer</td>
  <td class="size">$AntivirusInfo</td>
</tr>
"@
                    }
                }
            #Windows Antimalware
            } Else {
                $LastDefinition = $Lista[0].innerText
                $UmbralDefinition = $Lista[19].innerText
                $LocalDefinition = Get-ItemProperty -Path 'Registry::HKLM\SOFTWARE\Microsoft\Windows Defender\Signature Updates' -Name AVSignatureVersion | Select-Object -ExpandProperty AVSignatureVersion
                If ($LocalDefinition -ge $LastDefinition) {
                    $AntivirusInfo = "Windows Defender actualizado"
                    $HtmlAntivirus = @"
<tr>
  <td class="bold size">$Computer</td>
  <td class="size">$AntivirusInfo</td>
</tr>
"@
                } Else {
                    If ($LocalDefinition -gt $UmbralDefinition) {
                        $AntivirusInfo = "Windows Defender tiene nuevas definiciones"
                        $HtmlAntivirus = @"
<tr>
  <td class="bold size">$Computer</td>
  <td class="size">$AntivirusInfo</td>
</tr>
"@
                    } Else {
                        $AntivirusInfo = "Windows Defender desactualizado"
                        $HtmlAntivirus = @"
<tr>
  <td class="bold size">$Computer</td>
  <td class="size">$AntivirusInfo</td>
</tr>
"@
                    }
                }
            }
            Set-PrintMessage -Module Antivirus -Process StatusOK
        } Else {
            $AntivirusInfo = "Sin acceso al servidor"
            $HtmlAntivirus = @"
<tr>
  <td class="bold size">$Computer</td>
  <td class="size">$AntivirusInfo</td>
</tr>
"@
            Set-PrintMessage -Module Antivirus -Process Error
        }
    Add-Content -Path $ChecklistFile -Value $HtmlAntivirus
    }
    $HtmlAntivirusClose = @"
</table>
<p> Última definición: $LastDefinition</p>
</section>
</div>
"@
    Add-Content -Path $ChecklistFile -Value $HtmlAntivirusClose
}

####################################################################################
######### Información de Windows Updates (cantidad, reinicios pendientes) ##########
####################################################################################

If ($CheckBoxUpdates.Checked -eq $true) {
    #Orientacion columna    
    If ($CheckBoxAntivirus.Checked -eq $true) {
        $HtmlUpdatesHeader =@"
<div class="second column">
<section class="list">
<h2 class="barra">Updates pendientes y/o disponibles</h2>
<table>
<tr>
  <th class="veinte">Servidor</th>
  <th>Reinicio necesario</th>
  <th>Total de updates</th>
</tr>
"@
    } Else {
        $HtmlUpdatesHeader =@"
<div class="column">
<section class="list">
<h2 class="barra">Updates pendientes y/o disponibles</h2>
<table>
<tr>
  <th class="veinte">Servidor</th>
  <th>Reinicio necesario</th>
  <th>Total de updates</th>
</tr>
"@
    }
    Add-Content -Path $ChecklistFile -Value $HtmlUpdatesHeader
    #Recoleccion de Info
    Set-PrintMessage -Module Updates -Process Start
    Foreach ($Computer in $Computers) {
        If (Test-Connection -ComputerName $Computer -Count 1 -Quiet) {
            $WMI_OS = Get-WmiObject -Class Win32_OperatingSystem -Property BuildNumber -ComputerName $Computer
            $RegCon = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]"LocalMachine",$Computer)
            If ($WMI_OS.BuildNumber -ge 6001) {
                $RegSubKeysCBS = $RegCon.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\").GetSubKeyNames()
                $CBSRebootPend = $RegSubKeysCBS -contains "RebootPending"
            } Else{
                $CBSRebootPend = $false
            }
            $RegSubKeysWUAU = $RegCon.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\").GetSubKeyNames()
            $WUAURebootReq = $RegSubKeysWUAU -contains "RebootRequired"
            If($CBSRebootPend –OR $WUAURebootReq) {
                $machineNeedsRestart = "Se necesita reiniciar"
            } Else {
                $machineNeedsRestart = "No es necesario reiniciar"
            }
            $RegCon.Close()
            #Comprueba si es equipo local o remoto para crear la Session
            If($Computer -eq "$env:computername") {
                $UpdateSession = New-Object -ComObject Microsoft.Update.Session
            } Else {
                $UpdateSession = [activator]::CreateInstance([type]::GetTypeFromProgID("Microsoft.Update.Session",$Computer))
            }
            $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
			$SearchResult = $UpdateSearcher.Search("IsInstalled=0")
            #Si no hay updates, despliega el mensaje correspondiente
			If ($SearchResult.updates.count -eq 0) {
                $UpdatesTotales = "No hay updates pendientes"
            } Else {
                $UpdatesTotales = $($SearchResult.updates.count)
            }
            Set-PrintMessage -Module Updates -Process StatusOK
        } Else {
            $machineNeedsRestart = "Sin información"
            $UpdatesTotales = "Sin Información"
            Set-PrintMessage -Module Updates -Process Error
        }
        $HtmlUpdates = @"
<tr>
    <td class="bold size">$Computer</td>
    <td class="size">$machineNeedsRestart</td>
    <td class="size">$UpdatesTotales</td>
</tr>
"@
        Add-Content -Path $ChecklistFile -Value $HtmlUpdates
    }
    $HtmlUpdatesClose = @"
</table>
</section>
</div>
"@
    Add-Content -Path $ChecklistFile -Value $HtmlUpdatesClose
}


####################################################################################

# Agregamos la parte final del reporte
$HtmlEnd = @"
</div>
</body>
</html>
"@
Add-Content -Path $ChecklistFile -Value $HtmlEnd

#Guardo el archivo sin el BOM
$ExtractBOM = Get-Content $ChecklistFile
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($False)
[System.IO.File]::WriteAllLines($ChecklistFile, $ExtractBOM, $Utf8NoBomEncoding)

Set-PrintMessage -Process End
$LabelStatus.Text = "Finalizado"
}

#region Formulario
Add-Type -AssemblyName System.Windows.Forms
$Form = New-Object System.Windows.Forms.Form
$Form.Size = New-Object Drawing.Size(600,350)
$Form.StartPosition = "CenterScreen"
$Form.Text = "Auto Checklist"

#Caja de grupo - Ejecutando
$GroupBoxRun = New-Object System.Windows.Forms.GroupBox
$GroupBoxRun.Location = New-Object System.Drawing.Size(0,0)
$GroupBoxRun.Size = New-Object Drawing.Size(600,350)

#Caja de grupo - Modulo(s)
$GroupBoxModules = New-Object System.Windows.Forms.GroupBox
$GroupBoxModules.Location = New-Object System.Drawing.Size(20,20) 
$GroupBoxModules.Size = New-Object System.Drawing.Size(540,200) 
$GroupBoxModules.Text = "Modulo(s):"

#region Checkboxs
$CheckBoxSystem = New-Object System.Windows.Forms.CheckBox
$CheckBoxSystem.Location = New-Object System.Drawing.Size(20,25)
$CheckBoxSystem.Size = New-Object System.Drawing.Size(200,25)
$CheckBoxSystem.Text = "Informacion del sistema"

$CheckBoxAntivirus = New-Object System.Windows.Forms.CheckBox
$CheckBoxAntivirus.Location = New-Object System.Drawing.Size(20,50)
$CheckBoxAntivirus.Size = New-Object System.Drawing.Size(200,25)
$CheckBoxAntivirus.Text = "Informacion de Antivirus"

$CheckBoxUpdates = New-Object System.Windows.Forms.CheckBox
$CheckBoxUpdates.Location = New-Object System.Drawing.Size(20,75)
$CheckBoxUpdates.Size = New-Object System.Drawing.Size(200,25)
$CheckBoxUpdates.Text = "Estado de Updates"

#endregion

#Boton Ejecutar
$ButtonRun = New-Object System.Windows.Forms.Button
$ButtonRun.Add_Click({$LabelStatus.Text = "Ejecutando...";Get-AutoChecklist})
$ButtonRun.Location = New-Object System.Drawing.Size(50,260)
$ButtonRun.Text = "Ejecutar"

#Texto Estado
$LabelStatus = New-Object System.Windows.Forms.Label
$LabelStatus.Location = New-Object System.Drawing.Size(150,265)
$LabelStatus.Size = New-Object System.Drawing.Size(150,20)
$LabelStatus.Text = ""

#Boton Salir
$ButtonExit = New-Object System.Windows.Forms.Button
$ButtonExit.Add_Click({$Form.Close()})
$ButtonExit.Location = New-Object System.Drawing.Size(450,260)
$ButtonExit.Text = "Salir"

#Boton Abrir
$ButtonOpen = New-Object System.Windows.Forms.Button
$ButtonOpen.Add_Click({Invoke-Item ((Get-Location).Path + "\CheckList.html");$Form.Close()})
$ButtonOpen.Location = New-Object System.Drawing.Size(300,260)
$ButtonOpen.Text = "Abrir"

#Agrego elementos
$Form.Controls.Add($GroupBoxModules)
$GroupBoxModules.Controls.Add($CheckBoxSystem)
$GroupBoxModules.Controls.Add($CheckBoxAntivirus)
$GroupBoxModules.Controls.Add($CheckBoxUpdates)
$Form.Controls.Add($LabelStatus)
$Form.Controls.Add($ButtonRun)
$Form.Controls.Add($ButtonExit)
$Form.Controls.Add($ButtonOpen)
[void] $Form.ShowDialog()
#endregion
