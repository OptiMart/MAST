<#
.NOTES
    Autor: Martin Strobl
.SYNOPSIS
    Registriert ein PS Config für den Remotezugang mit dem Standardprofil
#>

$ProfileName = "RemoteProfile"
$ProfilePath = "$PSHOME\profile.ps1"
$ProfileUser = @("Domain\Admins","Domain\IT-Users")

## Bindet die Funktion ein
. (Join-Path $MASTPath.Liv.Lib "PS-Func_Set-PowerShellProfile.ps1")

Set-PowerShellProfile -ConfigName $ProfileName -ProfilePath $ProfilePath -Users $ProfileUser
