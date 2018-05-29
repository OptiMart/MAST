function Test-MS17-010 {
    [reflection.assembly]::LoadWithPartialName("System.Version")
    $os = Get-WmiObject -class Win32_OperatingSystem
    $osName = $os.Caption
    $s = "%systemroot%\system32\drivers\srv.sys"
    $v = [System.Environment]::ExpandEnvironmentVariables($s)
    If (Test-Path "$v")
        {
        Try
            {
            $versionInfo = (Get-Item $v).VersionInfo
            $versionString = "$($versionInfo.FileMajorPart).$($versionInfo.FileMinorPart).$($versionInfo.FileBuildPart).$($versionInfo.FilePrivatePart)"
            $fileVersion = New-Object System.Version($versionString)
            }
        Catch
            {
            Write-Host "Unable to retrieve file version info, please verify vulnerability state manually." -ForegroundColor Yellow
            Return "Unable to retrieve file version info, please verify vulnerability state manually."
            }
        }
    Else
        {
        Write-Host "Srv.sys does not exist, please verify vulnerability state manually." -ForegroundColor Yellow
        Return "Srv.sys does not exist, please verify vulnerability state manually."
        }
    if ($osName.Contains("Vista") -or ($osName.Contains("2008") -and -not $osName.Contains("R2")))
        {
        if ($versionString.Split('.')[3][0] -eq "1")
            {
            $currentOS = "$osName GDR"
            $expectedVersion = New-Object System.Version("6.0.6002.19743")
            } 
        elseif ($versionString.Split('.')[3][0] -eq "2")
            {
            $currentOS = "$osName LDR"
            $expectedVersion = New-Object System.Version("6.0.6002.24067")
            }
        else
            {
            $currentOS = "$osName"
            $expectedVersion = New-Object System.Version("9.9.9999.99999")
            }
        }
    elseif ($osName.Contains("Windows 7") -or ($osName.Contains("2008 R2")))
        {
        $currentOS = "$osName LDR"
        $expectedVersion = New-Object System.Version("6.1.7601.23689")
        }
    elseif ($osName.Contains("Windows 8.1") -or $osName.Contains("2012 R2"))
        {
        $currentOS = "$osName LDR"
        $expectedVersion = New-Object System.Version("6.3.9600.18604")
        }
    elseif ($osName.Contains("Windows 8") -or $osName.Contains("2012"))
        {
        $currentOS = "$osName LDR"
        $expectedVersion = New-Object System.Version("6.2.9200.22099")
        }
    elseif ($osName.Contains("Windows 10"))
        {
        if ($os.BuildNumber -eq "10240")
            {
            $currentOS = "$osName TH1"
            $expectedVersion = New-Object System.Version("10.0.10240.17319")
            }
        elseif ($os.BuildNumber -eq "10586")
            {
            $currentOS = "$osName TH2"
            $expectedVersion = New-Object System.Version("10.0.10586.839")
            }
        elseif ($os.BuildNumber -eq "14393")
            {
            $currentOS = "$($osName) RS1"
            $expectedVersion = New-Object System.Version("10.0.14393.953")
            }
        elseif ($os.BuildNumber -eq "15063")
            {
            $currentOS = "$osName RS2"
            "No need to Patch. RS2 is released as patched. "
            return "No need to Patch. RS2 is released as patched. "
            }
        }
    elseif ($osName.Contains("2016"))
        {
        $currentOS = "$osName"
        $expectedVersion = New-Object System.Version("10.0.14393.953")
        }
    elseif ($osName.Contains("Windows XP"))
        {
        $currentOS = "$osName"
        $expectedVersion = New-Object System.Version("5.1.2600.7208")
        }
    elseif ($osName.Contains("Server 2003"))
        {
        $currentOS = "$osName"
        $expectedVersion = New-Object System.Version("5.2.3790.6021")
        }
    else
        {
        Write-Host "Unable to determine OS applicability, please verify vulnerability state manually." -ForegroundColor Yellow
        "Unable to determine OS applicability, please verify vulnerability state manually."
        $currentOS = "$osName"
        $expectedVersion = New-Object System.Version("9.9.9999.99999")
        }
    Write-Host "`n`nCurrent OS: $currentOS (Build Number $($os.BuildNumber))" -ForegroundColor Cyan
    Write-Host "`nExpected Version of srv.sys: $($expectedVersion.ToString())" -ForegroundColor Cyan
    Write-Host "`nActual Version of srv.sys: $($fileVersion.ToString())" -ForegroundColor Cyan
    If ($($fileVersion.CompareTo($expectedVersion)) -lt 0)
        {
        Write-Host "`n`n"
        Write-Host "System is NOT Patched" -ForegroundColor Red
        "System is NOT Patched"
        }
    Else
        {
        Write-Host "`n`n"
        Write-Host "System is Patched" -ForegroundColor Green
        "System is Patched"
        }
}

# SIG # Begin signature block
# MIIJXAYJKoZIhvcNAQcCoIIJTTCCCUkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUsUTgBoIGwcqCR6krGLp7i/N8
# /a+gggbQMIIGzDCCBLSgAwIBAgIKHtjtxQABAAABvjANBgkqhkiG9w0BAQsFADBH
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
# AQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQp9WPga/go
# 0nhxVv3rZgN4mJiI3DANBgkqhkiG9w0BAQEFAASCAQBcb5XrywwI5FMgOe2ohjWT
# jePEopuq1D7ONnFwXJlcO5SecVNCwAAaqmI8JyJcSv0VhHWv9ck9O5hN76C75qIy
# CQkRGxtWxHX/67cmUi3xrwQ1rORL0PjmGcja5prTa1hDcGfm88QpIo8gRBsHZAPh
# RqsRXe8tTn2v95ZWNvpECtRWozVAgvRNIk5vrvsZe6WXPLxlAIwseIPZ/x7i9Vex
# BQwObnicTV4wcYHYyL/7cve+S2OzKrpkR6YtMkxTRoVGipnQbqcmezx9rOUFvqtv
# y+3cj60zrVZI7dt3Z+VRzfvD8EKU/zD84DgDGW7WsLOoNaHM83jOzRU4qfFwfm5D
# SIG # End signature block
