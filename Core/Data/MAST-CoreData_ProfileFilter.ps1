################################################################################
##                                                                            ##
##  Manage & Administrate Scripts - Tool (MAST)                               ##
##  Copyright (c) 2018 Martin Strobl                                          ##
##                                                                            ##
################################################################################

<#
.NOTES
    Autor: Martin Strobl
    Die Variable $ProfileFilterData wird in den Core-Loader Dateien die bei jedem Start einer PS Sitzung geladen werden nachgeladen
    Hier werden die verschiedenen Zuordnungsbereiche in dem .\Includes Ordner angegeben
.SYNOPSIS
    Variable mit den Informationen für profile.ps1 Datei
.DESCRIPTION
    Es können "Objekte" mit folgenden Eigenschaften erstellt werden

    InitName
        Ein Name der diesen Bereich/Objekt definiert, wird im MAST-Loader verwendet um gezielt Core-Funktionen zu laden
    
    InitHead
        Der Anzeigetext der beim Laden ausgegeben wird

    InitIncl
        Der Dateinamensfilter für die Selektion der zu Inkludierenden/Nachzuladenden Dateien
        Dieser kann/muss mit Wildcards versehen werden und wird für den Parameter Include der Funktion get-childitems verwendet

    InitScope
        Hier kann hinterlegt werden in welcher Profil-Umgebung ($MASTProfileScope) dieses Filter-Objekt benutz wird
        Mehrfachnennungen möglich
#>

[CmdletBinding()]
param(
    # Name of the Path-Variable leave blank for default ($MASTPath)
    [Parameter()]
    [Alias("VarName","Name")]
    [string]
    $TempVarName = "MASTProfileFilter",

    # Switch to Force relaod of the Variable
    [switch] $Force
)

Write-Verbose "Lade Variable $TempVarName - Force: $Force"

## Aus Performacegründen werden diese Variablen nur einmalig erzeugt
if((Get-Variable -Name $TempVarName -ErrorAction SilentlyContinue) -eq $null -or $Force) {

#region -------------------------------------------- Parameter der Variable ---------------------------------------------------

    $TempVarScope = "global"
    $TempVarOption = [System.Management.Automation.ScopedItemOptions]::ReadOnly
    $TempVarDescription = "Variable mit den MAST Profilefilter Daten"
    $TempVarVisibility = [System.Management.Automation.SessionStateEntryVisibility]::Public

#endregion ----------------------------------------- Parameter der Variable ---------------------------------------------------

#region ---------------------------------------------- Inhalt der Variable ----------------------------------------------------

    $TempVarValue = @(
        @{
            InitName = "Core"
            InitHead = "  ---  Loading Core Scripts      ---  "
            InitIncl = "MAST-CoreFunc_*.ps1"
            InitScope = @("Core")
            InitFile = @()
            InitPath = @()
        },
        @{
            InitName = "Global"
            InitHead = "  ---  Loading Default Scripts   ---  "
            InitIncl = "PS_global_*.ps1"
            InitScope = @("AllUsersAllHosts","CurrentUserAllHosts","FunctionCall")
            InitFile = @()
            InitPath = @()
        },
        @{
            InitName = "Site"
            InitHead = "  ---  Loading Site Scripts      ---  $($MASTPath.Site)  "
            InitIncl = "PS_$($MASTPath.Site)_*.ps1"
            InitScope = @("AllUsersAllHosts","CurrentUserAllHosts")
            InitFile = @()
            InitPath = @()
        },
        @{
            InitName = "Groups"
            InitHead = "  ---  Loading Group Scripts     ---  $("$(try{"$((Get-ItemProperty -Path $MASTPath.HKCU -ErrorAction Ignore).Gruppen);$((Get-ItemProperty -Path $MASTPath.HKLM -ErrorAction Ignore).Gruppen)"}catch{})" -Split(";") -Split(",") | %{$_.trim(" ")})  "
            InitIncl = @("$(try{"$((Get-ItemProperty -Path $MASTPath.HKCU -ErrorAction Ignore).Gruppen);$((Get-ItemProperty -Path $MASTPath.HKLM -ErrorAction Ignore).Gruppen)"}catch{})" -Split(";") -Split(",") | %{ if ($_.Trim(" ") -gt 0) {"PS_$($_.Trim(" "))_*.ps1"} else {"---"} })
            InitScope = @("AllUsersAllHosts","CurrentUserAllHosts")
            InitFile = @()
            InitPath = @()
        },
        @{
            InitName = "Computer"
            InitHead = "  ---  Loading Computer Scripts  ---  $env:COMPUTERNAME  "
            InitIncl = "PS_$($env:COMPUTERNAME)_*.ps1"
            InitScope = @("AllUsersAllHosts","CurrentUserAllHosts")
            InitFile = @()
            InitPath = @()
        },
        @{
            InitName = "User"
            InitHead = "  ---  Loading User Scripts      ---  $env:USERNAME  "
            InitIncl = "PS_$($env:USERNAME)_*.ps1"
            InitScope = @("AllUsersAllHosts","CurrentUserAllHosts","FunctionCall")
            InitFile = @()
            InitPath = @()
        },
        @{
            InitName = "Remote"
            InitHead = "  ---  Loading Remote Scripts    ---  "
            InitIncl = "PS_remote_*.ps1"
            InitScope = @("RemoteProfile","n.A.")
            InitFile = @()
            InitPath = @()
        }
    ) | % { New-Object psobject -Property $_ }

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
