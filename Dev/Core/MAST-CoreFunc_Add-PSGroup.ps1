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

# SIG # Begin signature block
# MIIJXAYJKoZIhvcNAQcCoIIJTTCCCUkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUWein9heDeyFyqcfoFpl/twJg
# xSigggbQMIIGzDCCBLSgAwIBAgIKHtjtxQABAAABvjANBgkqhkiG9w0BAQsFADBH
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
# AQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBS7PztRaQo9
# nr0cjR0/l8bQviYvNDANBgkqhkiG9w0BAQEFAASCAQBMq1UrA/p/de/Q/Qi8B5pO
# 3NWii9VvZy0A9cuXz5wKcNvks4T1wypAkIirzlKi/yeJiGmKhf5jmELOH1qBnZ+P
# vgE4FwusLbFqX+JHi8lLMfxj8XGP+9n2NN4TofOABoiX03GHWL8FAI+VEaIsiO7Y
# P9AZJXQRRDeF4WGkGigmLEr5xP2qb2ZimvAdpovAm9aCAHzrklhgaujGWtwTbpfH
# GmCmsQSaRL42lI3xGbvnCQBZPw9L5sBP7W5XEnGRauwX2yZVg1fZ8Vbbp3do6zdW
# qSX7U7C+fcqADN35tuBCGTIrEdb+nIe2F4o5ggSlycT5e+ecipSfN+F+0dlzXjyM
# SIG # End signature block
