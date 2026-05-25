$ErrorActionPreference = 'Stop'

Set-StrictMode -Version Latest
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.Drawing

$root = 'c:\Users\user\OneDrive\digidanWork\Mailers\2026\ZAS26088113 - 2026_SSA Retainer_Digital_CRM MX _ S26 Series Onboarding _ Mailers _ W19'
$publishedDir = Join-Path $root 'published'
$doneDir = Join-Path $root 'done'
$imagesDir = Join-Path $root 'S26 Series Onboarding_Export images'
$footersDir = 'c:\Users\user\OneDrive\digidanWork\Mailers\footers'
$allImagesDir = Join-Path $publishedDir 'ALL_IMAGES'
$buildAssetsDir = Join-Path $root 'build_assets'

if (-not (Test-Path -LiteralPath $buildAssetsDir)) {
    New-Item -ItemType Directory -Path $buildAssetsDir | Out-Null
}

function Get-NormalizedFooter {
    param(
        [string] $FooterFile
    )

    $footerPath = Join-Path $footersDir $FooterFile
    $footer = Get-Content -LiteralPath $footerPath -Raw -Encoding UTF8
    $footer = [regex]::Replace($footer, 'href="https://samsung-mena-mkt-prod6-m\.adobe-campaign\.com/webApp/smgUnsub[^\"]*"', 'href="YYYYY"')
    $footer = $footer.Replace([string][char]0x00A9, '&copy;')
    return $footer
}

function Copy-AssetMap {
    param(
        [hashtable] $AssetMap,
        [string] $DestinationFolder
    )

    foreach ($targetName in $AssetMap.Keys) {
        $sourcePath = $AssetMap[$targetName]
        Copy-Item -LiteralPath $sourcePath -Destination (Join-Path $DestinationFolder $targetName) -Force
    }
}

function New-CroppedPng {
    param(
        [string] $SourcePath,
        [string] $DestinationPath,
        [int] $X,
        [int] $Y,
        [int] $Width,
        [int] $Height
    )

    if (Test-Path -LiteralPath $DestinationPath) {
        Remove-Item -LiteralPath $DestinationPath -Force
    }

    $sourceImage = [System.Drawing.Bitmap]::new($SourcePath)
    try {
        $cropRect = [System.Drawing.Rectangle]::new($X, $Y, $Width, $Height)
        $croppedImage = New-Object System.Drawing.Bitmap $Width, $Height
        try {
            $graphics = [System.Drawing.Graphics]::FromImage($croppedImage)
            try {
                $graphics.DrawImage($sourceImage, [System.Drawing.Rectangle]::new(0, 0, $Width, $Height), $cropRect, [System.Drawing.GraphicsUnit]::Pixel)
            }
            finally {
                $graphics.Dispose()
            }

            $croppedImage.Save($DestinationPath, [System.Drawing.Imaging.ImageFormat]::Png)
        }
        finally {
            $croppedImage.Dispose()
        }
    }
    finally {
        $sourceImage.Dispose()
    }
}

function New-MailerDocument {
    param(
        [string] $Title,
        [string] $Preheader,
        [string] $Body,
        [string] $Footer
    )

@"
<!DOCTYPE html>
<html>
    <head><meta http-equiv="content-type" content="text/html; charset=utf-8"><meta name="viewport" content="width=600"><meta name="format-detection" content="telephone=no">
        <title>$Title</title>
    </head>
    <body style="background-color:#555555; margin:0; padding:0;"><span class="preheader" style="color: transparent; display: none; height: 0; max-height: 0; max-width: 0; opacity: 0; overflow: hidden; mso-hide: all; visibility: hidden; width: 0;"> $Preheader </span>
        <table border="0" cellpadding="0" cellspacing="0" id="bodyTable" style="height:100%;" width="100%">
            <tbody>
                <tr>
                    <td align="center" valign="top">
                        <table border="0" cellpadding="0" cellspacing="0" width="100%">
                            <tbody>
                                <tr>
                                    <td align="center" valign="top" width="10"></td>
                                    <td style="font-family: arial, sans-serif; font-size: 14px; line-height: 18px; color: rgb(0, 0, 0); text-align: center;" valign="top" width="500"><br>
                                        <span style="color:#000000;">ZZZZZ</span><br>
                                        &nbsp; &nbsp; &nbsp;&nbsp;</td>
                                    <td align="center" valign="top" width="10"></td>
                                </tr>
                                <tr>
                                    <td align="center" valign="top" width="10"></td>
                                    <td style="font-family: arial, sans-serif; font-size: 14px; line-height: 18px; color: rgb(0, 0, 0); text-align: center;" valign="top" width="500"></td>
                                    <td align="center" valign="top" width="10"></td>
                                </tr>
                            </tbody>
                        </table>
$Body
$Footer
                    </td>
                </tr>
            </tbody>
        </table>
    </body>
</html>
"@
}

function Get-LogoHeader {
    param(
        [string] $HomeUrl,
        [string] $LogoSrc
    )

@"
                        <table border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff; width:600px;" width="600">
                            <tbody>
                                <tr>
                                    <td style="padding:28px 0 18px 42px;"><a href="$HomeUrl" target="_blank"><img alt="Samsung" border="0" height="25" src="$LogoSrc" style="display:block; width:160px; height:25px;" width="160"></a></td>
                                </tr>
                            </tbody>
                        </table>
"@
}

function Get-LiveTipLabelRow {
    param(
        [string] $Label
    )

@"
                                <tr>
                                    <td style="text-align:center;"><u><span style="font-size:20px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;"><span style="color:#276DDC;"><strong>$Label</strong></span></span></span></u></td>
                                </tr>
"@
}

function Get-ImageTipLabelRow {
    param(
        [string] $ImageSrc,
        [string] $Alt,
        [int] $Width,
        [int] $Height
    )

@"
                                <tr>
                                    <td style="text-align:center;"><img alt="$Alt" border="0" height="$Height" src="$ImageSrc" style="width:${Width}px; height:${Height}px; display:block; margin:auto;" width="$Width"></td>
                                </tr>
"@
}

function Get-Mailer4Tip4Rows {
    param(
        [string] $TopImage,
        [string] $TopImageAlt,
        [string] $TopText,
        [string] $BottomImage,
        [string] $BottomImageAlt,
        [string] $BottomText
    )

@"
                                <tr>
                                    <td align="center" style="padding:0 40px;">
                                        <table align="center" border="0" cellpadding="0" cellspacing="0" width="520">
                                            <tbody>
                                                <tr>
                                                    <td valign="middle" width="249"><img alt="$TopImageAlt" border="0" height="336" src="$TopImage" style="width:249px; height:336px; display:block;" width="249"></td>
                                                    <td width="22">&nbsp;</td>
                                                    <td style="text-align:left;" valign="middle" width="249"><span style="font-size:18px; line-height:28px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">$TopText</span></span></td>
                                                </tr>
                                                <tr>
                                                    <td colspan="3" height="18" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                                </tr>
                                                <tr>
                                                    <td style="text-align:left;" valign="middle" width="249"><span style="font-size:18px; line-height:28px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">$BottomText</span></span></td>
                                                    <td width="22">&nbsp;</td>
                                                    <td valign="middle" width="249"><img alt="$BottomImageAlt" border="0" height="336" src="$BottomImage" style="width:249px; height:336px; display:block;" width="249"></td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
"@
}

function Get-Mailer3WatchPair {
    param(
        [string] $LandingUrl,
        [string] $LeftImage,
        [string] $RightImage,
        [string] $ButtonImage,
        [string] $ButtonAlt
    )

@"
                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background:#ffffff;" width="600">
                            <tbody>
                                <tr>
                                    <td height="10" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td align="center" style="padding:0 40px;">
                                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#F4F4F4; border-radius:12px;" width="520">
                                            <tbody>
                                                <tr>
                                                    <td align="center" style="padding:24px 20px 10px 20px;" valign="middle" width="250"><a href="$LandingUrl" target="_blank"><img alt="Galaxy Watch" border="0" height="180" src="$LeftImage" style="display:block; width:119px; height:180px; margin:auto;" width="119"></a></td>
                                                    <td align="center" style="padding:24px 20px 10px 20px;" valign="middle" width="250"><a href="$LandingUrl" target="_blank"><img alt="Galaxy Watch8 Classic" border="0" height="180" src="$RightImage" style="display:block; width:112px; height:180px; margin:auto;" width="112"></a></td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="16" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center;"><span style="font-size:22px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Galaxy Watch | Watch8 Classic</span></strong></span></td>
                                </tr>
                                <tr>
                                    <td height="16" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center;"><a href="$LandingUrl" target="_blank"><img alt="$ButtonAlt" border="0" height="50" src="$ButtonImage" style="width:184px; height:50px; display:block; margin:auto;" width="184"></a></td>
                                </tr>
                                <tr>
                                    <td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                            </tbody>
                        </table>
"@
}

function Get-Mailer3ProductCards {
    param(
        [string] $LandingUrl,
        [string] $LeftImage,
        [string] $LeftTitle,
        [string] $RightImage,
        [string] $RightTitle,
        [string] $ButtonImage,
        [string] $ButtonAlt
    )

@"
                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff;" width="600">
                            <tbody>
                                <tr>
                                    <td height="10" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td align="center" style="padding:0 30px;">
                                        <table align="center" border="0" cellpadding="0" cellspacing="0" width="540">
                                            <tbody>
                                                <tr valign="top">
                                                    <td bgcolor="#F4F4F4" style="background-color:#F4F4F4; width:265px; text-align:center; padding:25px 15px;" width="265">
                                                        <a href="$LandingUrl" target="_blank"><img alt="$LeftTitle" border="0" height="150" src="$LeftImage" style="display:block; margin:auto; width:auto; height:150px;" width="150"></a><br>
                                                        <span style="font-size:18px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">$LeftTitle</span></strong></span><br><br>
                                                        <a href="$LandingUrl" target="_blank"><img alt="$ButtonAlt" border="0" height="50" src="$ButtonImage" style="display:block; margin:auto; width:184px; height:50px;" width="184"></a>
                                                    </td>
                                                    <td style="width:10px; font-size:1px; line-height:1px;" width="10">&nbsp;</td>
                                                    <td bgcolor="#F4F4F4" style="background-color:#F4F4F4; width:265px; text-align:center; padding:25px 15px;" width="265">
                                                        <a href="$LandingUrl" target="_blank"><img alt="$RightTitle" border="0" height="150" src="$RightImage" style="display:block; margin:auto; width:auto; height:150px;" width="150"></a><br>
                                                        <span style="font-size:18px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">$RightTitle</span></strong></span><br><br>
                                                        <a href="$LandingUrl" target="_blank"><img alt="$ButtonAlt" border="0" height="50" src="$ButtonImage" style="display:block; margin:auto; width:184px; height:50px;" width="184"></a>
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                            </tbody>
                        </table>
"@
}

function Get-InfoCard {
    param(
        [string] $IconSrc,
        [string] $IconAlt,
        [string] $Headline,
        [string] $Body,
        [string] $ButtonSrc,
        [string] $ButtonAlt,
        [string] $ButtonUrl
    )

@"
                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background:#ffffff;" width="600">
                            <tbody>
                                <tr>
                                    <td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td align="center" style="padding:0 30px;">
                                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="border:1px solid #B9B9B9; border-radius:14px;" width="540">
                                            <tbody>
                                                <tr>
                                                    <td height="28" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                                </tr>
                                                <tr>
                                                    <td style="text-align:center;"><img alt="$IconAlt" border="0" height="72" src="$IconSrc" style="width:71px; height:72px; display:block; margin:auto;" width="71"></td>
                                                </tr>
                                                <tr>
                                                    <td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                                </tr>
                                                <tr>
                                                    <td style="text-align:center; padding:0 40px;"><span style="font-size:20px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">$Headline</span></strong></span></td>
                                                </tr>
                                                <tr>
                                                    <td height="12" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                                </tr>
                                                <tr>
                                                    <td style="text-align:center; padding:0 40px;"><span style="font-size:18px; line-height:28px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">$Body</span></span></td>
                                                </tr>
                                                <tr>
                                                    <td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                                </tr>
                                                <tr>
                                                    <td style="text-align:center;"><a href="$ButtonUrl" target="_blank"><img alt="$ButtonAlt" border="0" height="50" src="$ButtonSrc" style="display:block; margin:auto; width:auto; height:50px;" width="184"></a></td>
                                                </tr>
                                                <tr>
                                                    <td height="28" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                            </tbody>
                        </table>
"@
}

function Get-ReviewCard {
    param(
        [string] $IconSrc,
        [string] $Headline,
        [string] $ButtonSrc,
        [string] $ButtonAlt,
        [string] $ButtonUrl
    )

@"
                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background:#ffffff;" width="600">
                            <tbody>
                                <tr>
                                    <td align="center" style="padding:0 30px;">
                                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#F4F4F4; border-radius:14px;" width="540">
                                            <tbody>
                                                <tr>
                                                    <td height="28" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                                </tr>
                                                <tr>
                                                    <td style="text-align:center;"><img alt="Review icon" border="0" height="44" src="$IconSrc" style="width:44px; height:44px; display:block; margin:auto;" width="44"></td>
                                                </tr>
                                                <tr>
                                                    <td height="12" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                                </tr>
                                                <tr>
                                                    <td style="text-align:center; padding:0 40px;"><span style="font-size:20px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">$Headline</span></strong></span></td>
                                                </tr>
                                                <tr>
                                                    <td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                                </tr>
                                                <tr>
                                                    <td style="text-align:center;"><a href="$ButtonUrl" target="_blank"><img alt="$ButtonAlt" border="0" height="50" src="$ButtonSrc" style="display:block; margin:auto; width:auto; height:50px;" width="204"></a></td>
                                                </tr>
                                                <tr>
                                                    <td height="28" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                            </tbody>
                        </table>
"@
}

function Get-QrRow {
    param(
        [string] $QrImage,
        [string] $Title,
        [string] $LinkText,
        [string] $Url
    )

@"
                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#EEF2F8;" width="600">
                            <tbody>
                                <tr>
                                    <td align="center" style="padding:0 30px;">
                                        <table align="center" border="0" cellpadding="0" cellspacing="0" width="540">
                                            <tbody>
                                                <tr>
                                                    <td style="padding:18px 0;" valign="middle" width="260"><a href="$Url" target="_blank"><img alt="Try Galaxy AI QR code" border="0" height="278" src="$QrImage" style="display:block; width:260px; height:278px;" width="260"></a></td>
                                                    <td style="padding:18px 0 18px 20px;" valign="middle" width="260"><span style="font-size:20px; line-height:30px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">$Title</span></strong></span><br><br><a href="$Url" style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:16px; color:#000000; text-decoration:none;" target="_blank">$LinkText</a></td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
"@
}

function New-ZipFromFolder {
    param(
        [string] $FolderPath,
        [string] $ZipPath
    )

    if (Test-Path -LiteralPath $ZipPath) {
        Remove-Item -LiteralPath $ZipPath -Force
    }

    $zip = [System.IO.Compression.ZipFile]::Open($ZipPath, [System.IO.Compression.ZipArchiveMode]::Create)
    try {
        foreach ($file in Get-ChildItem -LiteralPath $FolderPath -File | Where-Object { $_.Extension -ne '.zip' }) {
            [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $file.FullName, $file.Name) | Out-Null
        }
    }
    finally {
        $zip.Dispose()
    }
}

function Write-OutputPackage {
    param(
        [string] $Name,
        [string] $Html,
        [hashtable] $AssetMap
    )

    $folderPath = Join-Path $publishedDir $Name
    if (Test-Path -LiteralPath $folderPath) {
        Remove-Item -LiteralPath $folderPath -Recurse -Force
    }
    New-Item -ItemType Directory -Path $folderPath | Out-Null

    Copy-AssetMap -AssetMap $AssetMap -DestinationFolder $folderPath

    $htmlPath = Join-Path $folderPath ($Name + '.html')
    [System.IO.File]::WriteAllText($htmlPath, $Html, [System.Text.Encoding]::UTF8)
    New-ZipFromFolder -FolderPath $folderPath -ZipPath (Join-Path $folderPath ($Name + '.zip'))
}

function New-ServerBundle {
    param(
        [array] $PackageNames
    )

    if (Test-Path -LiteralPath $allImagesDir) {
        Remove-Item -LiteralPath $allImagesDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $allImagesDir | Out-Null

    $seen = @{}
    $rows = New-Object System.Collections.Generic.List[object]
    $counter = 1

    foreach ($packageName in $PackageNames) {
        $folderPath = Join-Path $publishedDir $packageName
        foreach ($file in Get-ChildItem -LiteralPath $folderPath -File | Where-Object { $_.Extension -notin @('.html', '.zip') }) {
            $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
            if (-not $seen.ContainsKey($hash)) {
                $uploadName = '{0:D3}_{1}' -f $counter, $file.Name
                Copy-Item -LiteralPath $file.FullName -Destination (Join-Path $allImagesDir $uploadName) -Force
                $row = [pscustomobject]@{
                    Number = $counter
                    UploadName = $uploadName
                    Originals = New-Object System.Collections.Generic.List[string]
                }
                $row.Originals.Add($file.Name)
                $seen[$hash] = $row
                $rows.Add($row)
                $counter++
            }
            else {
                $row = $seen[$hash]
                if (-not $row.Originals.Contains($file.Name)) {
                    $row.Originals.Add($file.Name)
                }
            }
        }
    }

    $rowHtml = foreach ($row in $rows) {
        $originals = ($row.Originals | Sort-Object) -join ' | '
@"
            <tr data-originals="$originals" data-upload="$($row.UploadName)">
                <td style="border:1px solid #cccccc; padding:10px; font-family:Arial, sans-serif; font-size:14px; text-align:center;">$($row.Number)</td>
                <td style="border:1px solid #cccccc; padding:10px; font-family:Arial, sans-serif; font-size:13px;"><strong>$($row.UploadName)</strong><br><br><img alt="$($row.UploadName)" src="$($row.UploadName)" style="max-width:240px; max-height:180px; display:block;"></td>
                <td style="border:1px solid #cccccc; padding:10px; font-family:Arial, sans-serif; font-size:13px;">$(($row.Originals | Sort-Object) -join '<br>')</td>
            </tr>
"@
    }

    $serverHtml = @"
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>W19 Africa Server Reference</title>
    </head>
    <body style="margin:0; padding:24px; background-color:#f4f4f4;">
        <table border="0" cellpadding="0" cellspacing="0" style="width:100%; max-width:1200px; margin:0 auto; background-color:#ffffff; border-collapse:collapse;">
            <tbody>
                <tr>
                    <td colspan="3" style="padding:20px; font-family:Arial, sans-serif; font-size:24px; font-weight:bold;">W19 Africa ALL_IMAGES Server Reference</td>
                </tr>
                <tr>
                    <td style="border:1px solid #cccccc; padding:10px; font-family:Arial, sans-serif; font-size:14px; font-weight:bold; width:80px; text-align:center;">#</td>
                    <td style="border:1px solid #cccccc; padding:10px; font-family:Arial, sans-serif; font-size:14px; font-weight:bold; width:340px;">Uploaded asset</td>
                    <td style="border:1px solid #cccccc; padding:10px; font-family:Arial, sans-serif; font-size:14px; font-weight:bold;">Original local filename(s)</td>
                </tr>
$($rowHtml -join "`r`n")
            </tbody>
        </table>
    </body>
</html>
"@

    [System.IO.File]::WriteAllText((Join-Path $allImagesDir 'server.html'), $serverHtml, [System.Text.Encoding]::UTF8)
}

$footerGh = Get-NormalizedFooter -FooterFile 'footer_gh.txt'
$footerNg = Get-NormalizedFooter -FooterFile 'footer_ng.txt'
$footerKe = Get-NormalizedFooter -FooterFile 'footer_ke.txt'
$footerTz = Get-NormalizedFooter -FooterFile 'footer_tz.txt'
$footerMu = Get-NormalizedFooter -FooterFile 'footer_mu.txt'
$footerSn = Get-NormalizedFooter -FooterFile 'footer_sn.txt'
$footerCi = Get-NormalizedFooter -FooterFile 'footer_ci.txt'

$landingEn = 'https://www.samsung.com/africa_en/offer/welcome-to-samsung-mobile/'
$landingFr = 'https://www.samsung.com/africa_fr/offer/welcome-to-samsung-mobile/'
$homeEn = 'https://www.samsung.com/africa_en/'
$homeFr = 'https://www.samsung.com/africa_fr/'
$tryGalaxy = 'https://trygalaxy.com/'

$sa3Assets = Join-Path $doneDir 'ZAS26088113  S26 Series Onboarding_Mailers_W19_SA 3'
$sa4Assets = Join-Path $doneDir 'ZAS26088113  S26 Series Onboarding_Mailers_W19_SA 4'
$sa5Assets = Join-Path $doneDir 'ZAS26088113  S26 Series Onboarding_Mailers_W19_SA 5'

$m3EnglishKvSource = Join-Path $buildAssetsDir 'm3e_kv.png'
New-CroppedPng -SourcePath (Join-Path $root 'ZAS26088113  S26 Series Onboarding_Mailers_W19_GH + NG 3.png') -DestinationPath $m3EnglishKvSource -X 0 -Y 0 -Width 600 -Height 1193

$assetMaps = @{
    m3e = @{
        'm3e_kv.png' = $m3EnglishKvSource
        'm3e_learn_more.png' = (Join-Path $imagesDir '3\Button\Group 2649.png')
        'm3e_explore_now.png' = (Join-Path $imagesDir '3\Button\Group 2654.png')
        'm3e_lightbulb.png' = (Join-Path $imagesDir '3\Image 662.png')
        'm3e_watch_hero.png' = (Join-Path $imagesDir '3\Image 666.png')
        'm3e_health_logo.png' = (Join-Path $imagesDir '3\Image 667.png')
        'm3e_watch_classic.png' = (Join-Path $sa3Assets 'Image_693_2x.png')
        'm3e_watch_standard.png' = (Join-Path $imagesDir '3\Group 2673.png')
        'm3e_buds_hero.png' = (Join-Path $imagesDir '3\Image 668.png')
        'm3e_buds_pro.png' = (Join-Path $imagesDir '3\Image 670.png')
        'm3e_buds_base.png' = (Join-Path $imagesDir '3\Image 671.png')
        'm3e_tab_hero.png' = (Join-Path $imagesDir '3\Image 669.png')
        'm3e_tab_ultra.png' = (Join-Path $imagesDir '3\Image 673.png')
        'm3e_tab_base.png' = (Join-Path $imagesDir '3\Image 674.png')
        'm3e_qr.png' = (Join-Path $imagesDir 'ROA\Image 513.png')
    }
    m3f = @{
        'm3f_hero.png' = (Join-Path $imagesDir 'French\3\Group 2702.png')
        'm3f_learn_more.png' = (Join-Path $imagesDir 'French\3\Group 2682.png')
        'm3f_leave_review.png' = (Join-Path $imagesDir 'French\3\Group 2654.png')
        'm3f_lightbulb.png' = (Join-Path $imagesDir '3\Image 662.png')
        'm3f_watch_hero.png' = (Join-Path $imagesDir '3\Image 666.png')
        'm3f_health_logo.png' = (Join-Path $imagesDir '3\Image 667.png')
        'm3f_watch_classic.png' = (Join-Path $sa3Assets 'Image_693_2x.png')
        'm3f_watch_standard.png' = (Join-Path $imagesDir '3\Group 2673.png')
        'm3f_buds_hero.png' = (Join-Path $imagesDir '3\Image 668.png')
        'm3f_buds_pro.png' = (Join-Path $imagesDir '3\Image 670.png')
        'm3f_buds_base.png' = (Join-Path $imagesDir '3\Image 671.png')
        'm3f_tab_hero.png' = (Join-Path $imagesDir '3\Image 669.png')
        'm3f_tab_ultra.png' = (Join-Path $imagesDir '3\Image 673.png')
        'm3f_tab_base.png' = (Join-Path $imagesDir '3\Image 674.png')
    }
    m4e = @{
        'm4e_logo.png' = (Join-Path $sa4Assets 'SamsungLogo_2x.png')
        'm4e_ai_logo.png' = (Join-Path $imagesDir '4\Image 654.png')
        'm4e_learn_more.png' = (Join-Path $imagesDir '4\Buttons\Group 2644.png')
        'm4e_explore_now.png' = (Join-Path $imagesDir '4\Buttons\Group 2654.png')
        'm4e_leave_review.png' = (Join-Path $imagesDir '4\Buttons\Group 2655.png')
        'm4e_lightbulb.png' = (Join-Path $imagesDir '4\Image 662.png')
        'm4e_review_icon.png' = (Join-Path $imagesDir '4\Image 663.png')
        'm4e_tip1.png' = (Join-Path $imagesDir '4\Image 675.png')
        'm4e_tip2.png' = (Join-Path $imagesDir '4\Image 676.png')
        'm4e_tip3.png' = (Join-Path $imagesDir '4\Image 677.png')
        'm4e_tip4_left.png' = (Join-Path $imagesDir '4\Image 678.png')
        'm4e_tip4_right.png' = (Join-Path $imagesDir '4\Image 679.png')
        'm4e_qr.png' = (Join-Path $imagesDir 'ROA\Image 513.png')
    }
    m4f = @{
        'm4f_logo.png' = (Join-Path $sa4Assets 'SamsungLogo_2x.png')
        'm4f_ai_logo.png' = (Join-Path $imagesDir '4\Image 654.png')
        'm4f_learn_more.png' = (Join-Path $imagesDir 'French\4\Group 2696.png')
        'm4f_explore_now.png' = (Join-Path $imagesDir 'French\4\Group 2654.png')
        'm4f_leave_review.png' = (Join-Path $imagesDir 'French\4\Group 2655.png')
        'm4f_badge_1.png' = (Join-Path $imagesDir 'French\4\Group 2681.png')
        'm4f_badge_2.png' = (Join-Path $imagesDir 'French\4\Group 2677.png')
        'm4f_badge_3.png' = (Join-Path $imagesDir 'French\4\Group -1.png')
        'm4f_badge_4.png' = (Join-Path $imagesDir 'French\4\Group 2695.png')
        'm4f_lightbulb.png' = (Join-Path $imagesDir '4\Image 662.png')
        'm4f_review_icon.png' = (Join-Path $imagesDir '4\Image 663.png')
        'm4f_tip1.png' = (Join-Path $imagesDir '4\Image 675.png')
        'm4f_tip2.png' = (Join-Path $imagesDir '4\Image 676.png')
        'm4f_tip3.png' = (Join-Path $imagesDir '4\Image 677.png')
        'm4f_tip4_left.png' = (Join-Path $imagesDir '4\Image 678.png')
        'm4f_tip4_right.png' = (Join-Path $imagesDir '4\Image 679.png')
    }
    m5e = @{
        'm5e_logo.png' = (Join-Path $sa5Assets 'SamsungLogo_2x.png')
        'm5e_hero.png' = (Join-Path $imagesDir '5\Group 2675.png')
        'm5e_learn_more.png' = (Join-Path $imagesDir '5\Buttons\Group 2666.png')
        'm5e_explore_now.png' = (Join-Path $imagesDir '5\Buttons\Group 2654.png')
        'm5e_health.png' = (Join-Path $imagesDir '5\Image 681.png')
        'm5e_health_logo.png' = (Join-Path $imagesDir '5\Image 667.png')
        'm5e_smartthings.png' = (Join-Path $imagesDir '5\Image 682.png')
        'm5e_care.png' = (Join-Path $imagesDir '5\Image 642.png')
        'm5e_care_logo.png' = (Join-Path $imagesDir '5\Image 683.png')
        'm5e_care_priority.png' = (Join-Path $imagesDir '5\Image 645.png')
        'm5e_care_certified.png' = (Join-Path $imagesDir '5\Image 646.png')
        'm5e_care_global.png' = (Join-Path $imagesDir '5\Image 647.png')
        'm5e_lightbulb.png' = (Join-Path $imagesDir '5\Image 662.png')
        'm5e_qr.png' = (Join-Path $imagesDir 'ROA\Image 513.png')
    }
    m5f = @{
        'm5f_hero.png' = (Join-Path $imagesDir 'French\5\Group 2703.png')
        'm5f_learn_more.png' = (Join-Path $imagesDir 'French\4\Group 2696.png')
        'm5f_explore_now.png' = (Join-Path $imagesDir 'French\4\Group 2654.png')
        'm5f_health.png' = (Join-Path $imagesDir '5\Image 681.png')
        'm5f_health_logo.png' = (Join-Path $imagesDir '5\Image 667.png')
        'm5f_smartthings.png' = (Join-Path $imagesDir '5\Image 682.png')
        'm5f_lightbulb.png' = (Join-Path $imagesDir '5\Image 662.png')
    }
}

function Get-Mailer3EnglishBody {
    param(
        [bool] $IncludeQr
    )

    $body = @"
                        <table border="0" cellpadding="0" cellspacing="0" class="mailcont" id="emailContainer" style="background-color:#ffffff; width:600px;" width="600">
                            <tbody>
                                <tr><td><a href="$landingEn" target="_blank"><img alt="Explore possibilities with your new Galaxy" border="0" height="1193" src="m3e_kv.png" style="display:block; width:600px; height:1193px;" width="600"></a></td></tr>
                            </tbody>
                        </table>

                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background:#ffffff;" width="600">
                            <tbody>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><span style="font-size:22px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Galaxy Watch8 Series</span></strong></span></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingEn" target="_blank"><img alt="Galaxy Watch8 Series" border="0" height="339" src="m3e_watch_hero.png" style="width:520px; height:339px; display:block; margin:auto;" width="520"></a></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><span style="font-size:32px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Feel ultra comfort,<br>from sleep to workout</span></strong></span></td></tr>
                                <tr><td height="18" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><img alt="Samsung Health" border="0" height="58" src="m3e_health_logo.png" style="width:338px; height:58px; display:block; margin:auto;" width="338"></td></tr>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingEn" target="_blank"><img alt="Learn more" border="0" height="50" src="m3e_learn_more.png" style="width:184px; height:50px; display:block; margin:auto;" width="184"></a></td></tr>
                                <tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                            </tbody>
                        </table>

$(Get-Mailer3WatchPair -LandingUrl $landingEn -LeftImage 'm3e_watch_classic.png' -RightImage 'm3e_watch_standard.png' -ButtonImage 'm3e_learn_more.png' -ButtonAlt 'Learn more')

                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background:#ffffff;" width="600">
                            <tbody>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><span style="font-size:22px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Galaxy Buds4 Series</span></strong></span></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingEn" target="_blank"><img alt="Galaxy Buds4 Series" border="0" height="339" src="m3e_buds_hero.png" style="width:520px; height:339px; display:block; margin:auto;" width="520"></a></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><span style="font-size:32px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Tailor Hi-Fi sound<br>your way</span></strong></span></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center; padding:0 40px;"><span style="font-size:18px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Galaxy Buds4 Pro creates a tailored sound with the 9-Band Equalizer and optimizes sound to your ear shape and wearing style.</span></span></td></tr>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingEn" target="_blank"><img alt="Learn more" border="0" height="50" src="m3e_learn_more.png" style="width:184px; height:50px; display:block; margin:auto;" width="184"></a></td></tr>
                                <tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                            </tbody>
                        </table>

$(Get-Mailer3ProductCards -LandingUrl $landingEn -LeftImage 'm3e_buds_pro.png' -LeftTitle 'Galaxy<br>Buds4 Pro' -RightImage 'm3e_buds_base.png' -RightTitle 'Galaxy<br>Buds4' -ButtonImage 'm3e_learn_more.png' -ButtonAlt 'Learn more')

                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background:#ffffff;" width="600">
                            <tbody>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><span style="font-size:22px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Galaxy Tab S11 Series</span></strong></span></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingEn" target="_blank"><img alt="Galaxy Tab S11 Series" border="0" height="340" src="m3e_tab_hero.png" style="width:520px; height:340px; display:block; margin:auto;" width="520"></a></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><span style="font-size:32px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Meet Galaxy AI<br>on the big screen</span></strong></span></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center; padding:0 40px;"><span style="font-size:18px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Transform simple drawings into stunning AI-generated images in seconds.</span></span></td></tr>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingEn" target="_blank"><img alt="Learn more" border="0" height="50" src="m3e_learn_more.png" style="width:184px; height:50px; display:block; margin:auto;" width="184"></a></td></tr>
                                <tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                            </tbody>
                        </table>

$(Get-Mailer3ProductCards -LandingUrl $landingEn -LeftImage 'm3e_tab_ultra.png' -LeftTitle 'Galaxy<br>Tab S11 ultra' -RightImage 'm3e_tab_base.png' -RightTitle 'Galaxy<br>Tab S11' -ButtonImage 'm3e_learn_more.png' -ButtonAlt 'Learn more')

$(Get-InfoCard -IconSrc 'm3e_lightbulb.png' -IconAlt 'Check what you may have missed' -Headline 'Check what you may have missed to unlock tips, benefits and more' -Body '' -ButtonSrc 'm3e_explore_now.png' -ButtonAlt 'Explore now' -ButtonUrl $landingEn)
"@

    if ($IncludeQr) {
        $body += "`r`n" + (Get-QrRow -QrImage 'm3e_qr.png' -Title 'Try Galaxy AI on your phone' -LinkText 'Learn more &gt;' -Url $tryGalaxy)
    }

    return $body
}

function Get-Mailer3FrenchBody {
    $body = @"
                        <table border="0" cellpadding="0" cellspacing="0" class="mailcont" id="emailContainer" style="background-color:#ffffff; width:600px;" width="600">
                            <tbody>
                                <tr><td><a href="$landingFr" target="_blank"><img alt="Explorez de nouvelles possibilit&eacute;s avec votre nouveau Galaxy" border="0" height="1193" src="m3f_hero.png" style="display:block; width:600px; height:1193px;" width="600"></a></td></tr>
                            </tbody>
                        </table>

                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background:#ffffff;" width="600">
                            <tbody>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><span style="font-size:22px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Galaxy Watch8 Series</span></strong></span></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingFr" target="_blank"><img alt="Galaxy Watch8 Series" border="0" height="339" src="m3f_watch_hero.png" style="width:520px; height:339px; display:block; margin:auto;" width="520"></a></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><span style="font-size:32px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Un confort absolu,<br>du sommeil &agrave; l'entra&icirc;nement</span></strong></span></td></tr>
                                <tr><td height="18" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><img alt="Samsung Health" border="0" height="58" src="m3f_health_logo.png" style="width:338px; height:58px; display:block; margin:auto;" width="338"></td></tr>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingFr" target="_blank"><img alt="En savoir plus" border="0" height="50" src="m3f_learn_more.png" style="width:184px; height:50px; display:block; margin:auto;" width="184"></a></td></tr>
                                <tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                            </tbody>
                        </table>

$(Get-Mailer3WatchPair -LandingUrl $landingFr -LeftImage 'm3f_watch_classic.png' -RightImage 'm3f_watch_standard.png' -ButtonImage 'm3f_learn_more.png' -ButtonAlt 'En savoir plus')

                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background:#ffffff;" width="600">
                            <tbody>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><span style="font-size:22px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Galaxy Buds4 Series</span></strong></span></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingFr" target="_blank"><img alt="Galaxy Buds4 Series" border="0" height="339" src="m3f_buds_hero.png" style="width:520px; height:339px; display:block; margin:auto;" width="520"></a></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><span style="font-size:32px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Un son Hi-Fi personnalis&eacute;<br>selon vos pr&eacute;f&eacute;rences</span></strong></span></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center; padding:0 40px;"><span style="font-size:18px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Les Galaxy Buds4 Pro offrent un son personnalis&eacute; gr&acirc;ce &agrave; un &eacute;galiseur 9 bandes et optimisent l'audio selon la forme de vos oreilles et votre mani&egrave;re de les porter.</span></span></td></tr>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingFr" target="_blank"><img alt="En savoir plus" border="0" height="50" src="m3f_learn_more.png" style="width:184px; height:50px; display:block; margin:auto;" width="184"></a></td></tr>
                                <tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                            </tbody>
                        </table>

$(Get-Mailer3ProductCards -LandingUrl $landingFr -LeftImage 'm3f_buds_pro.png' -LeftTitle 'Galaxy<br>Buds4 Pro' -RightImage 'm3f_buds_base.png' -RightTitle 'Galaxy<br>Buds4' -ButtonImage 'm3f_learn_more.png' -ButtonAlt 'En savoir plus')

                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background:#ffffff;" width="600">
                            <tbody>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><span style="font-size:22px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Galaxy Tab S11 Series</span></strong></span></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingFr" target="_blank"><img alt="Galaxy Tab S11 Series" border="0" height="340" src="m3f_tab_hero.png" style="width:520px; height:340px; display:block; margin:auto;" width="520"></a></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><span style="font-size:32px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">D&eacute;couvrez Galaxy AI<br>sur grand &eacute;cran</span></strong></span></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center; padding:0 40px;"><span style="font-size:18px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Transformez de simples dessins en images impressionnantes g&eacute;n&eacute;r&eacute;es par l'IA en quelques secondes.</span></span></td></tr>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingFr" target="_blank"><img alt="En savoir plus" border="0" height="50" src="m3f_learn_more.png" style="width:184px; height:50px; display:block; margin:auto;" width="184"></a></td></tr>
                                <tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                            </tbody>
                        </table>

$(Get-Mailer3ProductCards -LandingUrl $landingFr -LeftImage 'm3f_tab_ultra.png' -LeftTitle 'Galaxy<br>Tab S11 ultra' -RightImage 'm3f_tab_base.png' -RightTitle 'Galaxy<br>Tab S11' -ButtonImage 'm3f_learn_more.png' -ButtonAlt 'En savoir plus')

$(Get-InfoCard -IconSrc 'm3f_lightbulb.png' -IconAlt 'D&eacute;couvrez ce que vous avez peut-&ecirc;tre manqu&eacute;' -Headline 'D&eacute;couvrez ce que vous avez peut-&ecirc;tre manqu&eacute; pour acc&eacute;der &agrave; des astuces, avantages et bien plus encore' -Body '' -ButtonSrc 'm3f_leave_review.png' -ButtonAlt 'Laissez un avis' -ButtonUrl $landingFr)
"@

    return $body
}

function Get-Mailer4EnglishBody {
    param(
        [bool] $IncludeQr
    )

    $tip1Label = Get-LiveTipLabelRow -Label 'Tip 1'
    $tip2Label = Get-LiveTipLabelRow -Label 'Tip 2'
    $tip3Label = Get-LiveTipLabelRow -Label 'Tip 3'
    $tip4Label = Get-LiveTipLabelRow -Label 'Tip 4'

    $body = @"
$(Get-LogoHeader -HomeUrl $homeEn -LogoSrc 'm4e_logo.png')
                        <table border="0" cellpadding="0" cellspacing="0" class="mailcont" id="emailContainer" style="background-color:#ffffff; width:600px;" width="600">
                            <tbody>
                                <tr><td height="25" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><img alt="Galaxy AI" border="0" height="46" src="m4e_ai_logo.png" style="width:234px; height:46px; display:block; margin:auto;" width="234"></td></tr>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center; padding:0 40px;"><span style="font-size:36px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Capture in detail.<br>Create effortlessly</span></strong></span></td></tr>
                                <tr><td height="12" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center; padding:0 48px;"><span style="font-size:18px; line-height:28px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Unleash your creativity with pro-grade tools enhanced by Galaxy AI.</span></span></td></tr>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingEn" target="_blank"><img alt="Learn more" border="0" height="50" src="m4e_learn_more.png" style="width:174px; height:50px; display:block; margin:auto;" width="174"></a></td></tr>
                                <tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                            </tbody>
                        </table>

                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background:#ffffff;" width="600"><tbody><tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
$tip1Label
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><span style="font-size:32px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Clear and bright,<br>even at night</span></strong></span></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingEn" target="_blank"><img alt="Nightography" border="0" height="339" src="m4e_tip1.png" style="width:520px; height:339px; display:block; margin:auto;" width="520"></a></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center; padding:0 40px;"><span style="font-size:18px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Nightography delivers clear and detailed video in low-light environments.</span></span></td></tr>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingEn" target="_blank"><img alt="Learn more" border="0" height="50" src="m4e_learn_more.png" style="width:174px; height:50px; display:block; margin:auto;" width="174"></a></td></tr>
                                <tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr></tbody></table>

                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background:#ffffff;" width="600"><tbody><tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
$tip2Label
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><span style="font-size:32px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">From photos to<br>stickers in a tap</span></strong></span></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingEn" target="_blank"><img alt="Creative Studio" border="0" height="339" src="m4e_tip2.png" style="width:520px; height:339px; display:block; margin:auto;" width="520"></a></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center; padding:0 40px;"><span style="font-size:18px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Create sticker sets in <strong>Creative Studio</strong>. With a simple text description, Galaxy AI produces the creations.</span></span></td></tr>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingEn" target="_blank"><img alt="Learn more" border="0" height="50" src="m4e_learn_more.png" style="width:174px; height:50px; display:block; margin:auto;" width="174"></a></td></tr>
                                <tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr></tbody></table>

                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background:#ffffff;" width="600"><tbody><tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
$tip3Label
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><span style="font-size:32px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Make every shot<br>picture-perfect</span></strong></span></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingEn" target="_blank"><img alt="Photo Assist" border="0" height="340" src="m4e_tip3.png" style="width:520px; height:340px; display:block; margin:auto;" width="520"></a></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center; padding:0 40px;"><span style="font-size:18px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Edit photos to your heart's content with <strong>Photo Assist</strong>. Just press and hold an object to move, resize, or enlarge it.</span></span></td></tr>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingEn" target="_blank"><img alt="Learn more" border="0" height="50" src="m4e_learn_more.png" style="width:174px; height:50px; display:block; margin:auto;" width="174"></a></td></tr>
                                <tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr></tbody></table>

                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background:#ffffff;" width="600"><tbody><tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
$tip4Label
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><span style="font-size:32px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Generate videos like a pro<br>with AI editing</span></strong></span></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
$(Get-Mailer4Tip4Rows -TopImage 'm4e_tip4_left.png' -TopImageAlt 'Audio Eraser' -TopText 'Remove background noise from your recordings with <strong>Audio Eraser</strong>.' -BottomImage 'm4e_tip4_right.png' -BottomImageAlt 'Auto Trim' -BottomText 'Capture your moments, and transform them into polished clips with <strong>Auto Trim</strong>.')
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingEn" target="_blank"><img alt="Learn more" border="0" height="50" src="m4e_learn_more.png" style="width:174px; height:50px; display:block; margin:auto;" width="174"></a></td></tr>
                                <tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr></tbody></table>

$(Get-InfoCard -IconSrc 'm4e_lightbulb.png' -IconAlt 'Looking for more information?' -Headline 'Looking for more information?' -Body 'Still more to discover - from product registration and tips, to apps, services and a connected experience with Galaxy eco-products.' -ButtonSrc 'm4e_explore_now.png' -ButtonAlt 'Explore now' -ButtonUrl $landingEn)
$(Get-ReviewCard -IconSrc 'm4e_review_icon.png' -Headline 'What''s your Galaxy moment?<br>Share your experience now' -ButtonSrc 'm4e_leave_review.png' -ButtonAlt 'Leave a review' -ButtonUrl $landingEn)
"@

    if ($IncludeQr) {
        $body += "`r`n" + (Get-QrRow -QrImage 'm4e_qr.png' -Title 'Try Galaxy AI on your phone' -LinkText 'Learn more &gt;' -Url $tryGalaxy)
    }

    return $body
}

function Get-Mailer4FrenchBody {
    $tip1Label = Get-ImageTipLabelRow -ImageSrc 'm4f_badge_1.png' -Alt 'Astuce 1' -Width 115 -Height 42
    $tip2Label = Get-ImageTipLabelRow -ImageSrc 'm4f_badge_2.png' -Alt 'Astuce 2' -Width 115 -Height 42
    $tip3Label = Get-ImageTipLabelRow -ImageSrc 'm4f_badge_3.png' -Alt 'Astuce 3' -Width 115 -Height 42
    $tip4Label = Get-ImageTipLabelRow -ImageSrc 'm4f_badge_4.png' -Alt 'Astuce 4' -Width 115 -Height 42

    $body = @"
$(Get-LogoHeader -HomeUrl $homeFr -LogoSrc 'm4f_logo.png')
                        <table border="0" cellpadding="0" cellspacing="0" class="mailcont" id="emailContainer" style="background-color:#ffffff; width:600px;" width="600">
                            <tbody>
                                <tr><td height="25" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><img alt="Galaxy AI" border="0" height="46" src="m4f_ai_logo.png" style="width:234px; height:46px; display:block; margin:auto;" width="234"></td></tr>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center; padding:0 40px;"><span style="font-size:36px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Capturez chaque d&eacute;tail.<br>Cr&eacute;ez en toute simplicit&eacute;</span></strong></span></td></tr>
                                <tr><td height="12" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center; padding:0 48px;"><span style="font-size:18px; line-height:28px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Lib&eacute;rez votre cr&eacute;ativit&eacute; gr&acirc;ce &agrave; des outils de niveau professionnel enrichis par Galaxy AI.</span></span></td></tr>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingFr" target="_blank"><img alt="En savoir plus" border="0" height="50" src="m4f_learn_more.png" style="width:184px; height:50px; display:block; margin:auto;" width="184"></a></td></tr>
                                <tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                            </tbody>
                        </table>

                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background:#ffffff;" width="600"><tbody><tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
$tip1Label
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><span style="font-size:32px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Clair et lumineux,<br>m&ecirc;me la nuit</span></strong></span></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingFr" target="_blank"><img alt="Nightography" border="0" height="339" src="m4f_tip1.png" style="width:520px; height:339px; display:block; margin:auto;" width="520"></a></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center; padding:0 40px;"><span style="font-size:18px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Nightography vous permet de capturer des vid&eacute;os claires et d&eacute;taill&eacute;es, m&ecirc;me en faible luminosit&eacute;.</span></span></td></tr>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingFr" target="_blank"><img alt="En savoir plus" border="0" height="50" src="m4f_learn_more.png" style="width:184px; height:50px; display:block; margin:auto;" width="184"></a></td></tr>
                                <tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr></tbody></table>

                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background:#ffffff;" width="600"><tbody><tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
$tip2Label
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><span style="font-size:32px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Des photos aux<br>stickers en un geste</span></strong></span></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingFr" target="_blank"><img alt="Studio Cr&eacute;ation" border="0" height="339" src="m4f_tip2.png" style="width:520px; height:339px; display:block; margin:auto;" width="520"></a></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center; padding:0 40px;"><span style="font-size:18px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Cr&eacute;ez des packs de stickers dans <strong>Studio Cr&eacute;ation</strong>. &Agrave; partir d'une simple description texte, Galaxy AI g&eacute;n&egrave;re vos cr&eacute;ations.</span></span></td></tr>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingFr" target="_blank"><img alt="En savoir plus" border="0" height="50" src="m4f_learn_more.png" style="width:184px; height:50px; display:block; margin:auto;" width="184"></a></td></tr>
                                <tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr></tbody></table>

                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background:#ffffff;" width="600"><tbody><tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
$tip3Label
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><span style="font-size:32px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Des clich&eacute;s parfaits<br>&agrave; chaque prise</span></strong></span></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingFr" target="_blank"><img alt="Assistant Photo" border="0" height="340" src="m4f_tip3.png" style="width:520px; height:340px; display:block; margin:auto;" width="520"></a></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center; padding:0 40px;"><span style="font-size:18px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Retouchez vos photos comme vous le souhaitez avec l'Assistant Photo. Maintenez simplement un objet pour le d&eacute;placer, le redimensionner ou l'agrandir.</span></span></td></tr>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingFr" target="_blank"><img alt="En savoir plus" border="0" height="50" src="m4f_learn_more.png" style="width:184px; height:50px; display:block; margin:auto;" width="184"></a></td></tr>
                                <tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr></tbody></table>

                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background:#ffffff;" width="600"><tbody><tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
$tip4Label
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><span style="font-size:32px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Cr&eacute;ez des vid&eacute;os comme un pro<br>gr&acirc;ce &agrave; l'IA.</span></strong></span></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
$(Get-Mailer4Tip4Rows -TopImage 'm4f_tip4_left.png' -TopImageAlt 'Effaceur Audio' -TopText 'Supprimez les bruits de fond de vos enregistrements avec l''Effaceur Audio.' -BottomImage 'm4f_tip4_right.png' -BottomImageAlt 'Auto Trim' -BottomText 'Capturez vos moments et transformez-les en clips soign&eacute;s avec la fonction D&eacute;coupage automatique (Auto Trim).')
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingFr" target="_blank"><img alt="En savoir plus" border="0" height="50" src="m4f_learn_more.png" style="width:184px; height:50px; display:block; margin:auto;" width="184"></a></td></tr>
                                <tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr></tbody></table>

$(Get-InfoCard -IconSrc 'm4f_lightbulb.png' -IconAlt 'Vous cherchez plus d''informations ?' -Headline 'Vous cherchez plus d''informations ?' -Body 'Il y a encore beaucoup &agrave; d&eacute;couvrir - de l''enregistrement de votre produit aux astuces, en passant par les applications, les services et une exp&eacute;rience connect&eacute;e avec l''&eacute;cosyst&egrave;me Galaxy.' -ButtonSrc 'm4f_explore_now.png' -ButtonAlt 'Explorez maintenant' -ButtonUrl $landingFr)
$(Get-ReviewCard -IconSrc 'm4f_review_icon.png' -Headline 'Quelle est votre exp&eacute;rience Galaxy ?<br>Partagez-la maintenant' -ButtonSrc 'm4f_leave_review.png' -ButtonAlt 'Laissez un avis' -ButtonUrl $landingFr)
"@

    return $body
}

function Get-Mailer5EnglishBody {
    param(
        [bool] $IncludeQr,
        [bool] $SingleCare
    )

    $tip1Label = Get-LiveTipLabelRow -Label 'Tip 1'
    $tip2Label = Get-LiveTipLabelRow -Label 'Tip 2'
    $tip3Label = Get-LiveTipLabelRow -Label 'Tip 3'

    if ($SingleCare) {
        $careIcons = @"
                                <tr>
                                    <td style="text-align:center;">
                                        <table align="center" border="0" cellpadding="12" cellspacing="0"><tbody><tr><td align="center"><img alt="Certified care" border="0" height="76" src="m5e_care_certified.png" style="width:50px; height:76px; display:block; margin:auto;" width="50"></td></tr><tr><td align="center"><span style="font-size:15px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Certified care</span></strong></span></td></tr></tbody></table>
                                    </td>
                                </tr>
"@
        $careBody = 'Always with you through your mobile device journey and new beginnings, supported by One free screen repair for seamless moments.'
    }
    else {
        $careIcons = @"
                                <tr>
                                    <td style="text-align:center;">
                                        <table align="center" border="0" cellpadding="12" cellspacing="0"><tbody><tr><td align="center"><img alt="Priority queue" border="0" height="73" src="m5e_care_priority.png" style="width:61px; height:73px; display:block; margin:auto;" width="61"></td><td align="center"><img alt="Certified care" border="0" height="76" src="m5e_care_certified.png" style="width:50px; height:76px; display:block; margin:auto;" width="50"></td><td align="center"><img alt="Home and abroad" border="0" height="70" src="m5e_care_global.png" style="width:71px; height:70px; display:block; margin:auto;" width="71"></td></tr><tr><td align="center"><span style="font-size:15px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Priority queue</span></strong></span></td><td align="center"><span style="font-size:15px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Certified care</span></strong></span></td><td align="center"><span style="font-size:15px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Home and abroad</span></strong></span></td></tr></tbody></table>
                                    </td>
                                </tr>
"@
        $careBody = 'Always with you through your mobile device journey and new beginnings, supported by unlimited repair for seamless moments.'
    }

    $body = @"
$(Get-LogoHeader -HomeUrl $homeEn -LogoSrc 'm5e_logo.png')
                        <table border="0" cellpadding="0" cellspacing="0" class="mailcont" id="emailContainer" style="background-color:#ffffff; width:600px;" width="600">
                            <tbody>
                                <tr><td height="12" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center; padding:0 40px;"><span style="font-size:48px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Galaxy here to<br>power you in<br>all ways</span></strong></span></td></tr>
                                <tr><td height="18" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center; padding:0 48px;"><span style="font-size:18px; line-height:28px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Find the essential apps &amp; services<br>that will make the most of your<br>Galaxy experience.</span></span></td></tr>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td><a href="$landingEn" target="_blank"><img alt="Galaxy here to power you in all ways" border="0" height="461" src="m5e_hero.png" style="display:block; width:600px; height:461px;" width="600"></a></td></tr>
                            </tbody>
                        </table>

                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background:#ffffff;" width="600"><tbody><tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
$tip1Label
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><span style="font-size:32px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Become a better<br>version of you</span></strong></span></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingEn" target="_blank"><img alt="Samsung Health" border="0" height="339" src="m5e_health.png" style="width:520px; height:339px; display:block; margin:auto;" width="520"></a></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><img alt="Samsung Health" border="0" height="58" src="m5e_health_logo.png" style="width:338px; height:58px; display:block; margin:auto;" width="338"></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center; padding:0 40px;"><span style="font-size:18px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Samsung Health tracks your health data and provides AI-powered insight. Start your health care journey now.</span></span></td></tr>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingEn" target="_blank"><img alt="Learn more" border="0" height="50" src="m5e_learn_more.png" style="width:174px; height:50px; display:block; margin:auto;" width="174"></a></td></tr>
                                <tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr></tbody></table>

                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background:#ffffff;" width="600"><tbody><tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
$tip2Label
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><span style="font-size:32px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Smart home that<br>takes care of you</span></strong></span></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingEn" target="_blank"><img alt="SmartThings" border="0" height="339" src="m5e_smartthings.png" style="width:520px; height:339px; display:block; margin:auto;" width="520"></a></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center; padding:0 40px;"><span style="font-size:18px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Connect smart devices and receive personalized living solutions effortlessly with SmartThings routines.</span></span></td></tr>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingEn" target="_blank"><img alt="Learn more" border="0" height="50" src="m5e_learn_more.png" style="width:174px; height:50px; display:block; margin:auto;" width="174"></a></td></tr>
                                <tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr></tbody></table>

                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background:#ffffff;" width="600"><tbody><tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
$tip3Label
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><span style="font-size:32px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Peace of mind today<br>lasting value tomorrow</span></strong></span></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingEn" target="_blank"><img alt="Samsung Care+" border="0" height="339" src="m5e_care.png" style="width:520px; height:339px; display:block; margin:auto;" width="520"></a></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><img alt="Samsung Care+" border="0" height="67" src="m5e_care_logo.png" style="width:328px; height:67px; display:block; margin:auto;" width="328"></td></tr>
                                <tr><td height="10" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
$careIcons
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center; padding:0 40px;"><span style="font-size:18px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">$careBody</span></span></td></tr>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingEn" target="_blank"><img alt="Learn more" border="0" height="50" src="m5e_learn_more.png" style="width:174px; height:50px; display:block; margin:auto;" width="174"></a></td></tr>
                                <tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr></tbody></table>

$(Get-InfoCard -IconSrc 'm5e_lightbulb.png' -IconAlt 'Looking for more information?' -Headline 'Looking for more information?' -Body 'There''s still more to discover. From how-to guides to smart features, here''s everything you need to make the most of your Galaxy.' -ButtonSrc 'm5e_explore_now.png' -ButtonAlt 'Explore now' -ButtonUrl $landingEn)
"@

    if ($IncludeQr) {
        $body += "`r`n" + (Get-QrRow -QrImage 'm5e_qr.png' -Title 'Try Galaxy AI on your phone' -LinkText 'Learn more &gt;' -Url $tryGalaxy)
    }

    return $body
}

function Get-Mailer5FrenchBody {
    $tip1Label = Get-LiveTipLabelRow -Label 'Astuce 1'
    $tip2Label = Get-LiveTipLabelRow -Label 'Astuce 2'

    $body = @"
                        <table border="0" cellpadding="0" cellspacing="0" class="mailcont" id="emailContainer" style="background-color:#ffffff; width:600px;" width="600">
                            <tbody>
                                <tr><td><a href="$landingFr" target="_blank"><img alt="Galaxy est l&agrave; pour vous accompagner &agrave; chaque instant" border="0" height="939" src="m5f_hero.png" style="display:block; width:600px; height:939px;" width="600"></a></td></tr>
                            </tbody>
                        </table>

                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background:#ffffff;" width="600"><tbody><tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
$tip1Label
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><span style="font-size:32px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Devenez la meilleure<br>version de vous-m&ecirc;me</span></strong></span></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingFr" target="_blank"><img alt="Samsung Health" border="0" height="339" src="m5f_health.png" style="width:520px; height:339px; display:block; margin:auto;" width="520"></a></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><img alt="Samsung Health" border="0" height="58" src="m5f_health_logo.png" style="width:338px; height:58px; display:block; margin:auto;" width="338"></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center; padding:0 40px;"><span style="font-size:18px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Samsung Health suit vos donn&eacute;es de sant&eacute; et fournit des analyses bas&eacute;es sur l'IA. Commencez votre parcours bien-&ecirc;tre d&egrave;s maintenant.</span></span></td></tr>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingFr" target="_blank"><img alt="En savoir plus" border="0" height="50" src="m5f_learn_more.png" style="width:184px; height:50px; display:block; margin:auto;" width="184"></a></td></tr>
                                <tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr></tbody></table>

                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background:#ffffff;" width="600"><tbody><tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
$tip2Label
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><span style="font-size:32px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Une maison connect&eacute;e<br>qui prend soin de vous</span></strong></span></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingFr" target="_blank"><img alt="SmartThings" border="0" height="339" src="m5f_smartthings.png" style="width:520px; height:339px; display:block; margin:auto;" width="520"></a></td></tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center; padding:0 40px;"><span style="font-size:18px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Connectez vos appareils intelligents et profitez de solutions personnalis&eacute;es en toute simplicit&eacute; gr&acirc;ce aux routines SmartThings.</span></span></td></tr>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr><td style="text-align:center;"><a href="$landingFr" target="_blank"><img alt="En savoir plus" border="0" height="50" src="m5f_learn_more.png" style="width:184px; height:50px; display:block; margin:auto;" width="184"></a></td></tr>
                                <tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr></tbody></table>

$(Get-InfoCard -IconSrc 'm5f_lightbulb.png' -IconAlt 'Vous cherchez plus d''informations ?' -Headline 'Vous cherchez plus d''informations ?' -Body 'Il reste encore beaucoup &agrave; d&eacute;couvrir. Des guides pratiques aux fonctionnalit&eacute;s intelligentes, voici tout ce dont vous avez besoin pour profiter pleinement de votre Galaxy.' -ButtonSrc 'm5f_explore_now.png' -ButtonAlt 'Explorez maintenant' -ButtonUrl $landingFr)
"@

    return $body
}

$outputs = @(
    @{ Name = 'ZAS26088113  S26 Series Onboarding_Mailers_W19_GH 3'; Html = (New-MailerDocument -Title 'Samsung Ghana' -Preheader 'Explore possibilities with your new Galaxy' -Body (Get-Mailer3EnglishBody -IncludeQr:$false) -Footer $footerGh); Assets = $assetMaps.m3e },
    @{ Name = 'ZAS26088113  S26 Series Onboarding_Mailers_W19_NG 3'; Html = (New-MailerDocument -Title 'Samsung Nigeria' -Preheader 'Explore possibilities with your new Galaxy' -Body (Get-Mailer3EnglishBody -IncludeQr:$false) -Footer $footerNg); Assets = $assetMaps.m3e },
    @{ Name = 'ZAS26088113  S26 Series Onboarding_Mailers_W19_KE 3'; Html = (New-MailerDocument -Title 'Samsung Kenya' -Preheader 'Explore possibilities with your new Galaxy' -Body (Get-Mailer3EnglishBody -IncludeQr:$true) -Footer $footerKe); Assets = $assetMaps.m3e },
    @{ Name = 'ZAS26088113  S26 Series Onboarding_Mailers_W19_TZ 3'; Html = (New-MailerDocument -Title 'Samsung Tanzania' -Preheader 'Explore possibilities with your new Galaxy' -Body (Get-Mailer3EnglishBody -IncludeQr:$true) -Footer $footerTz); Assets = $assetMaps.m3e },
    @{ Name = 'ZAS26088113  S26 Series Onboarding_Mailers_W19_MU 3'; Html = (New-MailerDocument -Title 'Samsung Mauritius' -Preheader 'Explore possibilities with your new Galaxy' -Body (Get-Mailer3EnglishBody -IncludeQr:$false) -Footer $footerMu); Assets = $assetMaps.m3e },
    @{ Name = 'ZAS26088113  S26 Series Onboarding_Mailers_W19_SN 3'; Html = (New-MailerDocument -Title 'Samsung Senegal' -Preheader 'Explorez de nouvelles possibilit&eacute;s avec votre nouveau Galaxy' -Body (Get-Mailer3FrenchBody) -Footer $footerSn); Assets = $assetMaps.m3f },
    @{ Name = 'ZAS26088113  S26 Series Onboarding_Mailers_W19_CI 3'; Html = (New-MailerDocument -Title 'Samsung C&ocirc;te d''Ivoire' -Preheader 'Explorez de nouvelles possibilit&eacute;s avec votre nouveau Galaxy' -Body (Get-Mailer3FrenchBody) -Footer $footerCi); Assets = $assetMaps.m3f },
    @{ Name = 'ZAS26088113  S26 Series Onboarding_Mailers_W19_GH 4'; Html = (New-MailerDocument -Title 'Samsung Ghana' -Preheader 'Capture in detail. Create effortlessly' -Body (Get-Mailer4EnglishBody -IncludeQr:$false) -Footer $footerGh); Assets = $assetMaps.m4e },
    @{ Name = 'ZAS26088113  S26 Series Onboarding_Mailers_W19_NG 4'; Html = (New-MailerDocument -Title 'Samsung Nigeria' -Preheader 'Capture in detail. Create effortlessly' -Body (Get-Mailer4EnglishBody -IncludeQr:$false) -Footer $footerNg); Assets = $assetMaps.m4e },
    @{ Name = 'ZAS26088113  S26 Series Onboarding_Mailers_W19_KE 4'; Html = (New-MailerDocument -Title 'Samsung Kenya' -Preheader 'Capture in detail. Create effortlessly' -Body (Get-Mailer4EnglishBody -IncludeQr:$true) -Footer $footerKe); Assets = $assetMaps.m4e },
    @{ Name = 'ZAS26088113  S26 Series Onboarding_Mailers_W19_TZ 4'; Html = (New-MailerDocument -Title 'Samsung Tanzania' -Preheader 'Capture in detail. Create effortlessly' -Body (Get-Mailer4EnglishBody -IncludeQr:$true) -Footer $footerTz); Assets = $assetMaps.m4e },
    @{ Name = 'ZAS26088113  S26 Series Onboarding_Mailers_W19_MU 4'; Html = (New-MailerDocument -Title 'Samsung Mauritius' -Preheader 'Capture in detail. Create effortlessly' -Body (Get-Mailer4EnglishBody -IncludeQr:$false) -Footer $footerMu); Assets = $assetMaps.m4e },
    @{ Name = 'ZAS26088113  S26 Series Onboarding_Mailers_W19_SN 4'; Html = (New-MailerDocument -Title 'Samsung Senegal' -Preheader 'Capturez chaque d&eacute;tail. Cr&eacute;ez en toute simplicit&eacute;' -Body (Get-Mailer4FrenchBody) -Footer $footerSn); Assets = $assetMaps.m4f },
    @{ Name = 'ZAS26088113  S26 Series Onboarding_Mailers_W19_CI 4'; Html = (New-MailerDocument -Title 'Samsung C&ocirc;te d''Ivoire' -Preheader 'Capturez chaque d&eacute;tail. Cr&eacute;ez en toute simplicit&eacute;' -Body (Get-Mailer4FrenchBody) -Footer $footerCi); Assets = $assetMaps.m4f },
    @{ Name = 'ZAS26088113  S26 Series Onboarding_Mailers_W19_GH 5'; Html = (New-MailerDocument -Title 'Samsung Ghana' -Preheader 'Galaxy here to power you in all ways' -Body (Get-Mailer5EnglishBody -IncludeQr:$false -SingleCare:$false) -Footer $footerGh); Assets = $assetMaps.m5e },
    @{ Name = 'ZAS26088113  S26 Series Onboarding_Mailers_W19_NG 5'; Html = (New-MailerDocument -Title 'Samsung Nigeria' -Preheader 'Galaxy here to power you in all ways' -Body (Get-Mailer5EnglishBody -IncludeQr:$false -SingleCare:$false) -Footer $footerNg); Assets = $assetMaps.m5e },
    @{ Name = 'ZAS26088113  S26 Series Onboarding_Mailers_W19_KE 5'; Html = (New-MailerDocument -Title 'Samsung Kenya' -Preheader 'Galaxy here to power you in all ways' -Body (Get-Mailer5EnglishBody -IncludeQr:$true -SingleCare:$false) -Footer $footerKe); Assets = $assetMaps.m5e },
    @{ Name = 'ZAS26088113  S26 Series Onboarding_Mailers_W19_TZ 5'; Html = (New-MailerDocument -Title 'Samsung Tanzania' -Preheader 'Galaxy here to power you in all ways' -Body (Get-Mailer5EnglishBody -IncludeQr:$true -SingleCare:$false) -Footer $footerTz); Assets = $assetMaps.m5e },
    @{ Name = 'ZAS26088113  S26 Series Onboarding_Mailers_W19_MU 5'; Html = (New-MailerDocument -Title 'Samsung Mauritius' -Preheader 'Galaxy here to power you in all ways' -Body (Get-Mailer5EnglishBody -IncludeQr:$false -SingleCare:$true) -Footer $footerMu); Assets = $assetMaps.m5e },
    @{ Name = 'ZAS26088113  S26 Series Onboarding_Mailers_W19_SN 5'; Html = (New-MailerDocument -Title 'Samsung Senegal' -Preheader 'Galaxy est l&agrave; pour vous accompagner &agrave; chaque instant' -Body (Get-Mailer5FrenchBody) -Footer $footerSn); Assets = $assetMaps.m5f },
    @{ Name = 'ZAS26088113  S26 Series Onboarding_Mailers_W19_CI 5'; Html = (New-MailerDocument -Title 'Samsung C&ocirc;te d''Ivoire' -Preheader 'Galaxy est l&agrave; pour vous accompagner &agrave; chaque instant' -Body (Get-Mailer5FrenchBody) -Footer $footerCi); Assets = $assetMaps.m5f }
)

foreach ($output in $outputs) {
    Write-OutputPackage -Name $output.Name -Html $output.Html -AssetMap $output.Assets
}

New-ServerBundle -PackageNames ($outputs | ForEach-Object { $_.Name })
