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


# SIG # Begin signature block
# MIIJXAYJKoZIhvcNAQcCoIIJTTCCCUkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUI5U1lrImu58wCpn08d35Tq4f
# BhWgggbQMIIGzDCCBLSgAwIBAgIKHtjtxQABAAABvjANBgkqhkiG9w0BAQsFADBH
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
# AQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQZnCiHbBp5
# d/v3NPfJbpbz6V0kETANBgkqhkiG9w0BAQEFAASCAQCs5sgpd21A5FAAhXlW5bgF
# /lvPmJR2zKWnaTY5jpmn+toeunB3zcvqGbS1aZYHaaguPsjl0prdijXhS2xcVSTE
# RG2JSFAB0/rwsGL2D+o5SOA8TyPxcn0MiQGfHxGUKUsSSS083v4m2myT4WqUYVOM
# wXWyEX28pLdJcMvA6PrYbTQDcFZowpP7xrxvFTzwy0E41E/ip8OlqkH6uAEGVfP6
# 04rHkHCCe28iDgJdow77wQsgUWr+Z8wrHfSmZOUb81kw4iKSHo88mpevi2x4yWqV
# tl8Cg9vaPDU0hEqYi970BI4hW0X5OMaGyl1Zps1/2LYycRPTSTVIVkzVYMaVh8Wh
# SIG # End signature block
