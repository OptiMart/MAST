function Clear-LogData {
<#
.NOTES
	Name: Clear-LogData
	Autor: ViAtStMa
	Version History:
		03.04.2018 - Initial Release
.SYNOPSIS
	Löscht alle Log-Daten die älter als X Tage sind
.DESCRIPTION
	Es werden alle Dateien gelöscht die länger als $Days Tage LastWriteTime Attribut haben
    Es werden alle Log-Daten in den Log-Files gelöscht die einen Zeitstempel älter als $Days haben
.PARAMETER Days
	Bereinigt die Log-Daten die älter als diese anzahl an Tagen ist (Default = 90)
#>
	[CmdletBinding()]
	param(
        [parameter(Mandatory=$false,Position=0)]
        [uint32] $Days = 90
    )
	begin {
		Write-Verbose "--- $($MyInvocation.MyCommand) - Begin - Start"
		
        [int] $RemovedFiles = 0
        [long] $RemovedChars = 0

        Write-Host "Hiermit werden die Log-Files bereinigt." -ForegroundColor Yellow
        $Weiter1 = Read-Host -Prompt "Soll fortgefahren werden? (j)"
        
        if ($Weiter1 -notmatch "j") {
            break
        }

        if ($Days -lt 90) {
            Write-Host "Sie haben einen Zeitraum kleiner 90 Tagen ausgewählt." -ForegroundColor Red
            $Weiter2 = Read-Host -Prompt "Soll fortgefahren werden? (j)"

            if ($Weiter2 -notmatch "j") {
                break
            }
        }

		Write-Verbose "--- $($MyInvocation.MyCommand) - Begin - End"
	}
	process {
		Write-Verbose "--- $($MyInvocation.MyCommand) - Process - Start"
		
        ## Lade alle Logfiles
        $LogFiles = @(Get-ChildItem -Path $MASTPath.Log.Env -Recurse -Include "*.log")
        Write-Host "Bereinigen der Log-Files unter $($MASTPath.Log.Env)" -ForegroundColor Cyan

        ## Verarbeite alle Log-Files
        foreach ($LogFile in $LogFiles) {
            
            Write-Host
            Write-Host "Bereinige $($LogFile.FullName -Replace [regex]::Escape($MASTPath.Log.Env), "... " )"
            [int64] $FileLength = $LogFile.Length

            if (($LogFile.LastWriteTime).AddDays($Days) -lt (Get-Date)) {
                
                ## Die Datei wird gelöscht da sie älter als der Bereinigungszeitraum ist
                Write-Host "  - Entferne Datei " -ForegroundColor Red -NoNewline
                
                try {
                    Remove-Item $LogFile -Force
                }
                catch {
                    Write-Warning "$($Error[0].Exception.Message)"
                }
                                    
                $RemovedFiles++
                $RemovedChars += $FileLength
                Write-Host "$("{0,0:N0}" -f $($FileLength)) Byte freigegeben" -ForegroundColor Green
            }
            else {
                ## Die Datei wird bereinigt
                
                ## Lade den Inhalt der Log-File und Filter nach Datum
                $LogData = Get-Content -Path $LogFile -Encoding UTF8 | 
                    Where-Object -FilterScript { @($_ -split "`t").Count -gt 1 } | 
                    Where-Object -FilterScript { (Get-Date @($_ -split "`t")[0]).AddDays($Days) -ge (Get-Date) }
            
                ## Schreibe die gefilterten Log-Daten wieder in das Log-File
                Write-Host "  - Komprimiere Datei " -ForegroundColor Yellow -NoNewline
                
                try {
                    Out-File -FilePath $LogFile -InputObject $LogData -Encoding utf8 -Force -Verbose:($PSBoundParameters['Verbose'] -eq $true)
                }
                catch {
                    Write-Warning "$($Error[0].Exception.Message)"
                }
                
                $LogFile.Refresh()
                $RemovedChars += $($FileLength - $LogFile.Length)
                Write-Host "$("{0,0:N0}" -f $($FileLength - $LogFile.Length)) Byte freigegeben" -ForegroundColor Green
            }
        }

		Write-Verbose "--- $($MyInvocation.MyCommand) - Process - End"
	}
	end {
		Write-Verbose "--- $($MyInvocation.MyCommand) - End - Start"

        Write-Host
        Write-Host "Verarbeitete Dateien: $($LogFiles.Count)"
        Write-Host "Gelöschte Dateien: $RemovedFiles"
        Write-Host "Gelöschte Zeichen: $RemovedChars"
        Write-Host $("Freigegebener Speicher: {0,0:N3} MiB" -f $($RemovedChars/1mb))
		
		Write-Verbose "--- $($MyInvocation.MyCommand) - End - End"
	}
}

# SIG # Begin signature block
# MIIJXAYJKoZIhvcNAQcCoIIJTTCCCUkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU4OF50pqS+Hy0nRbd6xQX/GQV
# ZhmgggbQMIIGzDCCBLSgAwIBAgIKHtjtxQABAAABvjANBgkqhkiG9w0BAQsFADBH
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
# AQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQgqC6vD8uN
# FvbwYZzNzYmfckHMDTANBgkqhkiG9w0BAQEFAASCAQAToNkGolmrNdV5rZg84x99
# wGOX3NiH5qezUXCmi7Thlgkn0pFFtaHKjwUZCMVHBD76YbHn9gt6BrtOqMdVNtlD
# jB/lw3o0x3UqO1Ygnc6N3Mqwxdf1VuFNqxB/6z/eCeRLbwXW204L1bpi+7i4FmB8
# AwLHDWoWB9YGI9/T6x11z1Mw8CEHKGTfP+IvWbfA/367LnRXxKHXHbpv+yin+ghN
# TUAxQ3Rh8Shi4HTMJaTB8qidIaohvGUnYNjmRR7f/txTTq+VupQBA/Cz0wBrVIv4
# SOw0qcQdYG7w+uUYXC0vP0G+17sCPiuIU7f677zYCZL9QuN1E21ZL0jy47eVAk++
# SIG # End signature block
