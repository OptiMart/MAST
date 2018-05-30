﻿#Requires -Version 2.0
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
