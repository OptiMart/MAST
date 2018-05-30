function Confirm-PSDevScripts {
<#
.SYNOPSIS
    Bestätigt/Signiert alle Skripte in dem gewünschten Bereich
.PARAMETER Release
    Hiermit werden die Skripte im Dev\Release-Verzeichnis signiert
.PARAMETER Live
    Hiermit werden die Skripte in den Live-Verzeichnisen signiert
.PARAMETER Dev
    Hiermit werden die Skripte im Dev\Entwicklung-Verzeichnis signiert
#>
    [CmdletBinding()]
    param(
        [switch] $Release,
        [switch] $Live,
        [switch] $Dev
    )
    begin {
        if ((-not $Release) -and (-not $Live) -and (-not $Dev)) {
            ## Wenn kein Bereich ausgewählt wurde dann wird die Funktion beendet
            Write-Verbose "Nichts ausgewählt, abbruch"
            break
        }

        .(Join-Path $PSScriptRoot "Set-CodeSignature.ps1")

        $SigPath = @()
        
        ## Füge die Pfade der ausgewählten Bereiche zum Array hinzu
        if ($Release) {
            $SigPath += $MASTPath.Rel.Env
        }

        if ($Live) {
            $SigPath += $MASTPath.Liv.Env
        }
        
        if ($Dev) {
            $SigPath += $MASTPath.Dev.Env
        }
    }
    process{
        Set-CodeSignature $SigPath -Verbose:($PSBoundPARAMETERs['Verbose'] -eq $true)
    }
}
