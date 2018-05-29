<#
.NOTES
    Autor: Martin Strobl
    Die Variable $EfkoDefaultMail wird für den Standard Mailversand verwendet
    Send-MailEfkoGroup
.SYNOPSIS
    Variable mit den Standard Emailempfängern pro Standort
#>

[CmdletBinding()]
param([switch] $Force)

#region ----------------------------------------------- Name der Variable -----------------------------------------------------

    $TempVarName = "EfkoDefaultMail"

    Write-Verbose "Lade Variable $TempVarName - Force: $Force"

#endregion -------------------------------------------- Name der Variable -----------------------------------------------------

## Aus Performacegründen werden diese Variablen nur einmalig erzeugt
if((Get-Variable -Name $TempVarName -ErrorAction SilentlyContinue) -eq $null -or $Force) {

#region -------------------------------------------- Parameter der Variable ---------------------------------------------------

    $TempVarScope = "global"
    $TempVarOption = [System.Management.Automation.ScopedItemOptions]::ReadOnly
    $TempVarDescription = "Variable mit den Standard Emailempfängern pro Standort"
    $TempVarVisibility = [System.Management.Automation.SessionStateEntryVisibility]::Public

#endregion ----------------------------------------- Parameter der Variable ---------------------------------------------------

#region ---------------------------------------------- Inhalt der Variable ----------------------------------------------------
    
    $TempVarValue = @{
        "Wien" = @{
            To = "martin.strobl@vitana.at;thomas.polzer@vitana.at"
            From = "$($env:computername)@vitana.at"
        };
        "Eferding" = @{
            To = "markus.roithmayr@efko.at;roland.fischer@efko.at"
            From = "$($env:computername)@efko.at"
        };
        "Naarn" = @{
            To = "michael.benezeder@machland.at"
            From = "$($env:computername)@machland.at"
        }
    }

#endregion ------------------------------------------- Inhalt der Variable ----------------------------------------------------

    try {
        ## Anlegen der gewünschten Variable
        New-Variable -Name $TempVarName -Value $TempVarValue -Scope $TempVarScope -Option $TempVarOption -Description $TempVarDescription -Visibility $TempVarVisibility -Force:($Force -eq $true) -ErrorAction Stop
        Write-Verbose " - laden erfolgreich"
    }
    catch {
        Write-Verbose " - Fehler"
        Write-Warning "Die Variable $TempVarName konnte nicht erzeugt werden. $($Error[0].Exception.Message)"
    }
}
else {
    Write-Verbose " - existiert schon"
}

## Entfernen der Temporären Variablen
Remove-Variable -Name "TempVar*"

# SIG # Begin signature block
# MIIJXAYJKoZIhvcNAQcCoIIJTTCCCUkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUQFooiikYT5nO/qIsYlAbeuLm
# QCCgggbQMIIGzDCCBLSgAwIBAgIKHtjtxQABAAABvjANBgkqhkiG9w0BAQsFADBH
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
# AQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQk+AYY9+uB
# /NJkPi77qQnkbh2NLjANBgkqhkiG9w0BAQEFAASCAQBsBwPOkGv8Mt/TCKc/B1Hr
# e3r9T4Bsc2FMZNXcCHW4IO3CM0hAR4l7uD84edMvjc2FaFt/J4A4Nv36s9pPFY1U
# No1bfAqkWZc03Qr1wz9FI6jR1OHxIndZp4zWfUQF8sqIXPY5zwFKR7rFLCYt4pMx
# 2Foi6iYKx0AAYzi62gkFhyZIFkiD+RqdWSA5N8QFJKqdLqPt7gdJdrjLySsMTech
# ScwiqaFCv9m6xvv8H88h0EU1JveZ/zbFY8gAACoGevJF2xuQul2eWqvQQ33npEqP
# Ye2MsqN2YUjw1XeKj15xoMAy24KRvzWO9nt2EHxqXZAZsodFF+4iwPjxJG7Wf+X0
# SIG # End signature block
