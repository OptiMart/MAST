function Publish-PSDevScripts {
<#
.SYNOPSIS
    Veröffentlicht alle vorbereiteten Skripte. Schiebt sie von der Release- in die Live-Umgebung und erstellt ein Backup
.DESCRIPTION
    Diese Funktion kann benutzt werden um im Entwicklungsprozess mit dem Parameter $Signature die bearbeitende Datei
    immer zu signieren und nicht zu löschen. Wenn alles erledigt ist wir dann mit dem Parameter $Delete die Datei aus dem
    Release-Verzeichnis gelöscht
.PARAMETER Signature
    Schalter ob alle Release-Skripte signiert werden sollen
.PARAMETER Delete
    Schalter ob die kopierten Dateien gelöscht werden sollen
#>
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$false,HelpMessage = "Schalter ob alle Release-Skripte signiert werden sollen")]
        [switch] $Signature,
        [parameter(Mandatory=$false,HelpMessage = "Schalter ob die kopierten Dateien gelöscht werden sollen")]
        [switch] $Delete,
        [parameter(Mandatory=$false,HelpMessage = "Filter welche Dateien verarbeitet werden sollen")]
        [string[]] $IncFile = @("*.ps1","*.psm1","*.psd1","*.xml")
    )
    begin {
		Write-Verbose "--- $($MyInvocation.MyCommand) - Begin - Start"
		
        .(Join-Path $MASTPath.Liv.Lib "PS-Func_Copy-ItemsEfkoGroup.ps1")

		Write-Verbose "--- $($MyInvocation.MyCommand) - Begin - End"
    }
    process{
		Write-Verbose "--- $($MyInvocation.MyCommand) - Process - Start"

        if ($Signature) {
            ## Wenn gewünscht werden auch gleich alle Skripte signiert
            Confirm-PSDevScripts -Release -Verbose:($PSBoundPARAMETERs['Verbose'] -eq $true) | Out-Null
            Write-Verbose "Bereitgestellte Dateien signiert"
        }

        ## Den Backup-Präfix jetzt definieren um einen einheitlichen für den gesamten Vorgang zu erzeugen
        $BkpPrefix = "$(Get-Date -Format "yyyy-MM-dd-HH-mm-ss")_"
        $PublishCount = 0

        ## Überprüfe alle Dateien im Release-Verzeichnis auf gültige Signaturen
        Get-ChildItem $MASTPath.Rel.Env -Recurse -Force -Include $IncFile | Get-AuthenticodeSignature | %{
            Write-Host "Veröffentliche: $($_.Path)".Replace($MASTPath.Rel.Env, "")

            if ($_.Status -eq "Valid" -or $_.Path -match ".psd1$" -or $_.Path -match ".xml$") {
                ## Nur wenn die Signatur der Datei gültig ist oder es sich um eine ModulManifest-Datei handelt wird sie kopiert
                Copy-ItemsEfkoGroup -PathDev $MASTPath.Rel.Env -PathBkp $MASTPath.Bkp.Env -PathDst $MASTPath.Liv.Env -FileFilter (Split-Path $_.Path -Leaf) -DeleteDev:$Delete -BkpPrefix $BkpPrefix -SendMail never -Verbose:($PSBoundPARAMETERs['Verbose'] -eq $true)
                $PublishCount++
            }
            else {
                Write-Warning "Die Datei $(Split-Path $_.Path -Leaf) hat keine gültige Signatur und wurde nicht veröffentlicht"
            }
        }

        Write-Host "$PublishCount Datei(en) wurden im Live-System aktualisiert" -ForegroundColor Magenta

        Write-Verbose "--- $($MyInvocation.MyCommand) - Process - End"
    }
}

# SIG # Begin signature block
# MIIJXAYJKoZIhvcNAQcCoIIJTTCCCUkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUpKdMs3/DTJokYF3jx4bcTIxk
# Ro2gggbQMIIGzDCCBLSgAwIBAgIKHtjtxQABAAABvjANBgkqhkiG9w0BAQsFADBH
# MRUwEwYKCZImiZPyLGQBGRYFbG9jYWwxFDASBgoJkiaJk/IsZAEZFgRlZmtvMRgw
# FgYDVQQDEw9lZmtvLUVGLURDMDEtQ0EwHhcNMTgwMzIwMTA0MzQ5WhcNMjMwMzE5
# MTA0MzQ5WjCBpTELMAkGA1UEBhMCQVQxETAPBgNVBAcTCEVmZXJkaW5nMTAwLgYD
# VQQKEydlZmtvIEZyaXNjaGZydWNodCB1bmQgRGVsaWthdGVzc2VuIEdtYmgxCzAJ
# BgNVBAsTAklUMSUwIwYDVQQDExxlZmtvIFNvZnR3YXJlIFNpZ25hdHVyZSAyMDE4
# MR0wGwYJKoZIhvcNAQkBFg5vZmZpY2VAZWZrby5hdDCCASIwDQYJKoZIhvcNAQEB
# BQADggEPADCCAQoCggEBALSIKqvZr3MEiOKluy/263oXtSWrt84cu5FZheNJg4gE
# V0QqBhn+m8zPdz6cAMzKEN8nurPHnBBYIlJ81SVfC7z3zaaQ+NCU2H6yFS4S/dTw
# Q1PjFowXHzuobXri1yKCl3FAqwPi5JclFOkOxPEJVjF26xsiLeppLGkQSjCaMkrI
# I8tWIAlZ9VCW15P+unBliaIgHFNHUl3HzcahK5/U49F2d5mmF2U00vRMnVtxMGN/
# abH+DymrRxMryIB1/6aA7axnCsTpBjhv/ZqasQPOInDQVrLWD1QGCHxzv2hWjK4s
# BnBdnCDaw9ff/Kr8cKHGJN749Pv2LDPSe3MQGmWF6w8CAwEAAaOCAlkwggJVMDwG
# CSsGAQQBgjcVBwQvMC0GJSsGAQQBgjcVCITtkHzSvUOGyY8vgey0GIb2wXdxg936
# KoTujxYCAWQCASYwEwYDVR0lBAwwCgYIKwYBBQUHAwMwDgYDVR0PAQH/BAQDAgeA
# MBsGCSsGAQQBgjcVCgQOMAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFNymGh84qixJ
# 0PehgMf04u5NQMKOMB8GA1UdIwQYMBaAFPnoqPzz1G3G9BUtBop05S9cTbMSMIHP
# BgNVHR8EgccwgcQwgcGggb6ggbuGgbhsZGFwOi8vL0NOPWVma28tRUYtREMwMS1D
# QSgxKSxDTj1FRi1EQzAxLENOPUNEUCxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2aWNl
# cyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPWVma28sREM9bG9jYWw/
# Y2VydGlmaWNhdGVSZXZvY2F0aW9uTGlzdD9iYXNlP29iamVjdENsYXNzPWNSTERp
# c3RyaWJ1dGlvblBvaW50MIHABggrBgEFBQcBAQSBszCBsDCBrQYIKwYBBQUHMAKG
# gaBsZGFwOi8vL0NOPWVma28tRUYtREMwMS1DQSxDTj1BSUEsQ049UHVibGljJTIw
# S2V5JTIwU2VydmljZXMsQ049U2VydmljZXMsQ049Q29uZmlndXJhdGlvbixEQz1l
# ZmtvLERDPWxvY2FsP2NBQ2VydGlmaWNhdGU/YmFzZT9vYmplY3RDbGFzcz1jZXJ0
# aWZpY2F0aW9uQXV0aG9yaXR5MA0GCSqGSIb3DQEBCwUAA4ICAQAfidCB9iTuGnx/
# Gc00xhMBrFB6eoL0UHgF+T4oC7PkQWdb/Up4dfRqF0DQzazLfPnQdysmOWs/eahV
# 9gFu1lSY8bRJD6Jl2Fz5dHWtiR+FMw6stKkxq6+gGOa/NYX9KbZnxoJdRa1LgUi/
# /TT3jlw6Yc3KtYxX/rvmEnPji2soLkQf0oWpQ+hWTPl1dYUW/Tq3GbRmLkBx1phD
# P1Vfp9wqVWDKoSJOVntZWeEKFDqTL+3segSs2gzsjh0Zpe64mWCeIFlLw8JenZlF
# Lq5vmjr702rQ97RW3APOyNCM5hEjBrj+Ut9DHFQ8kKmA+R4ZhYNfUwViKZQ+Tp0+
# kPaJLDKLdPZIvzkUPAibkg1VktY/DRx4NC/+2BEEdQBVHAAzR7vq0Te+gV/yFvrs
# xf6D+rXq3K0HJs3mX3y6IaGBYsCh3ipb2xnr1twD282uB49u+wkVE8MIX8Bsmi66
# lhukxc32/5pNQvl9S4julzl5yE4ji5HjOvXPz2JqtaCZpxz19MzkFviAD73P9r2p
# Q+Bxxe4mjrb7ehJJJ0wxBIQvnj2bQFidTw+D8iw5TTp6Z0APR5AtPym43f250KdL
# j8VW4851JgkwhmEAOFQqreEhbSTbLD3B6LUNeY5IFRzSa+agOh57HGzlCY9bW/lo
# 6UjeSDZfG82TCf89Li1cv3HodsUp3jGCAfYwggHyAgEBMFUwRzEVMBMGCgmSJomT
# 8ixkARkWBWxvY2FsMRQwEgYKCZImiZPyLGQBGRYEZWZrbzEYMBYGA1UEAxMPZWZr
# by1FRi1EQzAxLUNBAgoe2O3FAAEAAAG+MAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3
# AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisG
# AQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSn8ebgZ6L6
# xYxZ7zQTuoqWNaZdeDANBgkqhkiG9w0BAQEFAASCAQAwHcKzqpvQJu6yIsV8kbSV
# 7zL9VzlX0/Jray4y8N9itm/PhXXwaW9yolIiwFbDTl50DOcUomWUY8vGHQ4NMoou
# ZVdboo6goyJNqXLCqt2eM62X1r5bo8m0iHPOcwgQzWV//o/Pl0I218OBGIJGnDb7
# ALaO+t8YgG7WvsaIczl60MpkjNdEvHo0nhEDfF/+k5DkNz8Stild7gQJpo5xHNFg
# 0k9dCvVBSaKGHPst/vBqb2Yap99yS/R8Txp0K9fy2DuGcUS2K7UE6JlIaDSLS3fe
# H/M3Xl1hlnquXqqX3plQUIfHn5M/82RhHsh+NtnizhXx0tLDMV7qShCEfOr/mEuj
# SIG # End signature block
