function New-PSDevModule {
<#
.Notes
	Name: New-EfkoModule
	Autor: Martin Strobl
	Version History:
		19.07.2017 - Initial Release
.Synopsis
	Erzeugt ein neues Modul im Dev-Pfad; Legt den Ordner und die Manifestdatei an
.Parameter ModuleName
	Parameter
#>
    [CmdletBinding()]
    param(
	    [parameter(Mandatory=$true,Position=0,HelpMessage="Der Modulname")]
	    [string] $ModuleName,
	    [parameter(Mandatory=$false,Position=1,HelpMessage="Der Name des Autors")]
	    [string] $Author = $env:USERNAME
    )
    begin {
	    Write-Verbose "--- $($MyInvocation.MyCommand) - Begin - Start"
	    
        ## Überprüfe ob dieses ModulManifest schon existiert
        if (Test-Path -Path (Join-Path $MASTPath.Dev.Env "Libs\$ModuleName\$ModuleName.psd1")) {
            Write-Warning "Dieses Modul ist schon angelegt"
            break
        }

	    Write-Verbose "--- $($MyInvocation.MyCommand) - Begin - End"
    }
    process {
	    Write-Verbose "--- $($MyInvocation.MyCommand) - Process - Start"
	    
        ## Der Modulname sollte mit efko_ beginnen
        if (-not ($ModuleName -match "^efko_")) {
            Write-Verbose "schelcht"
            $Antwort = Read-Host "Der Modulname beginnt nicht mit efko_. Soll trotzdem fortgefahren werden? [J]"
        }

        if ($ModuleName -match "^efko_" -or $Antwort -match "j") {
            ## Lege den Ordner im Dev-Verzeichnis an
            New-Item -Path (Join-Path $MASTPath.Dev.Env "Libs\$ModuleName") -ItemType Directory -Force | Out-Null
            
            ## Erzeuge die Manifestdatei
            New-ModuleManifest -Path (Join-Path $MASTPath.Dev.Env "Libs\$ModuleName\$ModuleName.psd1") -Author $Author -CompanyName "efko" -PowerShellVersion "3.0"
        }
	    Write-Verbose "--- $($MyInvocation.MyCommand) - Process - End"
    }
}