function Publish-PSDevScripts {
<#
.SYNOPSIS
    Veröffentlicht alle vorbereiteten Skripte. Schiebt sie von der Release- in die Live-Umgebung und erstellt ein Backup
.DESCRIPTION
    Diese Funktion kann benutzt werden um im Entwicklungsprozess mit dem Parameter $Signature die bearbeitende Datei
    immer zu signieren und nicht zu löschen. Wenn alles erledigt ist wir dann mit dem Parameter $Delete die Datei aus dem
    Release-Verzeichnis gelöscht
.PARAMETER Signature
    Schalter ob alle Release-Skripte signiert werden sollen
.PARAMETER Delete
    Schalter ob die kopierten Dateien gelöscht werden sollen
#>
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$false,HelpMessage = "Schalter ob alle Release-Skripte signiert werden sollen")]
        [switch] $Signature,
        [parameter(Mandatory=$false,HelpMessage = "Schalter ob die kopierten Dateien gelöscht werden sollen")]
        [switch] $Delete,
        [parameter(Mandatory=$false,HelpMessage = "Filter welche Dateien verarbeitet werden sollen")]
        [string[]] $IncFile = @("*.ps1","*.psm1","*.psd1","*.xml")
    )
    begin {
		Write-Verbose "--- $($MyInvocation.MyCommand) - Begin - Start"
		
        .(Join-Path $MASTPath.Liv.Lib "PS-Func_Copy-ItemsEfkoGroup.ps1")

		Write-Verbose "--- $($MyInvocation.MyCommand) - Begin - End"
    }
    process{
		Write-Verbose "--- $($MyInvocation.MyCommand) - Process - Start"

        if ($Signature) {
            ## Wenn gewünscht werden auch gleich alle Skripte signiert
            Confirm-PSDevScripts -Release -Verbose:($PSBoundPARAMETERs['Verbose'] -eq $true) | Out-Null
            Write-Verbose "Bereitgestellte Dateien signiert"
        }

        ## Den Backup-Präfix jetzt definieren um einen einheitlichen für den gesamten Vorgang zu erzeugen
        $BkpPrefix = "$(Get-Date -Format "yyyy-MM-dd-HH-mm-ss")_"
        $PublishCount = 0

        ## Überprüfe alle Dateien im Release-Verzeichnis auf gültige Signaturen
        Get-ChildItem $MASTPath.Rel.Env -Recurse -Force -Include $IncFile | Get-AuthenticodeSignature | %{
            Write-Host "Veröffentliche: $($_.Path)".Replace($MASTPath.Rel.Env, "")

            if ($_.Status -eq "Valid" -or $_.Path -match ".psd1$" -or $_.Path -match ".xml$") {
                ## Nur wenn die Signatur der Datei gültig ist oder es sich um eine ModulManifest-Datei handelt wird sie kopiert
                Copy-ItemsEfkoGroup -PathDev $MASTPath.Rel.Env -PathBkp $MASTPath.Bkp.Env -PathDst $MASTPath.Liv.Env -FileFilter (Split-Path $_.Path -Leaf) -DeleteDev:$Delete -BkpPrefix $BkpPrefix -SendMail never -Verbose:($PSBoundPARAMETERs['Verbose'] -eq $true)
                $PublishCount++
            }
            else {
                Write-Warning "Die Datei $(Split-Path $_.Path -Leaf) hat keine gültige Signatur und wurde nicht veröffentlicht"
            }
        }

        Write-Host "$PublishCount Datei(en) wurden im Live-System aktualisiert" -ForegroundColor Magenta

        Write-Verbose "--- $($MyInvocation.MyCommand) - Process - End"
    }
}
