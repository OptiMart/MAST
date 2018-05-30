function Restore-PSArchiveScripts {
<#
.NOTES
	Name: Restore-PSArchiveScripts
	Autor: viatstma
	Version History:
		05.09.2017 - Initial Release
.SYNOPSIS
	Stellt alle Skripte aus dem Archiv-Ordner mit dem gewünschten Zeitstempel wieder her
.PARAMETER FileFilter
	Parameter
.PARAMETER Rollback
	Parameter
#>
	[CmdletBinding()]
	param(
		[parameter(Mandatory=$false,Position=1,HelpMessage="Filter welche")]
		[string[]] $FileFilter = @("*.ps1","*.ps[dm]1")
	)
    dynamicparam {
        $Name = 'TimeStamp'

        $Attribute = New-Object System.Management.Automation.ParameterAttribute
        $Attribute.Mandatory = $true
        $Attribute.Position = 0
        
        $ValidateItems = Get-ChildItem -Path $MASTPath.Bkp.Env -Recurse -File | %{ Write-Output (Get-Date -Date "$($_.Name.Substring(0,10)) $($_.Name.Substring(11,5).Replace("-",":"))") } | Where-Object {$_ -ge (Get-Date).AddDays(-30)} | Sort-Object -Unique | %{ Get-Date -Date $_ -Format "yyyy-MM-dd HH:mm"}
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($ValidateItems)

        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $AttributeCollection.Add($Attribute)
        $AttributeCollection.Add($ValidateSetAttribute)

        $RunTimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter($Name, [string], $AttributeCollection)

        $RunTimeDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $RunTimeDictionary.Add($Name, $RunTimeParam)

        ## Übergib das Parameter Dictionary
        Return $RunTimeDictionary
    }
	begin {
		Write-Verbose "--- $($MyInvocation.MyCommand) - Begin - Start"
        
        ## Einbinden der Copy-ItemsEfkoGroup Funktion
		. (Join-Path $MASTPath.Liv.Lib "PS-Func_Copy-ItemsEfkoGroup.ps1")
        
        $temp = Get-Date -Date $($PSBoundParameters["TimeStamp"]) -Format "yyyy-MM-dd-HH-mm"
        Write-Debug $temp

        ## Den FileFilter anpassen (Zeitstempel voranstellen)
        $FileFilter = $FileFilter -replace "^", "$temp*"
        Write-Debug "$FileFilter"

		Write-Verbose "--- $($MyInvocation.MyCommand) - Begin - End"
	}
	process {
		Write-Verbose "--- $($MyInvocation.MyCommand) - Process - Start"

        ## Ermittle alle betroffenen Dateien
        $RestoreFiles = Get-ChildItem $MASTPath.Bkp.Env -Recurse -File -Include $FileFilter

        Write-Debug "$RestoreFiles"

        ## Den Backup-Präfix jetzt definieren um einen einheitlichen für den gesamten Vorgang zu erzeugen
        $BkpPrefix = "$(Get-Date -Format "yyyy-MM-dd-HH-mm-ss")_"

        $RestoreFiles | %{
            Write-Host "Verarbeite $($_.Name)"
            $SourcePath = $_.FullName
            $FileName = $_.Name.Remove(0,20)
            $LivePath = Join-Path ((Split-Path (Split-Path $_.FullName -Parent) -Parent) -replace [regex]::Escape($MASTPath.Bkp.Env), $MASTPath.Liv.Env) $FileName
            
            Write-Debug $SourcePath
            Write-Debug $FileName
            Write-Debug $LivePath
            
            Write-Verbose "Erzeuge Backup von aktueller Datei"
            Copy-ItemsEfkoGroup -PathSrc $MASTPath.Liv.Env -PathBkp $MASTPath.Bkp.Env -FileFilter $FileName -DeleteSrc -BkpPrefix $BkpPrefix -SendMail never -Verbose:($PSBoundPARAMETERs['Verbose'] -eq $true)

            Write-Verbose "Kopiere die Backupdatei in die Liveumgebung"
            Copy-Item -Path $SourcePath -Destination $LivePath -Force
        }

		Write-Verbose "--- $($MyInvocation.MyCommand) - Process - End"
	}
	end {
		Write-Verbose "--- $($MyInvocation.MyCommand) - End - Start"
		
		Write-Verbose "--- $($MyInvocation.MyCommand) - End - End"
	}
}
