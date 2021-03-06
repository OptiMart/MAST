﻿################################################################################
##                                                                            ##
##  Manage & Administrate Scripts - Tool (MAST)                               ##
##  Copyright (c) 2018 Martin Strobl                                          ##
##                                                                            ##
##  This program is free software: you can redistribute it and/or modify      ##
##  it under the terms of the GNU General Public License as published by      ##
##  the Free Software Foundation, either version 3 of the License, or         ##
##  (at your option) any later version.                                       ##
##                                                                            ##
##  This program is distributed in the hope that it will be useful,           ##
##  but WITHOUT ANY WARRANTY; without even the implied warranty of            ##
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             ##
##  GNU General Public License for more details.                              ##
##                                                                            ##
##  You should have received a copy of the GNU General Public License         ##
##  along with this program.  If not, see <http://www.gnu.org/licenses/>.     ##
##                                                                            ##
################################################################################

<#
.NOTES
    Name: MAST-Core_Invoke-MASTLoader.ps1 
    Autor: Martin Strobl
    Version History:
    2.0 - 31.08.2017 - Trennung von Lokaler profile.ps1 Datei und Loader-Datei
          05.09.2017 - Popup für Auswahl Dev-Umgebung (Username = viatstma)
          08.05.2018 - Anpassung für Scope Development
                       Fehlerbehandlung bei $TempMASTLoader
    2.1 - 02.06.2018 - Komplette Überarbeitung (Funktionsaufbau, Const, Registry)
.SYNOPSIS
    Dieses Skript wird an alle gewünschten Powershell Profil-Pfade verteilt um bei jedem Start das MAST zu laden
.DESCRIPTION
    Dieses Skript muss in einem der $profile Pfade abgelegt werden.
    Dadruch wird es dann bei jedem Sitzungsstart ausgeführt und versucht das Managing&Administrating Scripts-Tool (MAST) zu laden

    1) Definieren von Basispfaden zu (Online/Offline) Umgebung von MAST
    2) Ermitteln um welche Profildatei es sich handelt (woher wird geladen)
    3) Ermitteln ob eine Verbindung zum Online-Verzeichnis besteht
    4) Nachladen des eigentlichen MAST-Loaders (abhängig von der PS-Version)
    5) Aufräumarbeiten durchführen
#>

[CmdletBinding(DefaultParameterSetName = 'LoadSilentRegistry',
               HelpUri = '')]
Param(
    # Path to Central/Online Script-Repository
    [Parameter(Mandatory=$true,
               ParameterSetName='SaveNewPath')]
    [Parameter(Mandatory=$true,
               ParameterSetName='LoadForcePath')]
    [ValidateNotNull()]
    [Alias("PathOnline","Path")]
    [string]
    $TempMASTPathOnline = "\\ServerName\Share\ScriptRoot",

    # Path to Local/Offline Copy of Live-Repository
    [Parameter(Mandatory=$false,
               ParameterSetName='SaveNewPath')]
    [Parameter(Mandatory=$false,
               ParameterSetName='LoadForcePath')]
    [Alias("PathLocal","PathOffline")]
    [string]
    $TempMASTPathLocal = (Join-Path $env:HOMEDRIVE "MAST"),

    # Path to Registry for MAST in Local Machine
    [Parameter()]
    [Alias("PathHKLM","RegistryHKLM")]
    [string]
    $TempMASTPathHKLM = "HKLM:\SOFTWARE\MAST",

    # Path to Registry for MAST in Current User
    [Parameter()]
    [Alias("PathHKCU","RegistryHKCU")]
    [string]
    $TempMASTPathHKCU = "HKCU:\Software\MAST",

    # Save the provided Paths - not implementet
    [Parameter(Mandatory=$true,
               ParameterSetName='SaveNewPath')]
    [Alias("Save")]
    [switch]
    $TempMASTSave,

    # Load with the provided Paths - not implementet
    [Parameter(Mandatory=$true,
               ParameterSetName='LoadForcePath')]
    [Alias("Force")]
    [switch]
    $TempMASTForce,

    # Load in Develepmentmode
    [Parameter(Mandatory=$true,
               ParameterSetName='Development')]
    [Alias("Dev","Develope","Development")]
    [switch]
    $TempMASTDev #= $true
)
Begin
{
    ## Save Time for loading time benchmark
    $TempMASTTimer = @()
    $TempMASTTimer += @{Name="Start";Time=Get-Date}

    #region ######## ----- Help-Functions ----- ################################
    
    function Get-MASTPathFromRegistry
    {
        <#
        .SYNOPSIS
            Returns the Paths stored in Registry
        #>
        [CmdletBinding()]
        Param(
            # Paths in Registry, last write wins
            [ValidateNotNullOrEmpty()]
            [string[]]
            $RegPath,

            # Path Scopes "Variable Names"
            [ValidateNotNullOrEmpty()]
            [string[]]
            $Scopes = @("Online", "Local")
        )
        Begin
        {
            ## Initialise Return-Object
            $ReturnObj = New-Object psobject

            foreach ($Scope in $Scopes)
            {
                $ReturnObj | Add-Member -MemberType NoteProperty -Name $Scope -Value ""
            }
        }
        Process
        {
            ## Try to load Paths from Registry HKCU -> HKLM
            foreach ($PathSource in $RegPath)
            {
                ## Load Online and Local
                foreach ($PathScope in $Scopes)
                {
                    $PathValue = Get-ItemPropertyValue -Path $PathSource -Name "Path$PathScope" -ErrorAction SilentlyContinue

                    if ($PathValue)
                    {
                        ## If Path exists in Registry, Set in Variable
                        $ReturnObj.$PathScope = $PathValue
                    }
                }
            }
        }
        End
        {
            ## Return Object
            Write-Output $ReturnObj
        }
    }

    function Get-MASTProfileScope
    {
        <#
        .SYNOPSIS
            Returns Scope für the MAST Loader
        .DESCRIPTION
            Returns a String with the correspondig Scope
            - AllUsersAllHosts, AllUsersCurrentHost, CurrentUserAllHosts, CurrentUserCurrentHost
            - RemoteProfile (if startet in a remote PSSession)
            - n.A. (if not applicable)
        #>
        [CmdletBinding()]
        Param(
            # Call with $MyInvocation.MyCommand.Path
            [Parameter()]
            [string]
            $ScriptPath
        )
        Begin
        {
            ## Initialise ReturnVal
            $ReturnVal = "n.A"

            $Scopes = @{
                "AllUsersAllHosts" = "AllUsersAllHosts"
                "AllUsersCurrentHost" = "AllUsersCurrentHost"
                "CurrentUserAllHosts" = "CurrentUserAllHosts"
                "CurrentUserCurrentHost" = "CurrentUserCurrentHost"
                "RemoteProfile" = "RemoteProfile"
            }

        }
        Process
        {
            switch ($ScriptPath)
            {
                ## Return value equal to profilescope
                "$($profile.$($Scopes.AllUsersAllHosts))" { $ReturnVal = $Scopes.AllUsersAllHosts }
                "$($profile.$($Scopes.AllUsersCurrentHost))" { $ReturnVal = $Scopes.AllUsersCurrentHost }
                "$($profile.$($Scopes.CurrentUserAllHosts))" { $ReturnVal = $Scopes.CurrentUserAllHosts }
                "$($profile.$($Scopes.CurrentUserCurrentHost))" { $ReturnVal = $Scopes.CurrentUserCurrentHost }
                default
                {
                    ## if the Scriptpath dies not match a profilepath check other scenarios
                    if ( -not $profile -and $Host.Name -match "Remote" )
                    {
                        $ReturnVal = $Scopes.RemoteProfile
                    }
                    else
                    {
                        <#if ($MASTEnviron -eq "Dev")
                        {
                            $ReturnVal = "Development"
                        }
                        else {
                            $ReturnVal = "n.A."
                        }
                        Write-Warning "Start from unknowen Path"#>
                    }
                }
            }
        }
        End
        {
            ## Return ProfileScope
            Write-Output $ReturnVal
        }
    }

    function Get-MASTLoaderScript
    {
        <#
        .SYNOPSIS
            Returns the Path to the Loader-Scriptfile
        #>
        [CmdletBinding()]
        Param(
            # true for Development
            [Parameter(Position=0)]
            [bool] $Dev
        )
        Begin
        {
            ## Initialise Return
            $ReturnVal = ""
        }
        Process
        {
            if ($Dev)
            {
                $ReturnVal = "\Core\Loader\MAST-Loader_PSv5.ps1"
            }
            else
            {
                switch ($PSVersionTable.PSVersion)
                {
                    ## check which Loader to use dependant on PSVersion
                    {$_ -ge [version]"5.0"} {$ReturnVal = "\Core\Loader\MAST-Loader_PSv5.ps1"; break}
                    {$_ -ge [version]"4.0"} {$ReturnVal = "\Core\Loader\MAST-Loader_PSv4.ps1"; break}
                    {$_ -ge [version]"2.0"} {$ReturnVal = "\Core\Loader\MAST-Loader_PSv2.ps1"; break}
                    default {$ReturnVal = ""; break}
                }
            }
        }
        End
        {
            ## Return the determined Path
            Write-Output $ReturnVal
        }
    }

    function Install-MAST
    {
        Write-Host
        Write-Host "This is your first start of MAST (Manage & Administrate Scripts - Tool)" -ForegroundColor Cyan
        Write-Host
        Write-Host "You startet with following Path-Settings:"
        Write-Host "Path to Online Repository:   " -NoNewline
        Write-Host $TempMASTPathOnline -ForegroundColor Yellow
        Write-Host "Path to Offline Copy:        " -NoNewline
        Write-Host $TempMASTPathLocal -ForegroundColor Yellow
        Write-Host
        Write-Host "If you want to save these Settings to Registry press " -NoNewline
        Write-Host "(S)ave" -ForegroundColor Green
        Write-Host "If you want to provide different Settings press " -NoNewline
        Write-Host "(N)ew." -ForegroundColor Green
        $TempMASTAnswerPath = Read-Host "If you want to continue with these Settings without save, press Enter"
        Write-Host
        
        ## Set the Paths from the Script to the Temp-Var for further usage
        $TempMASTPathOnline = $TempMASTPathOnline
        $TempMASTPathLocal = $TempMASTPathLocal

        if ($TempMASTAnswerPath -match "^s" -or $TempMASTAnswerPath -match "^n")
        {
            ## Want to save Settings to Registry New or from Script

            New-Item $TempMASTPathHKLM -ErrorAction SilentlyContinue | Out-Null
            New-Item $TempMASTPathHKCU -ErrorAction SilentlyContinue | Out-Null

            if ($TempMASTAnswerPath -match "^n")
            {
                ## Provide new Paths
                do
                {
                    $TempMASTPathOnline = Read-Host "Enter Path to Online Repository"
                    
                    if ($TempMASTPathOnline)
                    {
                        if (-not (Test-Path $TempMASTPathOnline))
                        {
                            Write-Host "Path does not exist" -ForegroundColor Red
                        }
                    }
                ## If Path is blank or Path exists -> exit Loop
                }
                until ($(if(-not $TempMASTPathOnline) {$true} else {Test-Path $TempMASTPathOnline}))

                $TempMASTPathLocal = Read-Host "Enter Path to Local Copy"
            }
            
            if (Get-Variable TempMASTPathOnline -ErrorAction SilentlyContinue)
            {
                New-ItemProperty -Path $TempMASTPathHKLM -Name PathOnline -Value $TempMASTPathOnline -Force -ErrorAction SilentlyContinue | Out-Null
                New-ItemProperty -Path $TempMASTPathHKCU -Name PathOnline -Value $TempMASTPathOnline -Force -ErrorAction SilentlyContinue | Out-Null
            }

            if (Get-Variable TempMASTPathLocal -ErrorAction SilentlyContinue)
            {
                New-ItemProperty -Path $TempMASTPathHKLM -Name PathLocal -Value $TempMASTPathLocal -Force -ErrorAction SilentlyContinue | Out-Null
                New-ItemProperty -Path $TempMASTPathHKCU -Name PathLocal -Value $TempMASTPathLocal -Force -ErrorAction SilentlyContinue | Out-Null
            }
        }
    }

    #endregion ##### ----- Help-Functions ----- ################################
}
Process
{
    ## Get Time for loading time benchmark
    $TempMASTTimer += @{Name="Start-Process";Time=Get-Date}

    ## Get ProfileScope
    $TempMASTProfileScope = Get-MASTProfileScope -ScriptPath $MyInvocation.MyCommand.Path
    Write-Verbose "ProfileScope: $TempMASTProfileScope"

    ## Load Paths
    switch -Wildcard ($TempMASTProfileScope)
    {
        "AllUsers*"
        {
            ## If this script is loaded from a "Machinecontext-Profile-Path"
            $TempMASTPath = Get-MASTPathFromRegistry -RegPath @($TempMASTPathHKLM)
        }
        "CurrentUser*"
        {
            ## If this script is loaded from a "Usercontext-Profile-Path"
            $TempMASTPath = Get-MASTPathFromRegistry -RegPath @($TempMASTPathHKCU)
        }
        "Remote*"
        {
            ## If the script is loaded from a remotesession
            $TempMASTPath = Get-MASTPathFromRegistry -RegPath @($TempMASTPathHKLM)
            ## ToDo: Load different Paths
        }
        default
        {
            ## If this script is loaded from an unknown source (e.g. manually in console)
            $TempMASTPath = Get-MASTPathFromRegistry -RegPath @($TempMASTPathHKCU, $TempMASTPathHKLM)
            ## ToDo: Load different Paths
        }
    }

    Write-Verbose "PathOnline: $($TempMASTPath.Online)"
    Write-Verbose "PathLocal: $($TempMASTPath.Local)"

    ## ToDo: Check if Firstrun -> start install / prepare environment (Folderstructure)
    ##       eventually copy profile.ps1 to destinations

    ## Check if live or dev environment
    #$MASTEnviron = $TempMASTEnviron = Get-MASTEnvironment $TempMASTDev $TempMASTDevPopup
    #Write-Verbose "Environment: $TempMASTEnviron"
    
    ## Check if Online
    if (Test-Path -Path $TempMASTPath.Online)
    {
        Write-Verbose "MAST is Online"
        $MASTIsOnline = $true
        $TempMASTBasePath = $TempMASTPath.Online
    }
    elseif (Test-Path -Path $TempMASTPath.Local)
    {
        Write-Verbose "MAST is Offline"
        $MASTIsOnline = $false
        $TempMASTBasePath = $TempMASTPath.Local
    }

    ## Get Script for MAST-Loader
    $TempMASTLoader = Get-MASTLoaderScript $TempMASTDev

    #region ######## ----- Start Loader ----- ##################################

    if (Get-Variable TempMASTBasePath -ValueOnly -ErrorAction Ignore)
    {
        if (Get-Variable TempMASTLoader -ValueOnly -ErrorAction Ignore)
        {
            #$TempMASTPathLoader = Join-Path (Join-Path $TempMASTBasePath $TempMASTEnviron) $TempMASTLoader
            $TempMASTPathLoader = Join-Path $TempMASTBasePath $TempMASTLoader

            if (Test-Path -Path $TempMASTPathLoader)
            {
                ## Get Time for loading time benchmark
                $TempMASTTimer += @{Name="Start-Loader";Time=Get-Date}
                
                try
                {
                    ## Import the detirmenied MASTLoader Script
                    . $TempMASTPathLoader
                }
                catch
                {
                    Write-Warning "An Error occured in the Loader-Scriptfile ($TempMASTLoader)`r`n$($Error[0])"
                }

                if (Get-Command $MASTLoaderFunction -ErrorAction SilentlyContinue)
                {
                    ## if the Loader was encapsulated in a function, call it now with parameters
                    . $MASTLoaderFunction -MASTBasePath $TempMASTBasePath -MASTProfileScope $TempMASTProfileScope -MASTDev:$TempMASTDev
                }
            }
            else
            {
                Write-Host "   !!! The determined MAST-Loader ($TempMASTPathLoader) could not be found !!!   " -BackgroundColor Red -ForegroundColor Yellow
            }
        }
        else
        {
            Write-Host "   !!! No MAST-Loader could be determined !!!   " -BackgroundColor Red -ForegroundColor Yellow
        }
    }
    else
    {
        Write-Host "   !!! There is no Connection to the central Script-Repository - and there is no local Copy to load !!!   " -BackgroundColor Red -ForegroundColor Yellow
    }

    #endregion ##### ----- Start Loader ----- ##################################
}
End
{
    #region ######## ----- Cleanup Tasks ----- #################################

    Write-Progress -Activity "*" -Completed

    if ($TempMASTDev)
    {
        ## if in Dev-Mode write Timing Benchmark
        $TempMASTTimer += @{Name="Finish";Time=Get-Date}
        for ($iTimer=1;$iTimer -lt $TempMASTTimer.Count;$iTimer++)
        {
            Write-Host ("$($TempMASTTimer[$iTimer].Name): {0:N0} Second ({1:N0} MilSec)" -f $($TempMASTTimer[$iTimer].Time - $TempMASTTimer[$iTimer-1].Time).TotalSeconds, $($TempMASTTimer[$iTimer].Time - $TempMASTTimer[$iTimer-1].Time).TotalMilliseconds) -BackgroundColor Gray -ForegroundColor Black
        }
        Write-Host ("Start-Finish: {0:N0} Second ({1:N0} MilSec)" -f $($TempMASTTimer[$TempMASTTimer.Count-1].Time - $TempMASTTimer[0].Time).TotalSeconds, $($TempMASTTimer[$TempMASTTimer.Count-1].Time - $TempMASTTimer[0].Time).TotalMilliseconds) -BackgroundColor Gray -ForegroundColor Black
    }
    else
    {
        ## if not in Dev-Mode remove all unneeded temp Variables
        Remove-Variable "TempMAST*" -Force -ErrorAction SilentlyContinue
        Write-Host
    }
    
    #endregion ##### ----- Cleanup Tasks ----- #################################
}
