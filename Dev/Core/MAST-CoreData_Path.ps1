<#
.NOTES
    Autor: Martin Strobl
.SYNOPSIS
    Variable mit den Pfadangaben
.DESCRIPTION
    Die Variable $MASTPath beinhaltet alle Pfadangaben und wird im Profil geladen um dann
    überall zur Verfügung zu stehen
    Die Variable $MASTBasePath (Rootpath für die Powershellverwaltung) muss vorher definiert werden
#>

[CmdletBinding()]
param([switch] $Force)

#region ----------------------------------------------- Name der Variable -----------------------------------------------------

    $TempVarName = "MASTPath"
    
    Write-Verbose "Lade Variable $TempVarName - Force: $Force"

#endregion -------------------------------------------- Name der Variable -----------------------------------------------------

## Aus Performacegründen werden diese Variablen nur einmalig erzeugt
if((Get-Variable -Name $TempVarName -ErrorAction SilentlyContinue) -eq $null -or $Force) {

#region -------------------------------------------- Parameter der Variable ---------------------------------------------------

    $TempVarScope = "global"
    $TempVarOption = [System.Management.Automation.ScopedItemOptions]::ReadOnly
    $TempVarDescription = "Variable mit den MAST Pfaden"
    $TempVarVisibility = [System.Management.Automation.SessionStateEntryVisibility]::Public

#endregion ----------------------------------------- Parameter der Variable ---------------------------------------------------

#region ---------------------------------------------- Inhalt der Variable ----------------------------------------------------

    ## Dies ist die Hauptvariable; wird weiter unten noch ergänzt
    
    $TempVarValue = New-Object psobject -Property @{
        Base = $MASTBasePath
        Online = "\\efko.local\ItEfGrDfs\Scripts"  ## Der Root-Pfad zur Onlineumgebung (wird im Loader aktualisiert)
        Local = "C:\efko\Powershell"               ## Der Root-Pfad zur Offlineumgebung (wird im Loader aktualisiert)
        HKLM = "HKLM:\Software\efko\PS"            ## Der Registrypfad zu den Computer Settings
        HKCU = "HKCU:\Software\efko\PS"            ## Der Registrypfad zu den User Settings
        Logs = "$(Join-Path $MASTBasePath "Logs")" ## Der Pfad zu den Logdateien
        Site = "$(try{                             ## Der Standortname laut Activedirectory
                    $($([System.DirectoryServices.ActiveDirectory.ActiveDirectorySite]::GetComputerSite()).Name)
                }catch{"offline"})"
    }

    ## Unterordner auf Ebene 1
    $TempVarMASTPathSub1 = @{
        Liv = "Live"                               ## Ordner für die Live-Umgebung
        Live = "Live"                              ## Ordner für die Live-Umgebung
        Dev = "Dev"                                ## Ordner für die Entwicklungsumgebung
        Bkp = "Archiv"                             ## Ordner für das Archiv
        Rel = "Release"                            ## Ordner für die zu veröffentlichen Dateien
        Log = "Logs"                               ## Ordner für Logfiles
    }

    ## Unterordner auf Ebene 2
    $TempVarMASTPathSub2 = @{
        Env = ""                                   ## Wurzelverzeichnis
        Bin = "Bin"                                ## Ordner für Dateien mit direkt ausführbaren Code
        Cor = "Core"                               ## Ordner für Kern-Dateien
        Dat = "Data"                               ## Ordner für Dateien mit Variablen
        Inc = "Includes"                           ## Ordner für Dateien die vom Loader gezielt geladen werden
        Lib = "Libs"                               ## Ordner für allgemeine Funktionen und Module
    }

    ## Erzeuge alle Pfadangaben und füge sie dem Objekt hinzu
    foreach ($Sub1 in $TempVarMASTPathSub1.GetEnumerator()) {
        $TempVarSub1 = New-Object psobject

        foreach ($Sub2 in $TempVarMASTPathSub2.GetEnumerator()) {
            $TempVarSub1 | Add-Member -MemberType NoteProperty -Name $Sub2.Name -Value (Join-Path (Join-Path $MASTBasePath $Sub1.Value) $Sub2.Value)
        }

        $TempVarValue | Add-Member -MemberType NoteProperty -Name $Sub1.Name -Value $TempVarSub1
    }

#endregion ------------------------------------------- Inhalt der Variable ----------------------------------------------------

    try {
        ## Anlegen der gewünschten Variable
        Set-Variable -Name $TempVarName -Value $TempVarValue -Scope $TempVarScope -Option $TempVarOption -Description $TempVarDescription -Visibility $TempVarVisibility -Force:($Force -eq $true) -ErrorAction Stop
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUHnOPeLEcJ6aqAe0FiVe6UPwy
# DdOgggbQMIIGzDCCBLSgAwIBAgIKHtjtxQABAAABvjANBgkqhkiG9w0BAQsFADBH
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
# AQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRztEhkLUVZ
# 1U63MWSEgFcCzsWGwDANBgkqhkiG9w0BAQEFAASCAQCx5dvZdA07woFZxQZaWP9j
# NxkDWSYyWT49XOnhpCtXbTlorVzrqAo9bN00OnfBtnmeAwo8m1Rbcia1MYUy7XGv
# PpRSQsgPGUhf/eJb+boeaUBB7V7XOGn5zhVUdC5VNt5BlVsaPkkhdmP0IpYRUvVO
# 0Eaw+kiaeK8vB+2pFvWHfdGJFSYh/s14L+RAClV5o81mc7FqDpt/K8XR8skVGtct
# csJePfySbUGYLjBeuCC9W4GRhFgGEHkOZchGmfxD+VcN8LU6H7X4HWRWzLFLBZHX
# 0Cgt4jRhvAbjM7F+W/795XUXGhOfJEv3vmlVx9hTdRCEY8E1fAjH2UkJW/qYtYiA
# SIG # End signature block
