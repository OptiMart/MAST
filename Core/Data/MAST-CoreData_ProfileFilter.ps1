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
    $TempVarName = "MASTProfileFilter1",

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
            Name = "Core Classes"
            Header = "Core Classes"
            Priority = 0
            Pattern = "MAST-CoreFunc_*.ps1"
            Scope = @("Coreclass")
            InitName = "Core Classes"
            InitHead = "  ---  Loading Core Scripts      ---  "
            InitIncl = "MAST-CoreFunc_*.ps1"
            InitScope = @("Coreclass")
            
        },
        @{
            Name = "Core Functions"
            Header = "Core Functions"
            Priority = 1
            Pattern = "MAST-CoreClass_*.ps1"
            Scope = @("Core")
            InitName = "Core Functions"
            InitHead = "  ---  Loading Core Scripts      ---  "
            InitIncl = "MAST-CoreClass_*.ps1"
            InitScope = @("Core")
            
        },
        @{
            Name = "Global"
            Header = "Default Scripts"
            Priority = 10
            Pattern = "PS_global_*.ps1"
            Scope = @("AllUsersAllHosts","CurrentUserAllHosts","FunctionCall")
            InitName = "Global"
            InitHead = "  ---  Loading Default Scripts   ---  "
            InitIncl = "PS_global_*.ps1"
            InitScope = @("AllUsersAllHosts","CurrentUserAllHosts","FunctionCall")
        },
        @{
            Name = "Site"
            Header = "Site Scripts ($($MASTPath.Site))"
            Priority = 11
            Pattern = "PS_$($MASTPath.Site)_*.ps1"
            Scope = @("AllUsersAllHosts","CurrentUserAllHosts")
            InitName = "Site"
            InitHead = "  ---  Loading Site Scripts      ---  $($MASTPath.Site)  "
            InitIncl = "PS_$($MASTPath.Site)_*.ps1"
            InitScope = @("AllUsersAllHosts","CurrentUserAllHosts")
        },
        @{
            Name = "Groups"
            Header = "Group Scripts ($("$(try{"$((Get-ItemProperty -Path $MASTPath.HKCU -ErrorAction Ignore).Gruppen);$((Get-ItemProperty -Path $MASTPath.HKLM -ErrorAction Ignore).Gruppen)"}catch{})" -Split(";") -Split(",") | %{$_.trim(" ")}))"
            Priority = 20
            Pattern = @("$(try{"$((Get-ItemProperty -Path $MASTPath.HKCU -ErrorAction Ignore).Gruppen);$((Get-ItemProperty -Path $MASTPath.HKLM -ErrorAction Ignore).Gruppen)"}catch{})" -Split(";") -Split(",") | %{ if ($_.Trim(" ") -gt 0) {"PS_$($_.Trim(" "))_*.ps1"} else {"---"} })
            Scope = @("AllUsersAllHosts","CurrentUserAllHosts")
            InitName = "Groups"
            InitHead = "  ---  Loading Group Scripts     ---  $("$(try{"$((Get-ItemProperty -Path $MASTPath.HKCU -ErrorAction Ignore).Gruppen);$((Get-ItemProperty -Path $MASTPath.HKLM -ErrorAction Ignore).Gruppen)"}catch{})" -Split(";") -Split(",") | %{$_.trim(" ")})  "
            InitIncl = @("$(try{"$((Get-ItemProperty -Path $MASTPath.HKCU -ErrorAction Ignore).Gruppen);$((Get-ItemProperty -Path $MASTPath.HKLM -ErrorAction Ignore).Gruppen)"}catch{})" -Split(";") -Split(",") | %{ if ($_.Trim(" ") -gt 0) {"PS_$($_.Trim(" "))_*.ps1"} else {"---"} })
            InitScope = @("AllUsersAllHosts","CurrentUserAllHosts")
        },
        @{
            Name = "Computer"
            Header = "Computer Scripts"
            Priority = 21
            Pattern = "PS_$($env:COMPUTERNAME)_*.ps1"
            Scope = @("AllUsersAllHosts","CurrentUserAllHosts")
            InitName = "Computer"
            InitHead = "  ---  Loading Computer Scripts  ---  $env:COMPUTERNAME  "
            InitIncl = "PS_$($env:COMPUTERNAME)_*.ps1"
            InitScope = @("AllUsersAllHosts","CurrentUserAllHosts")
        },
        @{
            Name = "User"
            Header = "User Scripts"
            Priority = 22
            Pattern = "PS_$($env:USERNAME)_*.ps1"
            Scope = @("AllUsersAllHosts","CurrentUserAllHosts","FunctionCall")
            InitName = "User"
            InitHead = "  ---  Loading User Scripts      ---  $env:USERNAME  "
            InitIncl = "PS_$($env:USERNAME)_*.ps1"
            InitScope = @("AllUsersAllHosts","CurrentUserAllHosts","FunctionCall")
        },
        @{
            Name = "Remote"
            Header = "Remote Scripts"
            Priority = 100
            Pattern = "PS_remote_*.ps1"
            Scope = @("RemoteProfile","n.A.")
            InitName = "Remote"
            InitHead = "  ---  Loading Remote Scripts    ---  "
            InitIncl = "PS_remote_*.ps1"
            InitScope = @("RemoteProfile","n.A.")
        }
    ) | ForEach-Object -Process {
            $TempObj = New-Object psobject -Property $_
            $TempObj | Add-Member -MemberType NoteProperty -Name InitFile -Value @()
            $TempObj | Add-Member -MemberType NoteProperty -Name InitPath -Value @()
            $TempObj | Add-Member -MemberType NoteProperty -Name LoadFiles -Value @()
            $TempObj | Add-Member -MemberType NoteProperty -Name LoadPaths -Value @()
            Write-Output $TempObj
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
