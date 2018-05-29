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

# SIG # Begin signature block
# MIIJXAYJKoZIhvcNAQcCoIIJTTCCCUkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUanqIsfdi4QajVcyd/DG7FAFw
# kKqgggbQMIIGzDCCBLSgAwIBAgIKHtjtxQABAAABvjANBgkqhkiG9w0BAQsFADBH
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
# AQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBT3Lb9i2lau
# nYD77TqEzBJazq92MjANBgkqhkiG9w0BAQEFAASCAQBdaKnCAaB9KD+1T4Vq12Ww
# edDeKrpXs9QKvQCWaLLhyIqnRJIVGedbG9aUSOHRoCo7eeWhicHvvkPPV4F71Q5V
# j24x7eLYnfKTk/+Q1pfmeA67HoN3NxmeGn+aWPmgejKIoUnatqRTuKp4JEcUluPt
# In0g155uLcZrzS8ed38VaXzvs/V6rzcKY/WXHmsN7s8CXY6eolzU7pxw9HpVMwCG
# ZINKJ3LTnB96QGworZkg/WJyU+q5vhN84zKrFkVS3CLwc0hmbj6INpPlePFrUJpW
# T5UFj65zVyiofQrRtWDZkoWTvFT5HhEj1tvsV7OEbDQgtnD1nrhVZJaliIpmQ8vq
# SIG # End signature block
