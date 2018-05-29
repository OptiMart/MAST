function Submit-PSDevScripts {
<#
.SYNOPSIS
    Kopiert die gewünschten Skripte aufgrund ihres Änderungsdatums aus der Entwicklungsumgebung in die Release-Umgebung
.DESCRIPTION
    Wenn die Funktion ohne parameter aufgerufen wird, werden alle Dateien im Entwicklungsverzeichnis mit denen im Live-Verzeichnis verglichen
    und nur jene die neuer sind in das Release-Verzeichnis kopiert
.PARAMETER Days
    Selektiert alle Dateien die vor weniger als Days Tage geändert wurden
.PARAMETER Hours
    Selektiert alle Dateien die vor weniger als Hours Stunden geändert wurden
.PARAMETER Date
    Selektiert alle Dateien die ein jünderes Änderungsdatum haben sind als dieses Datum/Zeit
.PARAMETER Inclue
    Filter für den kopierprozess
#>
    [CmdletBinding(DefaultParameterSetName="Compare")]
    param(
        [parameter(Mandatory=$true,ParameterSetName="Days",HelpMessage="Selektiert alle Dateien die vor weniger als Days Tage geändert wurden")]
        [uint32] $Days,
        [parameter(Mandatory=$true,ParameterSetName="Hours",HelpMessage="Selektiert alle Dateien die vor weniger als Hours Stunden geändert wurden")]
        [uint32] $Hours,
        [parameter(Mandatory=$true,ParameterSetName="Date",HelpMessage="Selektiert alle Dateien die ein jünderes Änderungsdatum haben sind als dieses Datum/Zeit")]
        [ValidateScript({try{get-date $_;$true}catch{$false}})]
        [string] $Date,
        [parameter(Mandatory=$false,HelpMessage = "Filter welche Dateien verarbeitet werden sollen")]
        [string[]] $Include = @("*.ps1","*.psm1","*.psd1","*.xml")
    )
    process {
		Write-Verbose "--- $($MyInvocation.MyCommand) - Process - Start"

        Write-Verbose "ParameterSet: $($PSCmdlet.ParameterSetName)"
        
        ## Je nachdem welche Parameter übergeben wurde werden verschiedene Methoden verwendet um die relevanten Dateien zu ermitteln
        switch ($PSCmdlet.ParameterSetName) {
            "Compare" {
                $Files = @(Get-ChildItem $MASTPath.Dev.Env -Recurse -Include $Include | Where-Object {
                    $_.LastWriteTime -gt $( try{ $(Get-Item ("$($_.FullName)".Replace($MASTPath.Dev.Env, $MASTPath.Liv.Env)) -ErrorAction Stop).LastWriteTime } catch { Get-Date -Date 01.01.1900 } )
                } )
            }
            "Days" {
                $Files = @(Get-ChildItem $MASTPath.Dev.Env -Recurse -Include $Include | Where-Object {
                    $_.LastWriteTime -gt (Get-Date).AddDays($Days*-1) })
            }
            "Hours" {
                $Files = @(Get-ChildItem $MASTPath.Dev.Env -Recurse -Include $Include | Where-Object {
                    $_.LastWriteTime -gt (Get-Date).AddHours($Hours*-1) })
            }
            "Date" {
                $Files = @(Get-ChildItem $MASTPath.Dev.Env -Recurse -Include $Include | Where-Object {
                    $_.LastWriteTime -gt (Get-Date -Date $Date) })
            }
        }
        
        Write-Verbose "$($Files.Count) Dateien gefunden"

        ## Verarbeite alle gefundenen Dateien
        foreach ($File in $Files) {
            Write-Verbose "Kopiere $File"

            $FileNew = "$($File.FullName)".Replace($MASTPath.Dev.Env, $MASTPath.Rel.Env)

            if (-not (Test-Path (Split-Path $FileNew))) {
                ## Falls das Verzeichnis noch nicht existiert wird es erstellt
                New-Item -Path (Split-Path $FileNew) -ItemType Directory -Force | Out-Null
            }

            ## Kopiere die Datei aus dem Entwicklungsordner in das Release Verzeichnis
            Copy-Item -Path $File -Destination $FileNew -Force
            Write-Host "Bereitgestellt: $FileNew".Replace($MASTPath.Rel.Env, "")
        }
        
        Write-Host "$($Files.Count) Datei(en) bereit zum genehmigen/veröffentlichen" -ForegroundColor Magenta

        Write-Verbose "--- $($MyInvocation.MyCommand) - Process - End"
    }
}

# SIG # Begin signature block
# MIIJXAYJKoZIhvcNAQcCoIIJTTCCCUkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUzj/kurjSi8Eagcn6xF7TrsJJ
# tJSgggbQMIIGzDCCBLSgAwIBAgIKHtjtxQABAAABvjANBgkqhkiG9w0BAQsFADBH
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
# AQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQC4LckgUhB
# +7+WPkuoF0CDTyfbojANBgkqhkiG9w0BAQEFAASCAQBaQFIy22Wx7Mbnnib6MfnY
# RheNoTzBx15Qjdq1Siw7wQyeJvoPxw845Yg4Ixs40UNS6bCoyETCGd41AdTpYkjP
# VolS3v6GIjB3pLSKKYP0xXTA2y5Fu6CgCG6QAo5fIESl8GHf8EQlzz06k256tiwv
# bVpOMwVNVT0psQ3NYyc6CyH4kgc4FG65l2n0MVSg9w29KfPafnvbEF6HOB/7ayqs
# FvhD5ksyQfdiO6EVGQu8gphX62KuiGD5rjoXWeDEGofof7kf/faL0FaMf2k1nvB+
# QNMugVfk21Ns5blT369NwSpaJflusTSEtryciLpF98ZEzPUgZfC6pYTh0IINsKY0
# SIG # End signature block
