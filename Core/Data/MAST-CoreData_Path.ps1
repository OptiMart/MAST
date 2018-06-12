################################################################################
##                                                                            ##
##  Manage & Administrate Scripts - Tool (MAST)                               ##
##  Copyright (c) 2018 Martin Strobl                                          ##
##                                                                            ##
################################################################################

<#
.NOTES
    Autor: Martin Strobl
.SYNOPSIS
    Variable mit den Pfadangaben
.DESCRIPTION
    Die Variable $MASTPath beinhaltet alle Pfadangaben und wird im Profil geladen um dann
    überall zur Verfügung zu stehen
    Der PArameter $TempMASTBasePath (Rootpath für die Powershellverwaltung) muss uebergeben werden
#>

[CmdletBinding()]
param(
    # Name of the Path-Variable leave blank for default ($MASTPath)
    [Parameter()]
    [Alias("VarName","Name")]
    [string]
    $TempVarName = "MASTPath",

    # The Path to the MAST-Root leave Blank for default (..\..\)
    [Parameter(Position=0)]
    [Alias("MASTBasePath")]
    [string]
    $TempMASTBasePath = "$($PSScriptRoot | Split-Path -Parent | Split-Path -Parent)",

    # Switch to Force relaod of the Variable
    [switch] $Force
)

Write-Verbose "Lade Variable $TempVarName - Force: $Force"

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
        Base = $TempMASTBasePath
        Online = "\\ServerName\Share\ScriptRoot"      ## Der Root-Pfad zur Onlineumgebung (wird im Loader aktualisiert)
        Local = "$(Join-Path $env:HOMEDRIVE "MAST")"  ## Der Root-Pfad zur Offlineumgebung (wird im Loader aktualisiert)
        HKLM = "HKLM:\Software\MAST"                  ## Der Registrypfad zu den Computer Settings
        HKCU = "HKCU:\Software\MAST"                  ## Der Registrypfad zu den User Settings
        Logs = "$(Join-Path $TempMASTBasePath "Logs")"    ## Der Pfad zu den Logdateien
        Site = "$(try{                                ## Der Standortname laut Activedirectory
                    $($([System.DirectoryServices.ActiveDirectory.ActiveDirectorySite]::GetComputerSite()).Name)
                }catch [System.DirectoryServices.ActiveDirectory.ActiveDirectoryObjectNotFoundException]{
                    "no_Site"}
                catch {"disconnected"})"
    }

    ## Unterordner auf Ebene 1
    $TempVarMASTPathSub1 = @{
        Liv = "Live"                               ## Ordner für die Live-Umgebung
        Live = "Live"                              ## Ordner für die Live-Umgebung
        Dev = "Dev"                                ## Ordner für die Entwicklungsumgebung
        Bkp = "Archive"                            ## Ordner für das Archiv
        Rel = "Release"                            ## Ordner für die zu veröffentlichen Dateien
        Log = "Logs"                               ## Ordner für Logfiles
        Cor = "Core"                               ## Ordner mit den Corefiles
    }

    ## Unterordner auf Ebene 2
    $TempVarMASTPathSub2 = @{
        Env = ""                                   ## Wurzelverzeichnis
        Bin = "Bin"                                ## Ordner für Dateien mit direkt ausführbaren Code
        Cor = "Core"                               ## Ordner für Kern-Dateien
        #Dat = "Data"                               ## Ordner für Dateien mit Variablen
        Inc = "Includes"                           ## Ordner für Dateien die vom Loader gezielt geladen werden
        Lib = "Libs"                               ## Ordner für allgemeine Funktionen und Module
    }

    ## Erzeuge alle Pfadangaben und füge sie dem Objekt hinzu
    foreach ($Sub1 in $TempVarMASTPathSub1.GetEnumerator()) {
        $TempVarSub1 = New-Object psobject

        foreach ($Sub2 in $TempVarMASTPathSub2.GetEnumerator()) {
            $TempVarSub1 | Add-Member -MemberType NoteProperty -Name $Sub2.Name -Value (Join-Path (Join-Path $TempMASTBasePath $Sub1.Value) $Sub2.Value)
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
