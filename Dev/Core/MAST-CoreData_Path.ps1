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
