function Clear-LogData {
<#
.NOTES
	Name: Clear-LogData
	Autor: ViAtStMa
	Version History:
		03.04.2018 - Initial Release
.SYNOPSIS
	Löscht alle Log-Daten die älter als X Tage sind
.DESCRIPTION
	Es werden alle Dateien gelöscht die länger als $Days Tage LastWriteTime Attribut haben
    Es werden alle Log-Daten in den Log-Files gelöscht die einen Zeitstempel älter als $Days haben
.PARAMETER Days
	Bereinigt die Log-Daten die älter als diese anzahl an Tagen ist (Default = 90)
#>
	[CmdletBinding()]
	param(
        [parameter(Mandatory=$false,Position=0)]
        [uint32] $Days = 90
    )
	begin {
		Write-Verbose "--- $($MyInvocation.MyCommand) - Begin - Start"
		
        [int] $RemovedFiles = 0
        [long] $RemovedChars = 0

        Write-Host "Hiermit werden die Log-Files bereinigt." -ForegroundColor Yellow
        $Weiter1 = Read-Host -Prompt "Soll fortgefahren werden? (j)"
        
        if ($Weiter1 -notmatch "j") {
            break
        }

        if ($Days -lt 90) {
            Write-Host "Sie haben einen Zeitraum kleiner 90 Tagen ausgewählt." -ForegroundColor Red
            $Weiter2 = Read-Host -Prompt "Soll fortgefahren werden? (j)"

            if ($Weiter2 -notmatch "j") {
                break
            }
        }

		Write-Verbose "--- $($MyInvocation.MyCommand) - Begin - End"
	}
	process {
		Write-Verbose "--- $($MyInvocation.MyCommand) - Process - Start"
		
        ## Lade alle Logfiles
        $LogFiles = @(Get-ChildItem -Path $MASTPath.Log.Env -Recurse -Include "*.log")
        Write-Host "Bereinigen der Log-Files unter $($MASTPath.Log.Env)" -ForegroundColor Cyan

        ## Verarbeite alle Log-Files
        foreach ($LogFile in $LogFiles) {
            
            Write-Host
            Write-Host "Bereinige $($LogFile.FullName -Replace [regex]::Escape($MASTPath.Log.Env), "... " )"
            [int64] $FileLength = $LogFile.Length

            if (($LogFile.LastWriteTime).AddDays($Days) -lt (Get-Date)) {
                
                ## Die Datei wird gelöscht da sie älter als der Bereinigungszeitraum ist
                Write-Host "  - Entferne Datei " -ForegroundColor Red -NoNewline
                
                try {
                    Remove-Item $LogFile -Force
                }
                catch {
                    Write-Warning "$($Error[0].Exception.Message)"
                }
                                    
                $RemovedFiles++
                $RemovedChars += $FileLength
                Write-Host "$("{0,0:N0}" -f $($FileLength)) Byte freigegeben" -ForegroundColor Green
            }
            else {
                ## Die Datei wird bereinigt
                
                ## Lade den Inhalt der Log-File und Filter nach Datum
                $LogData = Get-Content -Path $LogFile -Encoding UTF8 | 
                    Where-Object -FilterScript { @($_ -split "`t").Count -gt 1 } | 
                    Where-Object -FilterScript { (Get-Date @($_ -split "`t")[0]).AddDays($Days) -ge (Get-Date) }
            
                ## Schreibe die gefilterten Log-Daten wieder in das Log-File
                Write-Host "  - Komprimiere Datei " -ForegroundColor Yellow -NoNewline
                
                try {
                    Out-File -FilePath $LogFile -InputObject $LogData -Encoding utf8 -Force -Verbose:($PSBoundParameters['Verbose'] -eq $true)
                }
                catch {
                    Write-Warning "$($Error[0].Exception.Message)"
                }
                
                $LogFile.Refresh()
                $RemovedChars += $($FileLength - $LogFile.Length)
                Write-Host "$("{0,0:N0}" -f $($FileLength - $LogFile.Length)) Byte freigegeben" -ForegroundColor Green
            }
        }

		Write-Verbose "--- $($MyInvocation.MyCommand) - Process - End"
	}
	end {
		Write-Verbose "--- $($MyInvocation.MyCommand) - End - Start"

        Write-Host
        Write-Host "Verarbeitete Dateien: $($LogFiles.Count)"
        Write-Host "Gelöschte Dateien: $RemovedFiles"
        Write-Host "Gelöschte Zeichen: $RemovedChars"
        Write-Host $("Freigegebener Speicher: {0,0:N3} MiB" -f $($RemovedChars/1mb))
		
		Write-Verbose "--- $($MyInvocation.MyCommand) - End - End"
	}
}
