function Add-PSGroup {
<#
.NOTES
	Name: Add-PSGroup
	Autor: Martin Strobl
	Version History:
		09.08.2017 - Initial Release
.SYNOPSIS
	Fügt den Computer oder den User zu der gewünschten PS-Gruppe hinzu
.PARAMETER Gruppe
	Name der Gruppe
.PARAMETER CurrentUser
	Mit diesem Schalter wird deie Gruppe dem aktuell angemeldeten User zugewisen
    Ohne diesen Parameter wird sie dem Computer zugewiesen
.EXAMPLE
	Add-PSGroup ScriptDev -CurrentUser
	Die Gruppe ScriptDev wird dem aktuellen User zugewiesen
.EXAMPLE
	Add-PSGroup CopyCSB
	Die Gruppe CopyCSB wird dem aktuellen Computer zugewiesen
#>
	[CmdletBinding(DefaultParameterSetName="ComputerScope")]
	param(
		[parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,HelpMessage="Der Name der Gruppe")]
		[string] $Gruppe,
        [parameter(Mandatory=$true,ParameterSetName="UserScope",HelpMessage="Der Name der Gruppe")]
        [switch] $CurrentUser
	)
    begin {
	    Write-Verbose "--- $($MyInvocation.MyCommand) - Begin - Start"
	    
        switch ($PSCmdlet.ParameterSetName) {
            "ComputerScope" {
                $Path = $MASTPath.HKLM
            }
            "UserScope" {
                $Path = $MASTPath.HKCU
            }
            default { return }
        }

        ## Falls der Schlüssel noch nicht existiert, wird er angelegt
        if (-not (Test-Path -Path $Path)) {
            New-Item $Path -Force | Out-Null
        }

	    Write-Verbose "--- $($MyInvocation.MyCommand) - Begin - End"
    }
	process {
		Write-Verbose "--- $($MyInvocation.MyCommand) - Process - Start"
		
        ## Versuche die schon aktuell zugewiesenen Gruppen zu laden
        try {
            [string[]] $Gruppen = @((Get-ItemProperty -Path $Path -ErrorAction Stop).Gruppen)
        }
        catch {
            New-ItemProperty -Path $Path -Name Gruppen | Out-Null
            [string[]] $Gruppen = ""
        }

        $Gruppen = $Gruppen.Split(";").Split(",",[System.StringSplitOptions]::RemoveEmptyEntries)
        $Gruppen = ($Gruppen + $Gruppe) | Sort-Object -Unique

        Set-ItemProperty -Path $Path -Name Gruppen -Value ($Gruppen -join ";") | Out-Null

		Write-Verbose "--- $($MyInvocation.MyCommand) - Process - End"
	}
}
