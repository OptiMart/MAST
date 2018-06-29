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
    Variable with default Text-Translations
.DESCRIPTION
    Variable is an Array of Hasttables like
        Lang ... Culturecode (en-us, de-de, it)
        Dict ... Hashtable with Tag => Text
#>

[CmdletBinding()]
param(
    # Name of the Path-Variable leave blank for default
    [Parameter()]
    [Alias("VarName","Name")]
    [string]
    $TempVarName = "TempMASTDictionaries",

    # Language Filter
    [Parameter()]
    [Alias("Language","Filter")]
    [string]
    $TempVarLanguage,

    # Switch to Force relaod of the Variable
    [switch] $Force
)

Write-Verbose "Lade Variable $TempVarName - Force: $Force"

## Aus Performacegründen werden diese Variablen nur einmalig erzeugt
if((Get-Variable -Name $TempVarName -ErrorAction Ignore) -eq $null -or $Force) {

#region -------------------------------------------- Parameter der Variable ---------------------------------------------------

    $TempVarScope = "local"
    $TempVarOption = [System.Management.Automation.ScopedItemOptions]::None
    $TempVarDescription = "Variable mit den MAST Dictionary Words"
    $TempVarVisibility = [System.Management.Automation.SessionStateEntryVisibility]::Public

#endregion ----------------------------------------- Parameter der Variable ---------------------------------------------------

#region ---------------------------------------------- Inhalt der Variable ----------------------------------------------------

    $TempVarValue = @(
        @{
            Lang = "en"
            Dict = @{
                "Yes" = "Yes"
                "No" = "No"
            }
        }
        @{
            Lang = "de"
            Dict = @{
                "Yes" = "Ja"
                "No" = "Nein"
            }
        }
    ) | Where-Object -Property Lang -Match $TempVarLanguage

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
