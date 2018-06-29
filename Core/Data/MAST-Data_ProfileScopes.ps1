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
.DESCRIPTION
#>

[CmdletBinding()]
param(
    # Name of the Path-Variable leave blank for default ($MASTPath)
    [Parameter()]
    [Alias("VarName","Name")]
    [string]
    $TempVarName = "MASTProfileScopes",

    # Switch to Force relaod of the Variable
    [switch] $Force
)

Write-Verbose "Lade Variable $TempVarName - Force: $Force"

## Aus Performacegründen werden diese Variablen nur einmalig erzeugt
if((Get-Variable -Name $TempVarName -ErrorAction Ignore) -eq $null -or $Force) {

#region -------------------------------------------- Parameter der Variable ---------------------------------------------------

    $TempVarScope = "global"
    $TempVarOption = [System.Management.Automation.ScopedItemOptions]::ReadOnly
    $TempVarDescription = "Variable mit den MAST Profilescopes"
    $TempVarVisibility = [System.Management.Automation.SessionStateEntryVisibility]::Public

#endregion ----------------------------------------- Parameter der Variable ---------------------------------------------------

#region ---------------------------------------------- Inhalt der Variable ----------------------------------------------------

    $TempVarValue = @{
        "AllUsersAllHosts" = "AllUsersAllHosts"
        "AllUsersCurrentHost" = "AllUsersCurrentHost"
        "CurrentUserAllHosts" = "CurrentUserAllHosts"
        "CurrentUserCurrentHost" = "CurrentUserCurrentHost"
        "RemoteProfile" = "RemoteProfile"
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
