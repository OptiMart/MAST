function Set-CodeSignature {
<# 
.SYNOPSIS
    Signiert alle übergebenen Powershell Dateien
.DESCRIPTION
.PARAMETER Path
    Es können beliebig viele Dateien/Ordner übergeben werden
.PARAMETER Standard
    Mit dem Schalter Standard werden alle Scripte im Vitana Standard-Pfad signiert
.EXAMPLE
    [PS] C:\>Set-CodeSignature C:\Script.ps1
    C:\Script.ps1 wird signiert
.EXAMPLE
    [PS] C:\>Set-CodeSignature C:\Scripts
    Es werden alle Dateien im Ordner C:\Scripts signiert
#>
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$false,ValueFromPipeline=$true,Position=0,HelpMessage = "Zu signierende Datei oder Ordner mit Dateien")]
        [ValidateScript({Test-Path $_})]
        [Alias('File','Path')]
        [string[]] $ScriptPath
    )
    begin {
		Write-Verbose "--- $($MyInvocation.MyCommand) - Begin - Start"
		
        $IncFile = @("*.ps1","*.psm1")
        $SigFile = @()
        
        # Überprüfe ob eine Signatur vorhanden ist -> Wenn nicht kann nicht signiert werden -> ende
        if (@(Get-ChildItem Cert:\CurrentUser\My -codesigning).Count -eq 0) {
            Write-Host "Keine gültige Signatur zum Signieren von Code gefunden" -ForegroundColor Yellow
            break
        }
        else {
            $Cert = @(Get-ChildItem Cert:\CurrentUser\My -codesigning)[0]
        }

		Write-Verbose "--- $($MyInvocation.MyCommand) - Begin - End"
    }
    process {
		Write-Verbose "--- $($MyInvocation.MyCommand) - Process - Start"

        Write-Verbose "ScriptPath: $ScriptPath"

        # Es wird mit der Datei oder den in dem Ordner enthaltenen Dateien weiter gearbeitet
        $SigFile += Get-ChildItem $ScriptPath -Recurse -Force -Include $IncFile | Get-AuthenticodeSignature | Where-Object -Property Status -NE -Value "Valid"

		Write-Verbose "--- $($MyInvocation.MyCommand) - Process - End"
    }
    end {
		Write-Verbose "--- $($MyInvocation.MyCommand) - End - Start"
		
        # Signiere alle gefundenen Dateien die keine gültige Signatur haben
        Write-Verbose "Anzahl Dateien: $($SigFile.Count)"

        if ($SigFile.Count -ge 1) {
            Set-AuthenticodeSignature -FilePath $SigFile.Path -Certificate $Cert | Format-Table -Property Path, Status, StatusMessage
        }

		Write-Verbose "--- $($MyInvocation.MyCommand) - End - End"
    }
}

# SIG # Begin signature block
# MIIJXAYJKoZIhvcNAQcCoIIJTTCCCUkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUULSAqkgE5R50pBvVo34CfD9u
# zr6gggbQMIIGzDCCBLSgAwIBAgIKHtjtxQABAAABvjANBgkqhkiG9w0BAQsFADBH
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
# AQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQJ7qH3MYS8
# tBeXjU2z34hApF5ygjANBgkqhkiG9w0BAQEFAASCAQAm2nCy0iCoYjd2zU8Ob4qa
# PXlFFdZtadJYEReB5j4k4A+0nIwpHqcgRrZ0ir77rCTSjf/aa0z7EwisdT158T36
# JACJ3bMMshL0neSQrjyJtjMG31hEieW1/qcJaNCk7jZoQ5/Ndwv7Fdlcct5wE7nV
# bi9hG6WSye7mlVWojozYzSODAXZHiDtuq1zmwSw/ztgXc95yD2LTbLw3iW80quUa
# tMuHG+vkMz4evrqqCC6KnVKNC2UyzdTNVKQGuGlgiG73jpeersu3qBuuyFOhGPT/
# GKbdeYl9wiWCdLkX+gGJllGF2HlkiIuSpITbiv35YiDzY4LCgt9P7/2yOwa5Juyb
# SIG # End signature block
