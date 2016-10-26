## OpenVPN

#region Datos
$OpenVPN_GUI_file = "C:\Program Files\OpenVPN\bin\openvpn-gui.exe"
$OpenVPN_folder = "C:\Program Files\OpenVPN"
#endregion

cd $OpenVPN_folder
$folders = Get-ChildItem -Directory -Filter 'config*'

#region Form
#Cargo los Assemblies (necesario para definir el form)
[void][reflection.assembly]::loadwithpartialname("System.Windows.Forms")
[void][reflection.assembly]::loadwithpartialname("System.Drawing")
#Creo el objeto Form
$Form = New-Object System.Windows.Forms.Form
#Defino el tamaño del formulario
$Form.Size = New-Object Drawing.Size(400,200)
#Defino la posición inicial
$Form.StartPosition = "CenterScreen"
#Defino el titulo del formulario
$Form.Text = "OpenVPN - MultiCliente"
 
#Defino el botón
$Button = New-Object System.Windows.Forms.Button
$Button.Location = New-Object System.Drawing.Size(150,100)
$Button.Text = "Salir"
$Button.Add_Click({$Form.Close()})
$Form.Controls.Add($Button)

#Defino la etiqueta clientes
$Label = New-Object System.Windows.Forms.Label
$Label.Location = New-Object System.Drawing.Size(50,52)
$Label.Size = New-Object System.Drawing.Size(50,23)
$Label.Text = "Clientes"
$Form.Controls.Add($Label)

#Defino lista de clientes
$List = New-Object System.Windows.Forms.ComboBox
foreach ($folder in $folders) {
    if ($folder.name -ge 'config-') {
        $List.Items.Add($folder.Name.Split("-")[1]) | Out-Null
    } else {
        $List.Items.Add('Default') | Out-Null
    }
}
$List.Location = New-Object System.Drawing.Size(120,50)
$Form.Controls.Add($List)

#Ejecuto el formulario
[void]$Form.ShowDialog()
#endregion