#######
# Autor: Victor Silva
# Web: http//:blog.victorsilva.com.uy
#
#######
# Junio 7, 2016 - Primera versión.
#
#######

cls
#region Conexión a Outlook
$olFolderInbox = 6
$outlook = new-object -com outlook.application;
$mapi = $outlook.GetNameSpace("MAPI");
$inbox = $mapi.GetDefaultFolder($olFolderInbox)
#endregion

#region Funciones
function AddTextToImage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][String] $sourcePath,
        [Parameter(Mandatory=$true)][String] $destPath,
        [Parameter(Mandatory=$true)][String] $BirthdayName,
        [Parameter(Mandatory=$true)][String] $PhoneExt
    )
 
    [Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null

    $srcImg = [System.Drawing.Image]::FromFile($sourcePath)
    $bmpFile = new-object System.Drawing.Bitmap([int]($srcImg.width)),([int]($srcImg.height))
    $Image = [System.Drawing.Graphics]::FromImage($bmpFile)
    $Image.SmoothingMode = "AntiAlias"
    $Rectangle = New-Object Drawing.Rectangle 0, 0, $srcImg.Width, $srcImg.Height
    $Image.DrawImage($srcImg, $Rectangle, 0, 0, $srcImg.Width, $srcImg.Height, ([Drawing.GraphicsUnit]::Pixel))
    $Font = new-object System.Drawing.Font("Calibri", 18)
    $Brush = New-Object Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 0, 0,0))
    $Image.DrawString($BirthdayName, $Font, $Brush, 380, 198)
    $Font = New-object System.Drawing.Font("Calibri", 16)
    $Brush = New-Object Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 0, 0, 0))
    $Image.DrawString($PhoneExt, $Font, $Brush, 370, 350)
    $bmpFile.save($destPath, [System.Drawing.Imaging.ImageFormat]::Bmp)
    $bmpFile.Dispose()
    $srcImg.Dispose()

    #Invoke-Item $destPath
} # function AddTextToImage

function Send-MailMessage {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true)][Alias('PsPath')][ValidateNotNullOrEmpty()][string[]]${Attachments},
        [ValidateNotNullOrEmpty()][Collections.HashTable]${InlineAttachments},
        [ValidateNotNullOrEmpty()][Net.Mail.MailAddress[]]${Bcc},
        [Parameter(Position=2)][ValidateNotNullOrEmpty()][string]${Body},
        [Alias('BAH')][switch]${BodyAsHtml},
        [ValidateNotNullOrEmpty()][Net.Mail.MailAddress[]]${Cc},
        [Alias('DNO')][ValidateNotNullOrEmpty()][Net.Mail.DeliveryNotificationOptions]${DeliveryNotificationOption},
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][Net.Mail.MailAddress]${From},
        [Parameter(Mandatory = $true, Position = 3)][Alias('ComputerName')][string]${SmtpServer},
        [ValidateNotNullOrEmpty()][Net.Mail.MailPriority]${Priority},
        [Parameter(Mandatory=$true, Position=1)][Alias('sub')][ValidateNotNullOrEmpty()][string]${Subject},
        [Parameter(Mandatory=$true, Position=0)][Net.Mail.MailAddress[]]${To},
        [ValidateNotNullOrEmpty()][Management.Automation.PSCredential]${Credential},
        [switch]${UseSsl},
        [ValidateRange(0, 2147483647)][int]${Port} = 25
    )
    
    begin {
        function FileNameToContentType {
            [CmdletBinding()]
            param (
                [Parameter(Mandatory = $true)]
                [string]
                $FileName
            )

            $mimeMappings = @{
                '.jpeg' = 'image/jpeg'
                '.jpg' = 'image/jpeg'
                '.png' = 'image/png'
            }
            $extension = [System.IO.Path]::GetExtension($FileName)
            $contentType = $mimeMappings[$extension]
            if ([string]::IsNullOrEmpty($contentType)) {
                return New-Object System.Net.Mime.ContentType
            } else {
                return New-Object System.Net.Mime.ContentType($contentType)
            }
        }

        try {
            $_smtpClient = New-Object Net.Mail.SmtpClient
            $_smtpClient.Host = $SmtpServer
            $_smtpClient.Port = $Port
            $_smtpClient.EnableSsl = $UseSsl
            if ($null -ne $Credential) {
                $_tempCred = $Credential.GetNetworkCredential()
                $_smtpClient.Credentials = New-Object Net.NetworkCredential($Credential.UserName, $_tempCred.Password)
            } else {
                $_smtpClient.UseDefaultCredentials = $true
            }
            $_message = New-Object Net.Mail.MailMessage
            $_message.From = $From
            $_message.Subject = $Subject
            if ($BodyAsHtml) {
                $_bodyPart = [Net.Mail.AlternateView]::CreateAlternateViewFromString($Body, 'text/html')
            } else {
                $_bodyPart = [Net.Mail.AlternateView]::CreateAlternateViewFromString($Body, 'text/plain')
            }   
            $_message.AlternateViews.Add($_bodyPart)
            if ($PSBoundParameters.ContainsKey('DeliveryNotificationOption')) { $_message.DeliveryNotificationOptions = $DeliveryNotificationOption }
            if ($PSBoundParameters.ContainsKey('Priority')) { $_message.Priority = $Priority }
            foreach ($_address in $To) {
                if (-not $_message.To.Contains($_address)) { $_message.To.Add($_address) }
            }
            if ($null -ne $Cc) {
                foreach ($_address in $Cc) {
                    if (-not $_message.CC.Contains($_address)) { $_message.CC.Add($_address) }
                }
            }
            if ($null -ne $Bcc) {
                foreach ($_address in $Bcc) {
                    if (-not $_message.Bcc.Contains($_address)) { $_message.Bcc.Add($_address) }
                }
            }
        } catch {
            $_message.Dispose()
            throw
        }
        if ($PSBoundParameters.ContainsKey('InlineAttachments')) {
            foreach ($_entry in $InlineAttachments.GetEnumerator()) {
                $_file = $_entry.Value.ToString()
                if ([string]::IsNullOrEmpty($_file)) {
                    $_message.Dispose()
                    throw "Send-MailMessage: Values in the InlineAttachments table cannot be null."
                }

                try {
                    $_contentType = FileNameToContentType -FileName $_file
                    $_attachment = New-Object Net.Mail.LinkedResource($_file, $_contentType)
                    $_attachment.ContentId = $_entry.Key

                    $_bodyPart.LinkedResources.Add($_attachment)
                } catch {
                    $_message.Dispose()
                    throw
                }
            }
        }
    } process {
        if ($null -ne $Attachments) {
            foreach ($_file in $Attachments) {
                try {
                    $_contentType = FileNameToContentType -FileName $_file
                    $_message.Attachments.Add((New-Object Net.Mail.Attachment($_file, $_contentType)))
                } catch {
                    $_message.Dispose()
                    throw
                }
            }
        }
    } end {
        try {
            $_smtpClient.Send($_message)
        } catch {
            throw
        } finally {
            $_message.Dispose()
        }
    }

} # function Send-MailMessage
#endregion

#region Proceso
Foreach ($user in Get-ADUser -Properties fechaDeNacimiento,telephoneNumber -Filter *) {
    if ($user.fechaDeNacimiento -ne $null) {
        $fechaDeNacimiento = ([string]$user.fechaDeNacimiento).split(" ")[0]
        [string]$fecha = Get-Date -Format dd/MM
        $cumpleaños = $fechaDeNacimiento.Split("/")[1] + "/" + $fechaDeNacimiento.Split("/")[0]
        If ($cumpleaños -eq $fecha) {
            Write-host "Hoy es tu cumpleaños" $user.Name ", interno:" $user.telephoneNumber
            $images = @{ 
                image1 = 'C:\Users\Victor\OneDrive\Documentos\Clientes\Jetmar\FelizCumple\HoyHombre_MODIFICADO.png'
            }
            $body = @' 
<html>  
  <body>  
    <img src="cid:image1"><br> 
  </body>  
</html>  
'@    
            $params = @{ 
                InlineAttachments = $images 
                Body = $body 
                BodyAsHtml = $true 
                Subject = 'Test email' 
                From = 'vsilva@at.com.uy'
                To = 'vsilva@at.com.uy' 
                SmtpServer = 'smtp.office365.com' 
                Port = 587
                Credential = (Get-Credential) 
                UseSsl = $true 
            } 

AddTextToImage -sourcePath C:\Users\Victor\OneDrive\Documentos\Clientes\Jetmar\FelizCumple\HoyHombre.png -destPath C:\Users\Victor\OneDrive\Documentos\Clientes\Jetmar\FelizCumple\HoyHombre_MODIFICADO.png -BirthdayName "Martín Gonzalez" -PhoneExt "1318 / 099786513"
Send-MailMessage @params

        }
    }
}
#endregion

<#
Get-Process | where { $_.Name -like "Outlook" }| kill

$dia = "MARTES"
$ExchangeServer = "ex2013.jetmar2003.local"
$BodyMail = "<h2>TEST</h2>"
Send-MailMessage -From "Interno <internosoporte@jetmar.com.uy>" -Bcc "vsilva@t.com.uy" -Subject "HOY $dia, ES EL CUMPLEAÑOS DE..." -BodyAsHtml $BodyMail -SmtpServer $ExchangeServer
#>
