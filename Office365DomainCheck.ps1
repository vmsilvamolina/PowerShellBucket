###############################################################################
#
#  Office365DomainCheck - Victor Silva - 3/2/15
#
###############################################################################

#Cargo las librerias de .Net
[void][System.Reflection.Assembly]::LoadWithPartialName( "System.Windows.Forms")
[void][System.Reflection.Assembly]::LoadWithPartialName( "System.Drawing")
#Habilito los estilos visuales
[Windows.Forms.Application]::EnableVisualStyles()
    
function DomainCheck { 
$URL = "https://login.windows.net/" + $TextBoxDominio.Text + ".onmicrosoft.com/FederationMetadata/2007-06/FederationMetadata.xml"
$Solicitud = $null

try {
    Measure-Command {$Solicitud = Invoke-WebRequest -Uri $URL}
} catch {
    $Solicitud = $_.Exception.Response 
}

$Status = $Solicitud.StatusCode
    If ($Status -eq 200) {
        $LabelDomain.Text = "Dominio utilizado, por favor seleccionar otro."
    } else {
        $LabelDomain.Text = "Dominio disponible para usar en Office 365"
    }
}

########### Formulario Principal ###########

$Form = New-Object System.Windows.Forms.Form
$Form.Size = New-Object Drawing.Size(400,300)
$Form.StartPosition = "CenterScreen"
$Form.Text = "Office 365 Domain Check"

$LabelInfo = New-Object System.Windows.Forms.Label
$LabelInfo.Location = New-Object System.Drawing.Size(40,60)
$LabelInfo.Size = New-Object System.Drawing.Size(65,23)
$LabelInfo.Font = New-Object System.Drawing.Font("Sans Serif",10,[System.Drawing.FontStyle]::Bold)
$LabelInfo.Text = "Dominio:"
$Form.Controls.Add($LabelInfo)

$TextBoxDominio = New-Object System.Windows.Forms.TextBox
$TextBoxDominio.Location = New-Object System.Drawing.Size(110,58)
$TextBoxDominio.Size = New-Object System.Drawing.Size(120,23)
$Form.Controls.Add($TextBoxDominio)

$LabelOn = New-Object System.Windows.Forms.Label
$LabelOn.Location = New-Object System.Drawing.Size(235,58)
$LabelOn.Size = New-Object System.Drawing.Size(130,23)
$LabelOn.Font = New-Object System.Drawing.Font("Sans Serif",10,[System.Drawing.FontStyle]::Bold)
$LabelOn.Text = ".onmicrosoft.com"
$Form.Controls.Add($LabelOn)

$ButtonApply = New-Object System.Windows.Forms.Button
$ButtonApply.Location = New-Object System.Drawing.Size(90,100)
$ButtonApply.Size = New-Object System.Drawing.Size(200,30)
$ButtonApply.Text = "Chequear disponibilidad del dominio"
$ButtonApply.Add_Click({
    DomainCheck
})
$Form.Controls.Add($ButtonApply)

$ButtonExit = New-Object System.Windows.Forms.Button
$ButtonExit.Location = New-Object System.Drawing.Size(280,220)
$ButtonExit.Text = "Salir"
$ButtonExit.Add_Click({
    $Form.Close()
})
$Form.Controls.Add($ButtonExit)

$LabelDomain = New-Object System.Windows.Forms.Label
$LabelDomain.Location = New-Object System.Drawing.Size(60,170)
$LabelDomain.Size = New-Object System.Drawing.Size(300,23)
$LabelDomain.Text = ""
$LabelDomain.Font = New-Object System.Drawing.Font("Sans Serif",10,[System.Drawing.FontStyle]::Bold)
$Form.Controls.Add($LabelDomain)

$Form.ShowDialog() | Out-Null
