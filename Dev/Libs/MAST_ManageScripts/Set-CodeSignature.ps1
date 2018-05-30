function Set-CodeSignature {
<# 
.SYNOPSIS
    Signiert alle übergebenen Powershell Dateien
.DESCRIPTION
.PARAMETER Path
    Es können beliebig viele Dateien/Ordner übergeben werden
.PARAMETER Standard
    Mit dem Schalter Standard werden alle Scripte im Vitana Standard-Pfad signiert
.EXAMPLE
    [PS] C:\>Set-CodeSignature C:\Script.ps1
    C:\Script.ps1 wird signiert
.EXAMPLE
    [PS] C:\>Set-CodeSignature C:\Scripts
    Es werden alle Dateien im Ordner C:\Scripts signiert
#>
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$false,ValueFromPipeline=$true,Position=0,HelpMessage = "Zu signierende Datei oder Ordner mit Dateien")]
        [ValidateScript({Test-Path $_})]
        [Alias('File','Path')]
        [string[]] $ScriptPath
    )
    begin {
		Write-Verbose "--- $($MyInvocation.MyCommand) - Begin - Start"
		
        $IncFile = @("*.ps1","*.psm1")
        $SigFile = @()
        
        # Überprüfe ob eine Signatur vorhanden ist -> Wenn nicht kann nicht signiert werden -> ende
        if (@(Get-ChildItem Cert:\CurrentUser\My -codesigning).Count -eq 0) {
            Write-Host "Keine gültige Signatur zum Signieren von Code gefunden" -ForegroundColor Yellow
            break
        }
        else {
            $Cert = @(Get-ChildItem Cert:\CurrentUser\My -codesigning)[0]
        }

		Write-Verbose "--- $($MyInvocation.MyCommand) - Begin - End"
    }
    process {
		Write-Verbose "--- $($MyInvocation.MyCommand) - Process - Start"

        Write-Verbose "ScriptPath: $ScriptPath"

        # Es wird mit der Datei oder den in dem Ordner enthaltenen Dateien weiter gearbeitet
        $SigFile += Get-ChildItem $ScriptPath -Recurse -Force -Include $IncFile | Get-AuthenticodeSignature | Where-Object -Property Status -NE -Value "Valid"

		Write-Verbose "--- $($MyInvocation.MyCommand) - Process - End"
    }
    end {
		Write-Verbose "--- $($MyInvocation.MyCommand) - End - Start"
		
        # Signiere alle gefundenen Dateien die keine gültige Signatur haben
        Write-Verbose "Anzahl Dateien: $($SigFile.Count)"

        if ($SigFile.Count -ge 1) {
            Set-AuthenticodeSignature -FilePath $SigFile.Path -Certificate $Cert | Format-Table -Property Path, Status, StatusMessage
        }

		Write-Verbose "--- $($MyInvocation.MyCommand) - End - End"
    }
}
