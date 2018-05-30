function Get-PSScriptInformation {
<#
.NOTES
	Name: Get-PSScriptInformation
	Autor: Martin Strobl
	Version History:
		27.07.2017 - Initial Release
.SYNOPSIS
	Liefert Informationen über alle Funktionen die mit Load-PSScript -All -Function -Module geladen werden
#>
	[CmdletBinding(DefaultParameterSetName='All')]
	param()
	process {
		Write-Verbose "--- $($MyInvocation.MyCommand) - Process - Start"

        ## Lade die Lade-Funktion nach, damit alle durch sie geladenen Funktionen im richtigen Bereich (Scope) sind
        . (Join-Path $MASTPath.Liv.Cor "MAST-CoreFunc_Load-PSScript.ps1")
		
        ## Lade alle Skripte und Module aus dem Libs Verzeichnis nach
        . Load-PSScript -All -Function -Module -Verbose:($PSBoundParameters['Verbose'] -eq $true)

        ## Vergleiche nach dem Laden des Skripts und füge die nun neu zur Verfügung stehenden Funktionen zum Array hinzu
        $MyScope = $MyInvocation.MyCommand
        $AllUserFunctions = Get-ChildItem function: | Where-Object {$_.Source -match "efko_" -or $_.Source -like "$MyScope" }
        
        $AllFunctionInfo = @()

        ## Füge die Funktionshilfe hinzu
        foreach ($myFunction in $AllUserFunctions) {
            $FuncInfo = New-Object System.Object
            $FuncHelp = Get-Help $myFunction

            $FuncInfo | Add-Member -MemberType NoteProperty -Name Name -Value $myFunction.Name
            $FuncInfo | Add-Member -MemberType NoteProperty -Name Verb -Value $myFunction.Verb
            $FuncInfo | Add-Member -MemberType NoteProperty -Name Noun -Value $myFunction.Noun
            $FuncInfo | Add-Member -MemberType NoteProperty -Name Module -Value $(if ($myFunction.ModuleName -like "$MyScope") {$null} else {$myFunction.Module})
            $FuncInfo | Add-Member -MemberType NoteProperty -Name ModuleName -Value $(if ($myFunction.ModuleName -like "$MyScope") {$null} else {$myFunction.ModuleName})
            $FuncInfo | Add-Member -MemberType NoteProperty -Name Parameters -Value @(if ($FuncHelp.Parameters) { $FuncHelp.Parameters.parameter } )
            $FuncInfo | Add-Member -MemberType NoteProperty -Name Synopsis -Value $FuncHelp.Synopsis
            $FuncInfo | Add-Member -MemberType NoteProperty -Name description -Value $FuncHelp.Description.Text
            $AllFunctionInfo += $FuncInfo
        }

        Write-Output $AllFunctionInfo

        Write-Warning "Durch das Ausführen dieser Funktion entstehen Inkosistenzennz bei den geladenen Userfunktionen (Show-Userfunction)"

		Write-Verbose "--- $($MyInvocation.MyCommand) - Process - End"
	}
}
