function Update-PSDevModule {
<#
.Notes
	Name: Update-PSDevModule
	Autor: Martin Strobl
	Version History:
		19.07.2017 - Initial Release
.Synopsis
	Das ModulManifest des gewählten Moduls wird mit allen *.psm1 Files im Verzeichnis ergänzt
.Parameter Module
	Der Modulname im Efko Dev Verzeichnis
#>
	[CmdletBinding()]
	param()
    dynamicparam {
        $Name = 'Module'

        $Attribute = New-Object System.Management.Automation.ParameterAttribute
        $Attribute.Mandatory = $true
        $Attribute.Position = 0
        
        $ValidateItems = Get-ChildItem -Path (Join-Path $MASTPath.Dev.Env "Libs") -Include "*.psd1" -Recurse | Select-Object -Unique -ExpandProperty Name
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

		Write-Verbose "--- $($MyInvocation.MyCommand) - Begin - End"
	}
	process {
		Write-Verbose "--- $($MyInvocation.MyCommand) - Process - Start"
		
        $ModuleManifest = Get-ChildItem -Path (Join-Path $MASTPath.Dev.Env "Libs") -Include $PSBoundParameters.Module -Recurse -Force | Convert-Path
        $ModulePath = $ModuleManifest | Split-Path | Convert-Path
        
        $NestedPsm1 = @(Get-ChildItem -Path $ModulePath -Recurse -Include "*psm1" | Select-Object -Unique -ExpandProperty Name)
        $Functions = $NestedPsm1 -replace ".psm1$", ""

        Write-Verbose "$NestedPsm1"
        Write-Verbose "$Functions"

        Update-ModuleManifest -Path $ModuleManifest -NestedModules $NestedPsm1 -FunctionsToExport $Functions

		Write-Verbose "--- $($MyInvocation.MyCommand) - Process - End"
	}
	end {
		Write-Verbose "--- $($MyInvocation.MyCommand) - End - Start"
		
		Write-Verbose "--- $($MyInvocation.MyCommand) - End - End"
	}
}
