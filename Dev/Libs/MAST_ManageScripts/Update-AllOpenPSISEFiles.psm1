function Update-AllOpenPSISEFiles {
<#
.NOTES
	Name: Update-AllOpenPSISEFiles
	Autor: viatstma
	Version History:
		12.07.2017 - Initial Release
.SYNOPSIS
	Eine Replace-Funktion für den ISE um Dateien zu öffnen und dann in allen offenen Dateien zu ersetzen
.PARAMETER SearchString
	Der Such-String ist REGEX-fähig
.PARAMETER ReplaceString
	Der neue String
.PARAMETER OpenDevFilesFilter
	Ein Filter um eventuell Dateien aus dem Dev-Verzeichnis zu öffnen
.EXAMPLE
	Update-AllOpenPSISEFiles "String1" "String1"
	Wenn der Suchstring gleich dem Replacestring ist, kann man es als Suchfunktion benutzen (Registerkarten mit * sind "geändert"
    und haben somit mindestens einen Treffer
.EXAMPLE
	Update-AllOpenPSISEFiles "String1" "String2" -OpenDevFilesFilter "*.ps1", "*.psm1"
	Wenn der Suchstring gleich dem Replacestring ist, kann man es als Suchfunktion benutzen (Registerkarten mit * sind "geändert"
    und haben somit mindestens einen Treffer
    Durch den OpenDevFilesFilter Parameter werden zuvor alle Skript-Dateien aus dem Dev-Verzeichnis geöffnet und dann gesucht
.EXAMPLE
	Update-AllOpenPSISEFiles "String1" "String2"
    So werden alle "String1" Vorkommnisse in allen offenen Dateien im ISE durch "String2" ersetzt.
    Die Dateien werden nicht automatisch gespeichert. Das muss dann noch händisch erledigt werden
#>
	[CmdletBinding()]
	param(
		[parameter(Mandatory=$true,Position=0,HelpMessage="Der zu suchende String")]
		[string] $SearchString,
        [parameter(Mandatory=$true,Position=1,HelpMessage="Der ersetzende String")]
		[string] $ReplaceString,
        [parameter(Mandatory=$false,HelpMessage="Welche Dateien im Editor geöffnet werden sollen")]
		[string[]] $OpenDevFilesFilter
	)
	begin {
		Write-Verbose "--- $($MyInvocation.MyCommand) - Begin - Start"

        if ($Host.Name -notlike "*ISE*") {
            Write-Warning "Diese Funktion kann nur im Powershell ISE Host verwendet werden"
            break
        }

        if ($OpenDevFilesFilter) {
            psedit @(Get-ChildItem $MASTPath.Dev.Env -Include $OpenDevFilesFilter -Recurse | Convert-Path)
        }
        
        $iFiles = 0
        $iMatch = 0

		Write-Verbose "--- $($MyInvocation.MyCommand) - Begin - End"
	}
	process {
		Write-Verbose "--- $($MyInvocation.MyCommand) - Process - Start"
		
        foreach ($PSTab in $psise.PowerShellTabs) {
            foreach ($PSFile in $PSTab.Files) {
                ## Zähle die Vorkomnisse des Suchstrings
                $iCount = [regex]::Matches($PSFile.Editor.Text, [regex]::Escape($SearchString)).Count
                
                Write-Verbose "$iCount gefunden in $($PSFile.DisplayName)"

                if ($iCount -gt 0) {
                    ## Erhöhe die Zähler
                    $iMatch += $iCount
                    $iFiles++

                    ## Ersetze die aktuellen Text durch den neuen mit den geänderten Strings
                    $PSFile.Editor.Text = $PSFile.Editor.Text -replace ([regex]::Escape($SearchString), $ReplaceString)
                }
            }
        }

		Write-Verbose "--- $($MyInvocation.MyCommand) - Process - End"
	}
	end {
		Write-Verbose "--- $($MyInvocation.MyCommand) - End - Start"
		
        Write-Host "Es wurde(n) $iMatch Vorkomnisse in $iFiles Datei(en) ersetzt" -ForegroundColor Green

		Write-Verbose "--- $($MyInvocation.MyCommand) - End - End"
	}
}

# SIG # Begin signature block
# MIIJXAYJKoZIhvcNAQcCoIIJTTCCCUkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU+7pASW0CSPlbnBL6duB7t5gy
# lw+gggbQMIIGzDCCBLSgAwIBAgIKHtjtxQABAAABvjANBgkqhkiG9w0BAQsFADBH
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
# AQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTCPFFDpx1m
# wEblPmG9riVrtql55TANBgkqhkiG9w0BAQEFAASCAQBMnTSiYBTwuIsTl0SlPw0M
# PyCUxkKGz83ZXRmi8onghGPSmgvutqGNxl9gbxLOhCJqBj1bRCMb5b8ea3t9ehZ2
# TPIeQEZfJJHH+j6MjXneGSZ2wtvi0cDHUXH7IqvWX1TO+1h/rewBSY6lQ5RXxQNn
# altjyP4DPYVOCKFXG+s1lU9kToqG/ZGAqSmOVtsOLWFfRWksQgaYE79NWN73BZlk
# 5891SukgPFfWFchMpeqtt6UPptkfz5IM6yN3mOQKa/xr6+ajKIwxqK5S0pAh6Tfy
# w+1uVuRVNoZgsw5vv/cVGJDLvHF7lAjHM4+0Nn4u6mVa60B1EXihTdOSh5BsvKKT
# SIG # End signature block
