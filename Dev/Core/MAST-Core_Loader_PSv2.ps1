#Requires -Version 2.0
<#
.NOTES
    Managing & Administrating Scripts - Tool (MAST)
    Name: PS-Core_LoaderPSv2.ps1 
    Autor: Martin Strobl
    Version History:
    1.0 - 12.04.2017 - Initial Release.
    1.1 - 02.05.2017 - Zusammenlegung aller profile in ein universelles Skript
        - 04.05.2017 - Automatisches hinzufügen des Modul-Pfads zur PS-Variable (deaktiviert aus Performacegründen am 30.06.2017)
    1.2 - 07.06.2017 - Nur mehr ein Profil pro Computer und alles wird gezielt nachgeladen
        - 05.07.2017 - Hinzufügen der Fehlerbehandlung ScriptRequiresException
        - 10.07.2017 - Anpassen der Allgemeinen Pfadvariablen für Entwicklungsumgebung
    1.3 - 24.07.2017 - Einen Offlinemodus eingeführt (Bei jeder instanz wird die lokale Kopie aktualisiert)
                       Die Anzeige beim Starten aufgeräumt (Console -> leer) (Schalter Admin-Help für Show-UserFunctions Info)
    1.4 - 09.08.2017 - Kompatibilität für mehrere zu ladende Profildateien um zB auch wieder Profildateien in CurrentUser zu verarbeiten
    1.5 - 10.08.2017 - Erweitert um auch als Remote-Profildatei geladen werden zu können
    2.0 - 31.08.2017 - Trennung von Lokaler profile.ps1 Datei und Loader-Datei
                       Ändern des Namens und der Variblanepräfixe auf MAST
                       Kernfunktionen fest einbinden
                       Möglichkeit zwischen Live und Dev-Umgebung zu entscheiden
.SYNOPSIS
    Dieses Skript ist der zentrale MAST-Loader für Powershell Version 2.0 und höher
.DESCRIPTION
    -) Es wird geprüft ob der Loader schon von anderer Stelle aufgerufen wurde
    -) Initialisieren der Umgebungsvariablen
        -) Pfadvariable $MASTPath mit allen Pfaden der Ordnerstruktur
        -) Array für geladene Benutzerfunktionen $MASTUserFunctions
    -) Anlegen einer aktuellen Offline-kopie
    -) Nachladen der Benutzerfunktionen je nach ProfilFilter-Einstellungen
        -) Ermitteln aller Kernfunktionen
        -) Ermitteln aller passenden Dateien aus dem Includes-Ordner
        -) Einbinden per Dot-Sourcing aller zutreffenden Dateien
        -) Ermitteln aller neu zur Verfügung stehenden Funktionen
    -) Ausgabe eventueller Zusatzinfos ($MASTAdminHelp/$MASTDebugLevel)
#>

#region ################################# ----- Versionsinformationen festlegen ----- #########################################

[uint32] $TempMASTLoaderVerMajor = 2
[uint32] $TempMASTLoaderVerMinor = 0
[uint32] $TempMASTLoaderVerBuild = ((Get-Item $MyInvocation.MyCommand.Path).LastWriteTime - (Get-Date 01.01.2017)).Days
[uint32] $TempMASTLoaderVerRevis = (Get-Item $MyInvocation.MyCommand.Path).LastWriteTime.TimeOfDay.TotalMinutes

$TempMASTLoaderVersion = New-Object version $TempMASTLoaderVerMajor, $TempMASTLoaderVerMinor, $TempMASTLoaderVerBuild, $TempMASTLoaderVerRevis

#endregion

#region ############################## ----- Prüfung auf schon gestarteten Loader ----- #######################################
if ($MASTLoaderVersion) {
    if ($TempMASTLoaderVersion -gt $MASTLoaderVersion) {
        Write-Host "Es existiert eine neuere Version des Loaders ($TempMASTProfileScope) v$TempMASTLoaderVersion" -ForegroundColor Yellow

        if ($Host.Name -notmatch "ISE") {
            return ## Wenn nicht in PSISE ausgeführt wird, wird immer abgebrochen
        }
        else {
            $TempMASTPopup = new-object -comobject wscript.shell
            if ($TempMASTPopup.popup("Es existiert eine neuere Version des Loaders ($TempMASTProfileScope) v$TempMASTLoaderVersion`r`nSoll diese nun nachgeladen werden?",3,"Zusätzlicher Loader",4) -ne 6) {
                return ## Wenn nicht rechtzeitig mit "Ja" bestätigt wird, wird abgebrochen
            }
        }
    }
    else {
        return ## Die aktuelle Version ist gleich oder älter als die schon geladene -> keine weiteres/erneutes laden nötig
    }
}
#endregion

#region ############################# ----- Initialisierung der Umgebungsvariablen ----- ######################################

## Laden der Pfadvariable $MASTBasePath
. (Join-Path (Split-Path $MyInvocation.MyCommand.Path) "MAST-CoreData_Path.ps1")

if ($MASTPath.Online -ne $TempMASTProfilePathOnline) {
    Write-Warning "Die Pfadvariable zur Online-Umgebung ist nicht konsistent"
    $MASTPath.Online = $TempMASTProfilePathOnline
}
if ($MASTPath.Local -ne $TempMASTProfilePathLocal) {
    Write-Warning "Die Pfadvariable zur Lokalen Umgebung ist nicht konsistent"
    $MASTPath.Local = $TempMASTProfilePathLocal
}

## Laden der Profilfiltervariable $MASTProfileFilter
. (Join-Path (Split-Path $MyInvocation.MyCommand.Path) "MAST-CoreData_ProfileFilter.ps1")

## Skriptvariablen als allgemeine PS-Variablen übernehmen
$MASTLoaderVersion = $TempMASTLoaderVersion
$MASTProfileScope = $TempMASTProfileScope

if (-not($MASTUserFunctions)) { $MASTUserFunctions = @() }       ## Array um alle geladenen Funktionen zu sammeln

$MASTAdminHelp = $false                                          ## Schalter um die Hilfsfunktionen und Infos zu aktivieren
$MASTDebugLevel = 0                                              ## Ein Regler um einen Debugmodus für verschiedene Szenarien zu verwenden
#endregion

#region ############################# ----- Starte robocopy des aktuellen LiveEnv ----- #######################################
if ($MASTIsOnline -and $TempMASTProfileScope -match "AllUsersAllHosts") {
    ## ToDo, Berechtigungsthemen überprüfen
    ## Löschen alter Strukturen
    Get-ChildItem $MASTPath.Local | Where-Object {$_.Name -ne "Live"} | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

    Start-Job -Name CopyLive -ArgumentList (Join-Path $MASTPath.Online "Live"), (Join-Path $MASTPath.Local "Live") -ScriptBlock {
        param($source, $destination)
        robocopy $source $destination /MIR
    } | Out-Null
}
#endregion

#region ############ ----- Laden der Profil-Filter und verarbeiten der zugeordneten Include-Dateien ----- #####################
Write-Host "Powershell $($PSVersionTable.PSVersion) | $($MyInvocation.MyCommand) [$MASTProfileScope] $MASTEnviron v$MASTLoaderVersion"

$TempMASTProfileFilter = $MASTProfileFilter | Where-Object {$_.InitScope -Match $MASTProfileScope -or $_.InitName -eq "Core"}
$TempMASTFilterCount = 0

foreach ($TempMASTFilter in $TempMASTProfileFilter) {

    ## Initialisiere die Pfade zu den Filtern
    if ($TempMASTFilter.InitName -eq "Core") {
        $TempMASTFilter.InitPath = $MASTPath.$MASTEnviron.Cor
    }
    else {
        $TempMASTFilter.InitPath = $MASTPath.$MASTEnviron.Inc
    }

    ## Ermitteln der Dateien
    try {
        $TempMASTFilter.InitFile = @(Get-ChildItem $TempMASTFilter.InitPath -Recurse -Force -Include $TempMASTFilter.InitIncl -ErrorAction Stop)
    }
    catch {
        Write-Host "Fehler beim Ermitteln der Dateien:" -ForegroundColor Red
        Write-Host "$($Error[0].Exception.Message)" -ForegroundColor Yellow
    }

    ## Laden der Dateien
    foreach ($TempMASTFile in $TempMASTFilter.InitFile) {
        ## Merke alle vorher zur Verfügung stehenden Funktionen
        $TempMASTFuncPreLoad = Get-ChildItem function:

        try {
            ## Lade die PS-File per Dot-Sourcing nach
            . $TempMASTFile.FullName
        }
        catch [System.Management.Automation.PSSecurityException] {
            Write-Host "$($TempMASTFile.FullName) - Keine gültige Signatur" -ForegroundColor Yellow
        }
        catch [System.Management.Automation.ScriptRequiresException] {
            switch ($Error[0].FullyQualifiedErrorId) {
                "ScriptRequiresElevation" { Write-Host "$($TempMASTFile.FullName) - kann nur in einer Sitzung mit erhöhten Rechten geladen werden" -ForegroundColor Yellow }
                "ScriptRequiresUnmatchedPSVersion" { Write-Host "$($TempMASTFile.FullName) - benötigt die PSVersion ($($($Error[0].Exception.RequiresPSVersion))) um geladen zu werden" -ForegroundColor Yellow }
                default { Write-Host "$($TempMASTFile.FullName) - kann aufgrund der ScriptRequiresException: $($Error[0].FullyQualifiedErrorId) nicht geladen werden" -ForegroundColor Yellow }
            }
        }
        catch {
            Write-Host "$($TempMASTFile.FullName) - $($Error[0].Exception.Message) $($Error[0].Exception)" -ForegroundColor Red
        }

        ## Vergleiche nach dem Laden des Skripts und füge die nun neu zur Verfügung stehenden Funktionen zum Array hinzu
        $MASTUserFunctions += Get-ChildItem function: | Where-Object {$TempMASTFuncPreLoad -notcontains $_} | 
            Select-Object Name,Verb,Noun,@{
                Name="Source";
                Expression={
                    if ($TempMASTFile.BaseName -match "^MAST-CoreFunc_") {"Kernfunktion"}
                    else {"$($TempMASTFile.BaseName)"}}}
    }
}
#endregion

#region ####################################### ----- Ausgabe Zusatzinfos ----- ###############################################

if ($MASTAdminHelp -or $Host.Name -match "ISE" -or $MASTProfileScope -match "RemoteProfile") {

    ## Ausgabe der geladenen Dateien pro Filter
    if ($Host.Name -match "ISE" -or $MASTProfileScope -match "RemoteProfile") {
        $MASTProfileFilter | Where-Object {$_.InitScope -Match $MASTProfileScope} | % {
            Write-Host "$($_.InitHead)" -ForegroundColor Black -BackgroundColor Green
            $_.InitFile | % {
                Write-Host "  [Including $($_.FullName -Replace [regex]::Escape($MASTPath.$MASTEnviron.Inc), "... " )]" -ForegroundColor Green
            }
        }
    }

    ## Anzahl geladener Funktionen ermitteln
    $TempMASTFuncAll = ($MASTUserFunctions | Select-Object -Unique Name | Measure-Object).Count
    $TempMASTFuncCore = ($MASTUserFunctions | Where-Object {$_.Source -match "Kernfunktion"} | Select-Object -Unique Name | Measure-Object).Count
    $TempMASTFuncUser = ($MASTUserFunctions | Where-Object {$_.Source -notmatch "Kernfunktion"} | Select-Object -Unique Name | Measure-Object).Count

    ## Infotext Ausgabe über die nachgeladenen Funktionen
    Write-Host "---------------------------------------------------------------------"
    Write-Host "Durch MAST bereitgestellte Funktionen: " -NoNewline -ForegroundColor Cyan
    Write-Host "$TempMASTFuncAll " -NoNewline -ForegroundColor Green
    Write-Host "(Kern: " -NoNewline -ForegroundColor Cyan
    Write-Host "$TempMASTFuncCore" -NoNewline -ForegroundColor Yellow
    Write-Host " User: " -NoNewline -ForegroundColor Cyan
    Write-Host "$TempMASTFuncUser" -NoNewline -ForegroundColor Yellow
    Write-Host ")" -ForegroundColor Cyan
    Write-Host "Diese können mit dem Befehl " -NoNewline -ForegroundColor Cyan
    Write-Host "Show-UserFunctions " -NoNewline -ForegroundColor Yellow
    Write-Host "aufgelistet werden" -ForegroundColor Cyan
}

if ($MASTDebugLevel -ge 1) {
    ## Überprüfe den Robocopy-Prozess
    $LiveCopyJob = @(Get-Job | Where-Object -Property Name -Like CopyLive)

    Write-Host "---------------------------------------------------------------------"
    Write-Host "Offlinekopie Vorgang: " -NoNewline -ForegroundColor Cyan

    if ($LiveCopyJob.Count -gt 0) {
        if ($LiveCopyJob[$LiveCopyJob.Count-1].State -eq [System.Management.Automation.JobState]::Completed) {
            Write-Host "beendet " -ForegroundColor Green

            if ($LiveCopyJob[$LiveCopyJob.Count-1].HasMoreData) {
                $LiveCopyJobData = Receive-Job $LiveCopyJob[$LiveCopyJob.Count-1]

                if ($LiveCopyJobData.Count -ge 7) {
                    for ($i=7;$i -ge 3;$i--) {
                        Write-Host $LiveCopyJobData[$LiveCopyJobData.Count-$i]
                    }
                }
                else {
                    Write-Host $LiveCopyJobData
                }
            }
            else {
                Write-Host "ohne weitere Daten"
            }
        }
        else {
            Write-Host "nicht beendet - Status: $($LiveCopyJob[$LiveCopyJob.Count-1].State)" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "nicht durchgeführt" -ForegroundColor Red
    }
}
#endregion

# SIG # Begin signature block
# MIIJXAYJKoZIhvcNAQcCoIIJTTCCCUkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUK8f9jT3riib3zro7yqGbaFAd
# oSygggbQMIIGzDCCBLSgAwIBAgIKHtjtxQABAAABvjANBgkqhkiG9w0BAQsFADBH
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
# AQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTML73TJXsu
# VgW8/6P3XsCIvWGOuDANBgkqhkiG9w0BAQEFAASCAQCapi0L80yc+plr6CwY4WcL
# oJRokTA6D2DUuRcaIkUhKk4jF8z84IbJxkAMklRSXaPNVofiMUeJwiIyE3f4w3HG
# RIDqJjw+taA39Ppw+nHAH0kS3JGXyGaTG41V6FUSqKyKmpv6sOEEkm2ZSjKCsoF8
# XAC5XMeZcdvFk05BeKm1cAZRDb1uI7b+spN9xVJ+MGVk1f4/Y8w+Hg0aiZxLUMbS
# V23De9hsn41ykVL7k0VhUctbQSme2I7VgUSZkNMDQD37Ao7D3+O9khng9JhvOODG
# riMuSoFFS8N9ACT1FXYY7A1cfTgL6zhIDeGTanfhhoRfL7gxXU5eDeJI1ik9ESOH
# SIG # End signature block
