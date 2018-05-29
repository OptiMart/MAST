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

# SIG # Begin signature block
# MIIJXAYJKoZIhvcNAQcCoIIJTTCCCUkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUPcmZVI11w570ifanU5luD7Pv
# R+OgggbQMIIGzDCCBLSgAwIBAgIKHtjtxQABAAABvjANBgkqhkiG9w0BAQsFADBH
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
# AQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBR0U+ZtyB6V
# qhW2guzkCEZxZJeFrDANBgkqhkiG9w0BAQEFAASCAQCu1l0mgSCWdeze+76yvObY
# 4TywEAf9NzhxVQwuOnunz9sudYNkPMORplZ4yzIrwlriUEzRofJBFJvxPGHxfQR9
# Bnn7dEe/FSlNYrf6B5jzhPrSLrJaAfBzYjKoVIjvvQ5mu9ihLoKHe2dGwO2xt21I
# +XsfBWxM6mWSeO5jA+73/C7m8vzCB8YAy8qegPHmVQN7I0tMYnxHrD1R35VUpXN6
# oJTCW2nfjupfNkfzdtDfXdwmXDvn5GuV1zbslCG8ehFAdxytUIx6VbgFr0aihgyk
# VKsc5os9zjriUwMprsYoWvaO/KE2bpoUJTl1qWiHH8ehoYRrHJhi2Rn4SYD4KOti
# SIG # End signature block
