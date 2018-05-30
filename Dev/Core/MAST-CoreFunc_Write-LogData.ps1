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
