function Set-PowerShellProfile {
<#
.NOTES
	Name: Set-PowerShellProfile
	Autor: Martin Strobl
	Version History:
		11.08.2017 - Initial Release
.SYNOPSIS
	Registriert ein PSSession Profil mit Namen und zugehöriger Profil-Datei für zB Remotesitzungen
.PARAMETER ConfigName
	Der Name der PSSessionConfiguration
.PARAMETER ProfilePath
	Der Pfad zur Startup Profil Datei
.PARAMETER Users
	Alle Benutzer-/gruppen die eine Berechtigung haben sollen
#>
	[CmdletBinding()]
	param(
		[parameter(Mandatory=$true,Position=0,HelpMessage="Der Name der PSSessionConfiguration")]
		[string] $ConfigName,
		[parameter(Mandatory=$true,Position=1,HelpMessage="Der Pfad zur Startup Profil Datei")]
		[string] $ProfilePath,
		[parameter(Mandatory=$false,Position=2,HelpMessage="Alle Benutzer-/gruppen die eine Berechtigung haben sollen")]
		[string[]] $Users
	)
	process {
		Write-Verbose "--- $($MyInvocation.MyCommand) - Process - Start"
        
        $config = Get-PSSessionConfiguration -Name "Microsoft.PowerShell"
        $existingSDDL = $Config.SecurityDescriptorSDDL
 
        $isContainer = $false
        $isDS = $false

        $SecurityDescriptor = New-Object -TypeName Security.AccessControl.CommonSecurityDescriptor -ArgumentList $isContainer,$isDS, $existingSDDL

        $accessType = "Allow"
        $accessMask = 268435456
        $inheritanceFlags = "none"
        $propagationFlags = "none"

        foreach ($User in $Users) {
            $account = New-Object Security.Principal.NTAccount $User
            $sid = $account.Translate([Security.Principal.SecurityIdentifier]).Value
            $SecurityDescriptor.DiscretionaryAcl.AddAccess($accessType,$sid,$accessMask,$inheritanceFlags,$propagationFlags)
        }
        
        Register-PSSessionConfiguration -Name $ConfigName -StartupScript $ProfilePath -SecurityDescriptorSddl $SecurityDescriptor.GetSddlForm("All") -Force
		
        Write-Verbose "--- $($MyInvocation.MyCommand) - Process - End"
	}
}
