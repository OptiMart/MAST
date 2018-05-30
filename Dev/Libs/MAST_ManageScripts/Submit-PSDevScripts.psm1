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
