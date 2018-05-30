function Show-UserFunctions {
<#
.NOTES
	Name: Show-UserFunctions
	Autor: Martin Strobl
	Version History:
		14.08.2017 - Initial Release (Aus der Profile.ps1 ausgegliedert)
.SYNOPSIS
	Zeigt eine Übersicht über alle geladenen benutzerdefinierten Funktionen
.PARAMETER Filter
	Um die Funktionen nach Name filtern zu können
#>
	[CmdletBinding()]
	param(
		[parameter(Mandatory=$false,Position=0,HelpMessage="Ein Namensfilter")]
		[string] $Filter,
		[parameter(Mandatory=$false,HelpMessage="Ob Core-Functions auch angezeigt werden sollen")]
		[switch] $Core
	)
	process {
		Write-Verbose "--- $($MyInvocation.MyCommand) - Process - Start"
        
        $MASTUserFunctions | Sort-Object -Property Name -Unique | Where-Object { ($_.Name -match $Filter) -and ($Core -or ($_.Source -notmatch "Kernfunktion")) } | % {
            Write-Host "`r`n$($_.Name)" -ForegroundColor Cyan -NoNewline
            Write-Host " ($($_.Source))" -ForegroundColor Gray
            if (-not $($(Get-Help "$($_.Name)").Synopsis).startswith("$([char]13)$([char]10)")) {
                Write-Host "`t$($(Get-Help "$($_.Name)").Synopsis)"
            }
        }

		Write-Verbose "--- $($MyInvocation.MyCommand) - Process - End"
	}
}
