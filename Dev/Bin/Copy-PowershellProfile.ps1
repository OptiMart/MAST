<#
.NOTES
	Name: Copy-PowershellProfile
	Autor: ViAtStMa
	Version History:
		04.05.2018 - Initial Release
.SYNOPSIS
	Diese Funktion kopiert die Profile.ps1 Datei an den Zielort
.DESCRIPTION
	Diese Funktion kann außerhalb des MAST aufgerufen werden um die "Start-Datei" an den richtigen Ort zu kopieren
.PARAMETER Target
	An welchen Zielort soll die Datei kopiert werden
.PARAMETER Dev
	Wenn die Profile.ps1 aus dem Dev-Verzeichnis genommen werden soll
#>
[CmdletBinding()]
param(
	[parameter()]
	[ValidateSet('AllUsersAllHosts','AllUsersCurrentHost','CurrentUserAllHosts','CurrentUserCurrentHost','Current')]
    [string] $Target = 'AllUsersAllHosts',
    [parameter()]
    [switch] $Dev
)
begin {
    ## Initialisiere Pfadvariablen

    Write-Verbose "Ermittle den Quellpfad"
    if ($Dev) {
        $SourcePath = "\\efko.local\ItEfGrDfs\Scripts\Dev\Core\MAST-Local-Profile.ps1"
    }
    else {
        $SourcePath = "\\efko.local\ItEfGrDfs\Scripts\Live\Core\MAST-Local-Profile.ps1"
    }
    Write-Verbose $SourcePath

    Write-Verbose "Ermittle den Zielpfad"
    if ($Target -eq 'Current') {
        $TargetPath = $profile
    }
    else {
        $TargetPath = $profile.$Target
    }
    Write-Verbose $TargetPath
}
process {
    Write-Verbose "Starte kopiervorgang"
    Copy-Item -Path $SourcePath -Destination $TargetPath -Force | Out-Null
}
end {
}
