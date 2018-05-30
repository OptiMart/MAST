function Update-AllOpenPSISEFiles {
<#
.NOTES
	Name: Update-AllOpenPSISEFiles
	Autor: viatstma
	Version History:
		12.07.2017 - Initial Release
.SYNOPSIS
	Eine Replace-Funktion für den ISE um Dateien zu öffnen und dann in allen offenen Dateien zu ersetzen
.PARAMETER SearchString
	Der Such-String ist REGEX-fähig
.PARAMETER ReplaceString
	Der neue String
.PARAMETER OpenDevFilesFilter
	Ein Filter um eventuell Dateien aus dem Dev-Verzeichnis zu öffnen
.EXAMPLE
	Update-AllOpenPSISEFiles "String1" "String1"
	Wenn der Suchstring gleich dem Replacestring ist, kann man es als Suchfunktion benutzen (Registerkarten mit * sind "geändert"
    und haben somit mindestens einen Treffer
.EXAMPLE
	Update-AllOpenPSISEFiles "String1" "String2" -OpenDevFilesFilter "*.ps1", "*.psm1"
	Wenn der Suchstring gleich dem Replacestring ist, kann man es als Suchfunktion benutzen (Registerkarten mit * sind "geändert"
    und haben somit mindestens einen Treffer
    Durch den OpenDevFilesFilter Parameter werden zuvor alle Skript-Dateien aus dem Dev-Verzeichnis geöffnet und dann gesucht
.EXAMPLE
	Update-AllOpenPSISEFiles "String1" "String2"
    So werden alle "String1" Vorkommnisse in allen offenen Dateien im ISE durch "String2" ersetzt.
    Die Dateien werden nicht automatisch gespeichert. Das muss dann noch händisch erledigt werden
#>
	[CmdletBinding()]
	param(
		[parameter(Mandatory=$true,Position=0,HelpMessage="Der zu suchende String")]
		[string] $SearchString,
        [parameter(Mandatory=$true,Position=1,HelpMessage="Der ersetzende String")]
		[string] $ReplaceString,
        [parameter(Mandatory=$false,HelpMessage="Welche Dateien im Editor geöffnet werden sollen")]
		[string[]] $OpenDevFilesFilter
	)
	begin {
		Write-Verbose "--- $($MyInvocation.MyCommand) - Begin - Start"

        if ($Host.Name -notlike "*ISE*") {
            Write-Warning "Diese Funktion kann nur im Powershell ISE Host verwendet werden"
            break
        }

        if ($OpenDevFilesFilter) {
            psedit @(Get-ChildItem $MASTPath.Dev.Env -Include $OpenDevFilesFilter -Recurse | Convert-Path)
        }
        
        $iFiles = 0
        $iMatch = 0

		Write-Verbose "--- $($MyInvocation.MyCommand) - Begin - End"
	}
	process {
		Write-Verbose "--- $($MyInvocation.MyCommand) - Process - Start"
		
        foreach ($PSTab in $psise.PowerShellTabs) {
            foreach ($PSFile in $PSTab.Files) {
                ## Zähle die Vorkomnisse des Suchstrings
                $iCount = [regex]::Matches($PSFile.Editor.Text, [regex]::Escape($SearchString)).Count
                
                Write-Verbose "$iCount gefunden in $($PSFile.DisplayName)"

                if ($iCount -gt 0) {
                    ## Erhöhe die Zähler
                    $iMatch += $iCount
                    $iFiles++

                    ## Ersetze die aktuellen Text durch den neuen mit den geänderten Strings
                    $PSFile.Editor.Text = $PSFile.Editor.Text -replace ([regex]::Escape($SearchString), $ReplaceString)
                }
            }
        }

		Write-Verbose "--- $($MyInvocation.MyCommand) - Process - End"
	}
	end {
		Write-Verbose "--- $($MyInvocation.MyCommand) - End - Start"
		
        Write-Host "Es wurde(n) $iMatch Vorkomnisse in $iFiles Datei(en) ersetzt" -ForegroundColor Green

		Write-Verbose "--- $($MyInvocation.MyCommand) - End - End"
	}
}
