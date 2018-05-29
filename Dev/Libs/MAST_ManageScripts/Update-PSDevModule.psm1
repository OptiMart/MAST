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

# SIG # Begin signature block
# MIIJXAYJKoZIhvcNAQcCoIIJTTCCCUkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUmmYPyp32bY0LWFOb0B7gY9b5
# GAOgggbQMIIGzDCCBLSgAwIBAgIKHtjtxQABAAABvjANBgkqhkiG9w0BAQsFADBH
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
# AQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRUSHuErxQ7
# UFB4scgSTC88l9yrcjANBgkqhkiG9w0BAQEFAASCAQBN5wz9QH1RURJOj6s8WnS7
# kDBdispuxbiDWQVxe2nIxtDEOK26eGn5YHTEkFN/az2p83qiirZ+U9xqQ3JTEgZb
# ZrIEix8oAE07rfyVIo9hohrAWaUh6M6Hy6yajDipPZ59i9CmRDJZ+IhABx7Stboe
# 5hCuuVPyqwLcAb/X8YvgJpSU4OBmEzG0dnTqtr04zfagpeMvRQEpHc5Yw4q7hFGP
# Le4yjIGnWZ/qe2NZy7AlXGnmNRwSy3eB2NUfh67GbdtHfK6oRNqwUEaqVlcwB64v
# FANzGzyfTbxuf2NzF3aRvKNKyEqKjheQqSVJikbkHSvX3BNdARSkHDKtQabnJ+JP
# SIG # End signature block
