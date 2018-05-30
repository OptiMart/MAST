function Clear-PSLiveEnvironment {
<#
.NOTES
	Name: Clear-PSLiveEnvironment
	Autor: Martin Strobl
	Version History:
		20.07.2017 - Initial Release
.SYNOPSIS
	Bereinigt die Live-Umgebung (Abgleich mit Dev)
#>
	[CmdletBinding()]
	param(
        [switch] $Confirm
    )
	begin {
		Write-Verbose "--- $($MyInvocation.MyCommand) - Begin - Start"
		
        .(Join-Path $MASTPath.Liv.Lib "PS-Func_Copy-ItemsEfkoGroup")

		Write-Verbose "--- $($MyInvocation.MyCommand) - Begin - End"
	}
	process {
		Write-Verbose "--- $($MyInvocation.MyCommand) - Process - Start"
		
        $DevFiles = (Get-ChildItem $MASTPath.Dev.Env -Recurse -Force -File | Convert-Path) -replace [regex]::Escape($MASTPath.Dev.Env), $MASTPath.Liv.Env
        $LiveFiles = Get-ChildItem $MASTPath.Liv.Env -Recurse -Force -File | Convert-Path

        ## Ermittle die "extra"-Dateien die im Live-Verz vorhanden sind aber nicht mehr im Dev-Verz
        $ExtraFiles = $LiveFiles | Where-Object {$DevFiles -notcontains $_}
		
        Write-Debug "$ExtraFiles"
        Write-Verbose "Anzhal ExtraFiles: $(($ExtraFiles | Measure-Object).Count)"

        if (-not $Confirm -and ($ExtraFiles | Measure-Object).Count -gt 0) {
            Write-Host "Folgende Dateien sind im Live-Verzeichnis die nicht mehr im Dev-Verzeichnis vorhanden sind:"
            $ExtraFiles.Replace($MASTPath.Liv.Env, "") | Write-Host
            $Weiter = Read-Host -Prompt "Soll fortgefahren werden? (j)"
            if ($Weiter -notmatch "j") {
                break
            }
        }

        ## Den Backup-Präfix jetzt definieren um einen einheitlichen für den gesamten Vorgang zu erzeugen
        $BkpPrefix = "$(Get-Date -Format "yyyy-MM-dd-HH-mm-ss")_"

        foreach ($File in $ExtraFiles) {
            Write-Host "Verschiebe Datei in Backup: $File".Replace($MASTPath.Liv.Env, "")
            Write-Verbose "Von: $(Split-Path $File)"
            Write-Verbose "Nach: $((Split-Path $File) -replace [regex]::Escape($MASTPath.Liv.Env), $MASTPath.Bkp.Env )"

            ## Nutze die erweiterte Copy-ItemsEfkoGroup Funktion um die extra-Dateien in eine Backup zu VERSCHIEBEN
            Copy-ItemsEfkoGroup -PathSrc (Split-Path $File) -PathBkp ((Split-Path $File) -replace [regex]::Escape($MASTPath.Liv.Env), $MASTPath.Bkp.Env ) -FileFilter (Split-Path $File -Leaf) -DeleteSrc -BkpPrefix $BkpPrefix
        }

        ## Löschen der leeren Verzeichnise in den Basisordnern des Live-Verzeichnisses
        Get-ChildItem $MASTPath.Liv.Env -Force -Directory -Depth 1 | Where-Object { @(Get-ChildItem $_.FullName -Force).Count -eq 0 } | Remove-Item
        
        Write-Verbose "--- $($MyInvocation.MyCommand) - Process - End"
	}
}

