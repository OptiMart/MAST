<#Enum MASTLog {
    Log = 0      ## Wird nur in dem Ziel-Log gespeichert
    Info = 1     ## Wird zusätzlich in dem Globlane Standort-Log gespeichert
    Error = 2    ## Wird zusätzlich in dem Globalen Log gespeichert
}#>

function Write-LogData {
<#
.NOTES
	Name: Write-MASTLogData
	Autor: viatstma
	Version History:
		14.09.2017 - Initial Release
.SYNOPSIS
	Schreibt Logdaten fort
.DESCRIPTION
	Langtext Beschreibung
.PARAMETER Data
	Die Log-Daten
.PARAMETER User
	Es wird in ein Benutzerbezogenes Logfile geschrieben
.PARAMETER Severity
	Welche Gewichtung haben die Log-Daten
.PARAMETER TimeStamp
	Hier kann ein benutzerdefinierter Zeitstempel übergeben werden
#>
	[CmdletBinding(DefaultParameterSetName='MachineLog')]
	param(
		[parameter(Mandatory=$true,Position=0,HelpMessage="Die Log-Daten")]
		[string[]] $Data,
        [parameter(Mandatory=$true,ParameterSetName='UserLog',HelpMessage="Es wird in ein Benutzerbezogenes Logfile geschrieben")]
		[switch] $User,
        [parameter(Mandatory=$false,ParameterSetName='UserLog',HelpMessage="Es kann der UserName für das LogFile.log geändert werden")]
		[string] $UserLogFile,
        [parameter(Mandatory=$false,HelpMessage="Es kann der HostName für das LogFile.log geändert werden")]
		[string] $HostLogFile,
        [parameter(Mandatory=$false,HelpMessage="Welche Gewichtung haben die Log-Daten")]
        [uint32] $Severity = 0,
        [parameter(Mandatory=$false,HelpMessage="Hier kann ein benutzerdefinierter Zeitstempel übergeben werden")]
        [datetime] $TimeStamp = (Get-Date)
	)
	begin {
		Write-Verbose "--- $($MyInvocation.MyCommand) - Begin - Start"
		
        ## Initialisieren
        $LogHost = $env:COMPUTERNAME
        $LogClient = $env:COMPUTERNAME
        $LogUser = $env:USERNAME
        $LogSite = $MASTPath.Site
        $LogTime = (Get-Date $TimeStamp -Format "yyyy-MM-dd HH:mm:ss")
        $LogPath = @()
        $LogData = @()

        try {		
            ## Lade das RemoteDesktop Modul
            Import-Module (Join-Path $MASTPath.Liv.Lib "PSTerminalServices") -ErrorAction Stop | Out-Null

            ## Versuche den Clientnamen zu ermitteln
            $RDSClient = (Get-TSCurrentSession).ClientName
            Write-Verbose "RDS-ClientName: $LogClient"

            ## Wenn einer gefunden wurde, dann wird mit diesem gearbeitet
            if ($RDSClient) {
                Write-Verbose "Length: $($LogClient.length)"
                $LogClient = $RDSClient
            }
        }
        catch {
            ## Bei Fheler fahre mit den Standardsetings fort
        }

        ## Festlegen des Namens der UserLogFile
        if ($UserLogFile) {
            $LogFileUser = $UserLogFile -replace "\.log$",""
        }
        else {
            $LogFileUser = $LogUser
        }

        ##Festlegen des Namens der ClientLogFile
        if ($HostLogFile) {
            $LogFileHost = $HostLogFile -replace "\.log$",""
            $LogHost = $HostLogFile -replace "\.log$",""
        }
        else {
            $LogFileHost = $LogClient
        }

        ## Ermittle die LogPaths je nach Priorität
        switch ($Severity) {
            {$_ -ge 0} { $LogPath += Join-Path $MASTPath.Log.Env "$LogSite\$LogFileHost.log" }
            {$_ -ge 1} { $LogPath += Join-Path $MASTPath.Log.Env "Info-$LogSite.log" }
            {$_ -ge 2} { $LogPath += Join-Path $MASTPath.Log.Env "Error.log" }
        }

        ## Ermittle den LogPath
        if ($User) {
            ## Der User-Log Pfad
            $LogPath += Join-Path $MASTPath.Log.Env "User\$LogFileUser.log"
        }

        Write-Verbose "LogPath: $LogPath"

		Write-Verbose "--- $($MyInvocation.MyCommand) - Begin - End"
	}
	process {
		Write-Verbose "--- $($MyInvocation.MyCommand) - Process - Start"

        ## Lege den Ordner an falls noch nicht existiert

        foreach ($Path in $LogPath) {
            if (-not (Test-Path (Split-Path $Path))) {
                New-Item -Path (Split-Path $Path) -ItemType Directory -Force | Out-Null
            }
        }

        ## Baue den Datensatz
        foreach ($DataSet in $Data) {
            $LogData += "$LogTime`t$LogSite`t$LogUser`t$LogClient`t$LogHost`t$DataSet"
        }

        ## Schreibe in die Datei
        try {
            ## Für jeden Zielpfad der Reihe nach
            $LogPath | %{
                Out-File -FilePath $_ -InputObject $LogData -Encoding utf8 -Append -Force -Verbose:($PSBoundParameters['Verbose'] -eq $true)
            }
        }
        catch {
            Write-Warning "Log-Daten konnten nicht geschrieben werden"
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUTQ0qKKzb2FNRdkw2kcYPRjIr
# bQWgggbQMIIGzDCCBLSgAwIBAgIKHtjtxQABAAABvjANBgkqhkiG9w0BAQsFADBH
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
# AQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTohiq4Fi07
# 8KZZ9xA9/9TZtWUlvTANBgkqhkiG9w0BAQEFAASCAQCSLm6R1iIhpbii00G9DEHr
# 0//HgiR8615w4DrMZhnu/cuKbE3O7nfXsYg1kzjWCo7Rplz3J+xKeayYcl8mlA+b
# l4kArtJoMKCQYEUjjgB15fuaxOj5Fb/0L8RRMy5JrCw4qttjxtmgoP4ALjNJCu0D
# 8T/o624WDFHA4FSvFgbOMSYPD63TwFNCEfNWWMG+kVafMQ9d7oaRQrplzbeAOsBy
# D2IUCkEx10LywMcY/w8NgP3JuwE7Hcu4LnwliGQ31TJ7vIpP8900ZNkuKRmC0j6D
# ZDCqwzvkFtdM2vliyTZ68x2HbTdTSvx9TPUJx+kRVrlFBjnTcesyDC0SI9IHmFev
# SIG # End signature block
