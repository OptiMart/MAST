function Load-PSScript {
<#
.NOTES
    Name: MAST-CoreFunc_Load-PSScript.ps1 
    Autor: Martin Strobl
    Version History:
    1.0 - 06.07.2017 - Initial Release.
    1.1 - 19.07.2017 - Umgebaut um Live und Dev Skripte und auch Module laden zu können
.SYNOPSIS
    Diese Funktion kann einfach mittels IntelliSense (Strg+Leertaste oder Tabulator) Skripte und Module nachladen
.DESCRIPTION
    Mit dieser Funktion können recht einfach alle Funktionen aus dem Libs Verzeichnis nachgeladen werden
    Dazu muss die Funktion per Dot-Sourcing (Vorangestellter . ) aufgerufen werden
    Bei dem Parameter FileName (Position 0) kann per IntelliSense Strg+Leertaste alle möglichen Dateien aufgelistet werden
#>
    [CmdletBinding(DefaultParameterSetName='LiveFunction')]
    param(
		[parameter(Mandatory=$true,ParameterSetName="AllLive",HelpMessage="Bestimmt ob alles geladen werden soll")]
		[parameter(Mandatory=$true,ParameterSetName="AllDev",HelpMessage="Bestimmt ob alles geladen werden soll")]
		[switch] $All,
		[parameter(Mandatory=$true,ParameterSetName="AllDev",HelpMessage="Bestimmt ob aus dem Dev-Verzeichnis geladen werden soll")]
		[switch] $Dev,
		[parameter(Mandatory=$false,ParameterSetName="AllLive",HelpMessage="Bestimmt ob alle Funktionen geladen werden sollen")]
		[parameter(Mandatory=$false,ParameterSetName="AllDev",HelpMessage="Bestimmt ob alle Funktionen geladen werden sollen")]
		[switch] $Function,
		[parameter(Mandatory=$false,ParameterSetName="AllLive",HelpMessage="Bestimmt ob alle Module geladen werden sollen")]
		[parameter(Mandatory=$false,ParameterSetName="AllDev",HelpMessage="Bestimmt ob alle Module geladen werden sollen")]
		[switch] $Module,
		[parameter(Mandatory=$false,ParameterSetName="AllLive",HelpMessage="Bestimmt ob alle Variablen geladen werden sollen")]
		[parameter(Mandatory=$false,ParameterSetName="AllDev",HelpMessage="Bestimmt ob alle Variablen geladen werden sollen")]
		[switch] $Variable,
		[parameter(Mandatory=$false,HelpMessage="Bestimmt ob alle Geladenen Funktionen zur UserFunctions hinzugefügt werden soll")]
		[switch] $AddUserFunctions,
        [parameter(Mandatory=$false,HelpMessage="Um das Modul/die Variable zwingend neu zu laden")]
		[switch] $Force
    )
    dynamicparam {
        ## Definiere die Parameter
        $MyParams = @(
            @{  Name = 'LiveFunction'
                Mandatory = $true
                Position = 0
                ParameterSetName = 'LiveFunction'
                ValidateItems = try{ Get-ChildItem -Path $MASTPath.Liv.Lib -Include "PS-Func*.ps1" -Recurse -Force -ErrorAction Stop | Select-Object -Unique -ExpandProperty Name }
                                catch { "kein Zugriff" }},
            @{  Name = 'DevFunction'
                Mandatory = $true
                Position = 0
                ParameterSetName = 'DevFunction'
                ValidateItems = try{ Get-ChildItem -Path $MASTPath.Dev.Lib -Include "PS-Func*.ps1" -Recurse -Force -ErrorAction Stop | Select-Object -Unique -ExpandProperty Name }
                                catch { "kein Zugriff" }},
            @{  Name = 'LiveModule'
                Mandatory = $true
                Position = 0
                ParameterSetName = 'LiveModule'
                ValidateItems = try { Get-ChildItem -Path $MASTPath.Liv.Lib -Include "*.psd1" -Recurse -Force -ErrorAction Stop | Select-Object -Unique -ExpandProperty Name }
                                catch { "kein Zugriff" }},
            @{  Name = 'DevModule'
                Mandatory = $true
                Position = 0
                ParameterSetName = 'DevModule'
                ValidateItems = try{ Get-ChildItem -Path $MASTPath.Dev.Lib -Include "*.psd1" -Recurse -Force -ErrorAction Stop | Select-Object -Unique -ExpandProperty Name }
                                catch { "kein Zugriff" }}
            @{  Name = 'LiveVariable'
                Mandatory = $true
                Position = 0
                ParameterSetName = 'LiveVariable'
                ValidateItems = try { Get-ChildItem -Path $MASTPath.Liv.Dat -Include "PS-Data*.ps1" -Recurse -Force -ErrorAction Stop | Select-Object -Unique -ExpandProperty Name }
                                catch { "kein Zugriff" }},
            @{  Name = 'DevVariable'
                Mandatory = $true
                Position = 0
                ParameterSetName = 'DevVariable'
                ValidateItems = try{ Get-ChildItem -Path $MASTPath.Dev.Dat -Include "PS-Data*.ps1" -Recurse -Force -ErrorAction Stop | Select-Object -Unique -ExpandProperty Name }
                                catch { "kein Zugriff" }}
        )


        ## Erzeuge das Rückgabe-Dictionary
        $RunTimeDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        foreach ($Param in $MyParams) {
            $Name = $Param.Name

            $Attribute = New-Object System.Management.Automation.ParameterAttribute
            $Attribute.Mandatory = $Param.Mandatory
            $Attribute.Position = $Param.Position
            $Attribute.ParameterSetName = $Param.ParameterSetName

            #$Alias = New-Object Alias(
            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($Param.ValidateItems)

            $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $AttributeCollection.Add($Attribute)
            $AttributeCollection.Add($ValidateSetAttribute)

            $RunTimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter($Name, [string], $AttributeCollection)

            $RunTimeDictionary.Add($Name, $RunTimeParam)
        }

        ## Übergib das Parameter Dictionary
        Return $RunTimeDictionary
    }
	begin {
		Write-Verbose "--- $($MyInvocation.MyCommand) - Begin - Start"

        ## Merke alle vorher zur Verfügung stehenden Funktionen
        $FuncPreLoad = Get-ChildItem Function:
        #$VarsPreLoad = Get-ChildItem Variable:

		Write-Verbose "--- $($MyInvocation.MyCommand) - Begin - End"
	}
    process {
        ## Initialisiere Variablen
        $LoadEnv = "Liv"
        $LoadCat = @("Lib")
		$LoadPath = @()
        $IncFunction = "----"
        $IncModule = "----"
        $IncVariable = "----"

        ## Je nach Parameterwahl wird der zu ladende Pfad und Filter ermittelt
        switch -Wildcard ($PSCmdlet.ParameterSetName) {
            "*Live*" {
                $LoadEnv = "Liv"
            }
            "*Dev*" {
                $LoadEnv = "Dev"
            }
            "*Function*" {
                $IncFunction = $PSBoundParameters[$PSCmdlet.ParameterSetName]
                $LoadCat += "Lib"
            }
            "*Module*" {
                $IncModule = $PSBoundParameters[$PSCmdlet.ParameterSetName]
                $LoadCat += "Lib"
            }
            "*Variable*" {
                $IncVariable = $PSBoundParameters[$PSCmdlet.ParameterSetName]
                $LoadCat += "Dat"
            }
            "*All*" {
                if ($Function) {
                    $IncFunction = "PS-Func*.ps1"
                    $LoadCat += "Lib"
                }
                if ($Module) {
                    $IncModule = "*.psd1"
                    $LoadCat += "Lib"
                }
                if ($Variable) {
                    $IncVariable = "PS-Data*.ps1"
                    $LoadCat += "Dat"
                }
            }
        }

        $LoadCat | %{
            $LoadPath += $MASTPath.$LoadEnv.$_
        }

        $LoadPath = $LoadPath  | Select-Object -Unique

        Write-Verbose "LoadPath: $LoadPath"
        Write-Verbose "IncFunction: $IncFunction"
        Write-Verbose "IncModule: $IncModule"
        Write-Verbose "IncVariable: $IncVariable"

        ## Es werden alle zu ladenden Objekte gesucht
        $LoadFunctions = @(Get-ChildItem -Path $LoadPath -Include $IncFunction -Recurse -Force -ErrorAction Ignore | Convert-Path)
        $LoadModules = @(Get-ChildItem -Path $LoadPath -Include $IncModule -Recurse -Force -ErrorAction Ignore | Split-Path | Convert-Path)
        $LoadVariables = @(Get-ChildItem -Path $LoadPath -Include $IncVariable -Recurse -Force -ErrorAction Ignore | Convert-Path)

        ## Lade die ausgewählten Funktionen
        foreach ($LoadFunction in $LoadFunctions) {
            Write-Verbose "Lade Funktion: $LoadFunction"
            . $LoadFunction
        }

        ## Lade die ausgewählten Module
        foreach ($LoadModule in $LoadModules) {
            Write-Verbose "Lade Modul: $LoadModule"
            Import-Module $LoadModule -Force:($Force -eq $true) -Verbose:($PSBoundParameters['Verbose'] -eq $true)
        }
        
        ## Lade die ausgewählten Variablen
        foreach ($LoadVariable in $LoadVariables) {
            Write-Verbose "Lade Variable: $LoadVariable"
            . $LoadVariable -Force:($Force -eq $true) -Verbose:($PSBoundParameters['Verbose'] -eq $true)
        }
    }
	end {
		Write-Verbose "--- $($MyInvocation.MyCommand) - End - Start"

        ## Vergleiche nach dem Laden des Skripts und füge die nun neu zur Verfügung stehenden Funktionen zum Array hinzu
        if ($AddUserFunctions) {
            $MASTUserFunctions += Get-ChildItem function: | Where-Object {$FuncPreLoad -notcontains $_} | Select-Object Name,Verb,Noun,@{Name="Source";Expression={"$($MyInvocation.MyCommand)"}}
    		## Problematisch wenn es nur innerhalb eines Skripts verwendet wird, dann wird trotzdem gleich für Show-UserFunction mitgeloggt ...
        }

		Write-Verbose "--- $($MyInvocation.MyCommand) - End - End"
	}
}

# SIG # Begin signature block
# MIIJXAYJKoZIhvcNAQcCoIIJTTCCCUkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU4SeZIfyQKnVEMazOxMVsFoOb
# xiegggbQMIIGzDCCBLSgAwIBAgIKHtjtxQABAAABvjANBgkqhkiG9w0BAQsFADBH
# MRUwEwYKCZImiZPyLGQBGRYFbG9jYWwxFDASBgoJkiaJk/IsZAEZFgRlZmtvMRgw
# FgYDVQQDEw9lZmtvLUVGLURDMDEtQ0EwHhcNMTgwMzIwMTA0MzQ5WhcNMjMwMzE5
# MTA0MzQ5WjCBpTELMAkGA1UEBhMCQVQxETAPBgNVBAcTCEVmZXJkaW5nMTAwLgYD
# VQQKEydlZmtvIEZyaXNjaGZydWNodCB1bmQgRGVsaWthdGVzc2VuIEdtYmgxCzAJ
# BgNVBAsTAklUMSUwIwYDVQQDExxlZmtvIFNvZnR3YXJlIFNpZ25hdHVyZSAyMDE4
# MR0wGwYJKoZIhvcNAQkBFg5vZmZpY2VAZWZrby5hdDCCASIwDQYJKoZIhvcNAQEB
# BQADggEPADCCAQoCggEBALSIKqvZr3MEiOKluy/263oXtSWrt84cu5FZheNJg4gE
# V0QqBhn+m8zPdz6cAMzKEN8nurPHnBBYIlJ81SVfC7z3zaaQ+NCU2H6yFS4S/dTw
# Q1PjFowXHzuobXri1yKCl3FAqwPi5JclFOkOxPEJVjF26xsiLeppLGkQSjCaMkrI
# I8tWIAlZ9VCW15P+unBliaIgHFNHUl3HzcahK5/U49F2d5mmF2U00vRMnVtxMGN/
# abH+DymrRxMryIB1/6aA7axnCsTpBjhv/ZqasQPOInDQVrLWD1QGCHxzv2hWjK4s
# BnBdnCDaw9ff/Kr8cKHGJN749Pv2LDPSe3MQGmWF6w8CAwEAAaOCAlkwggJVMDwG
# CSsGAQQBgjcVBwQvMC0GJSsGAQQBgjcVCITtkHzSvUOGyY8vgey0GIb2wXdxg936
# KoTujxYCAWQCASYwEwYDVR0lBAwwCgYIKwYBBQUHAwMwDgYDVR0PAQH/BAQDAgeA
# MBsGCSsGAQQBgjcVCgQOMAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFNymGh84qixJ
# 0PehgMf04u5NQMKOMB8GA1UdIwQYMBaAFPnoqPzz1G3G9BUtBop05S9cTbMSMIHP
# BgNVHR8EgccwgcQwgcGggb6ggbuGgbhsZGFwOi8vL0NOPWVma28tRUYtREMwMS1D
# QSgxKSxDTj1FRi1EQzAxLENOPUNEUCxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2aWNl
# cyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPWVma28sREM9bG9jYWw/
# Y2VydGlmaWNhdGVSZXZvY2F0aW9uTGlzdD9iYXNlP29iamVjdENsYXNzPWNSTERp
# c3RyaWJ1dGlvblBvaW50MIHABggrBgEFBQcBAQSBszCBsDCBrQYIKwYBBQUHMAKG
# gaBsZGFwOi8vL0NOPWVma28tRUYtREMwMS1DQSxDTj1BSUEsQ049UHVibGljJTIw
# S2V5JTIwU2VydmljZXMsQ049U2VydmljZXMsQ049Q29uZmlndXJhdGlvbixEQz1l
# ZmtvLERDPWxvY2FsP2NBQ2VydGlmaWNhdGU/YmFzZT9vYmplY3RDbGFzcz1jZXJ0
# aWZpY2F0aW9uQXV0aG9yaXR5MA0GCSqGSIb3DQEBCwUAA4ICAQAfidCB9iTuGnx/
# Gc00xhMBrFB6eoL0UHgF+T4oC7PkQWdb/Up4dfRqF0DQzazLfPnQdysmOWs/eahV
# 9gFu1lSY8bRJD6Jl2Fz5dHWtiR+FMw6stKkxq6+gGOa/NYX9KbZnxoJdRa1LgUi/
# /TT3jlw6Yc3KtYxX/rvmEnPji2soLkQf0oWpQ+hWTPl1dYUW/Tq3GbRmLkBx1phD
# P1Vfp9wqVWDKoSJOVntZWeEKFDqTL+3segSs2gzsjh0Zpe64mWCeIFlLw8JenZlF
# Lq5vmjr702rQ97RW3APOyNCM5hEjBrj+Ut9DHFQ8kKmA+R4ZhYNfUwViKZQ+Tp0+
# kPaJLDKLdPZIvzkUPAibkg1VktY/DRx4NC/+2BEEdQBVHAAzR7vq0Te+gV/yFvrs
# xf6D+rXq3K0HJs3mX3y6IaGBYsCh3ipb2xnr1twD282uB49u+wkVE8MIX8Bsmi66
# lhukxc32/5pNQvl9S4julzl5yE4ji5HjOvXPz2JqtaCZpxz19MzkFviAD73P9r2p
# Q+Bxxe4mjrb7ehJJJ0wxBIQvnj2bQFidTw+D8iw5TTp6Z0APR5AtPym43f250KdL
# j8VW4851JgkwhmEAOFQqreEhbSTbLD3B6LUNeY5IFRzSa+agOh57HGzlCY9bW/lo
# 6UjeSDZfG82TCf89Li1cv3HodsUp3jGCAfYwggHyAgEBMFUwRzEVMBMGCgmSJomT
# 8ixkARkWBWxvY2FsMRQwEgYKCZImiZPyLGQBGRYEZWZrbzEYMBYGA1UEAxMPZWZr
# by1FRi1EQzAxLUNBAgoe2O3FAAEAAAG+MAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3
# AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisG
# AQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTb0VweQbyg
# 7G77kCtUX2mZSxmObjANBgkqhkiG9w0BAQEFAASCAQCmzNQOJASKSt4NTt+AJXZl
# vCLcCtZ7qgXhKCdhKB6X2ULh/snPn+Gfbt7ciC0/Xmmr6tMm2qAObNl5pkpej1eA
# DJSVhl7kT5tc/gXnFR88zHlmGOPJ7CuXnXJ2zYsu2oo/Nuo55T6hOsVdbZleBhNi
# lpqooUUCZJI05L9cjaR6/PggqLd20C7375VU7Af+fAsuyLBvPbZ3s62HHwKBy2UN
# fxNkjYzdoBU42gjFsgER3E5ZbxIPUieWSVwEt7ko7XiekrMesACey6UVWdoksmEk
# sTp0yoNcaJUJvTXpIIhLzp80wTC+Ej5OxD1090TiGXKdqq79wmpMgA+bCDm31Gb/
# SIG # End signature block
