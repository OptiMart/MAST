<#
.NOTES
    Name: MAST-Local-Profile.ps1 
    Autor: Martin Strobl
    Version History:
    2.0 - 31.08.2017 - Trennung von Lokaler profile.ps1 Datei und Loader-Datei
          05.09.2017 - Popup für Auswahl Dev-Umgebung (Username = viatstma)
          08.05.2018 - Anpassung für Scope Development
                       Fehlerbehandlung bei $TempMASTLoader
.SYNOPSIS
    Dieses Skript wird an alle gewünschten Powershell Profil-Pfade verteilt um bei jedem Start das MAST zu laden
.DESCRIPTION
    Dieses Skript muss in einem der $profile Pfade abgelegt werden.
    Dadruch wird es dann bei jedem Sitzungsstart ausgeführt und versucht das Managing&Administrating Scripts-Tool (MAST) zu laden

    1) Definieren von Basispfaden zu (Online/Offline) Umgebung von MAST
    2) Ermitteln um welche Profildatei es sich handelt (woher wird geladen)
    3) Ermitteln ob eine Verbindung zum Online-Verzeichnis besteht
    4) Nachladen des eigentlichen MAST-Loaders (abhängig von der PS-Version)
    5) Aufräumarbeiten durchführen
#>

#region ################################### ----- Basisvariablen definieren ----- #############################################

    $TempMASTProfilePathOnline = "\\ServerName\Share\ScriptRoot"         ## Der Rootpath für die Powershellverwaltung
    $TempMASTProfilePathLocal = Join-Path $env:HOMEDRIVE "MAST"          ## Der Pfad zur Lokalen Livekopie
    ## Laden aus Registry

    New-Variable -Name MASTConstLive -Value "Live" -Option Constant
    New-Variable -Name MASTConstDev -Value "Dev" -Option Constant
    New-Variable -Name MASTConstAllUsersAllHosts -Value "AllUsersAllHosts" -Option Constant
    New-Variable -Name MASTConstAllUsersCurrentHost -Value "AllUsersCurrentHost" -Option Constant
    New-Variable -Name MASTConstCurrentUserAllHosts -Value "CurrentUserAllHosts" -Option Constant
    New-Variable -Name MASTConstCurrentUserCurrentHost -Value "CurrentUserCurrentHost" -Option Constant
    New-Variable -Name MASTConstRemoteProfile -Value "RemoteProfile" -Option Constant

    ## Defaultumgebung ist "Live"
    $MASTEnviron = "Live"

    ## Beliebige kriterien um zur Dev-Umgebung mittels 3Sek PopUp zu wechseln
    [bool] $TempMASTDevPopUp = ($env:USERNAME -match "MyUser")

    ## Beliebige kriterien um immer zur Dev-Umgebung zu wechseln
    [bool] $TempMASTDev = ($false)

    if ($TempMASTDevPopUp) {
        $TempMASTPopup = new-object -comobject wscript.shell
        if ($TempMASTPopup.popup("Laden der Dev-Umgebung?",3,"Dev",4) -eq 6) {
            $TempMASTDev = $true
        }
    }

    if ($TempMASTDev) {
        $MASTEnviron = "Dev"
    }

#endregion

#region ###################################### ----- Check Profile-Scope ----- ################################################

    switch ($MyInvocation.MyCommand.Path) {
        "$($profile.AllUsersAllHosts)" { $TempMASTProfileScope = "AllUsersAllHosts" }
        "$($profile.AllUsersCurrentHost)" { $TempMASTProfileScope = "AllUsersCurrentHost" }
        "$($profile.CurrentUserAllHosts)" { $TempMASTProfileScope = "CurrentUserAllHosts" }
        "$($profile.CurrentUserCurrentHost)" { $TempMASTProfileScope = "CurrentUserCurrentHost" }
        default { 
            if ( -not $profile -and $Host.Name -match "Remote" ) {
                $TempMASTProfileScope = "RemoteProfile"
            }
            else {
                if ($MASTEnviron -eq "Dev") {
                    $TempMASTProfileScope = "Development"
                }
                else {
                    $TempMASTProfileScope = "n.A."
                }
                Write-Warning "Die Profildatei wird von einem ungültigen Pfad aus gestartet"
            }
        }
    }

#endregion

#region ############################## ----- Check ob Online- oder Offlinebetrieb ----- #######################################

    if (Test-Path -Path (Join-Path $TempMASTProfilePathOnline $MASTEnviron)) {
        $MASTIsOnline = $true
        $MASTBasePath = $TempMASTProfilePathOnline
    }
    elseif (Test-Path -Path (Join-Path $TempMASTProfilePathLocal $MASTEnviron)) {
        Write-Host "   !!! Es besteht keine Verbindung zur Zentralen Skriptverwaltung - lade Offlinekopie !!!   " -BackgroundColor Cyan -ForegroundColor Black
        $MASTIsOnline = $false
        $MASTBasePath = $TempMASTProfilePathLocal
    }
    else {
        ## Wenn auch noch keine Offlinekopie besteht muss abgebrochen werden
        Write-Host "   !!! Es besteht keine Verbindung zur Zentralen Skriptverwaltung - Es konnte keine Offlinekopie gefunden werden !!!   " -BackgroundColor Red -ForegroundColor Yellow
        break
    }

#endregion

#region ######################################### ----- Starte Loader ----- ###################################################

    if ($MASTEnviron -eq "Dev" -or $TempMASTProfileScope -eq "Development") {
        $TempMASTLoader = "Core\MAST-Core_Loader_PSv5.ps1"
    }
    else {
        switch ($PSVersionTable.PSVersion) {
            ## Check welche PS Version um den Loader anzupassen
            #{$_ -ge [version]"5.1"} {$TempMASTLoader = "Core\MAST-Core_Loader_PSv5_1.ps1"; break} ## geplant den MAST-Loader als Klasse zu implementieren
            {$_ -ge [version]"4.0"} {$TempMASTLoader = "Core\MAST-Core_Loader_PSv4.ps1"; break}
            {$_ -ge [version]"2.0"} {$TempMASTLoader = "Core\MAST-Core_Loader_PSv2.ps1"; break}
            ## Unter Powershell Version 2.0 wird nicht geladen
            default {$TempMASTLoader = ""; break}
        }
    }

    ## Einbinden des Loaders
    if ($TempMASTLoader) {
        if (Test-Path -Path (Join-Path (Join-Path $MASTBasePath $MASTEnviron) $TempMASTLoader)) {
            . (Join-Path (Join-Path $MASTBasePath $MASTEnviron) $TempMASTLoader)
        }
        else {
            Write-Host "   !!! Der Loader konnte nicht unter ($(Join-Path (Join-Path $MASTBasePath $MASTEnviron) $TempMASTLoader)) gefunden werden !!!   " -BackgroundColor Red -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "   !!! Es konnte kein Loader ermittelt werden !!!   " -BackgroundColor Red -ForegroundColor Yellow
    }

#endregion

#region ########################################### ----- Aufräumen ----- #####################################################

    ## Progressbar abschließen, alle Temp-Variablen löschen und eine abschließende Leerzeile anfügen
    
    Write-Progress -Activity "*" -Completed
    Remove-Variable "TempMAST*"
    Write-Host

#endregion
