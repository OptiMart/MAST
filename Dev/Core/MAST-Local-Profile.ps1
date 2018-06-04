<#
.NOTES
    Name: MAST-Local-Profile.ps1 
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

    # Save the provided Paths
    [Parameter(Mandatory=$true,
               ParameterSetName='SaveNewPath')]
    [Alias("Save")]
    [switch]
    $TempMASTSave,

    # Load with the provided Paths
    [Parameter(Mandatory=$true,
               ParameterSetName='LoadForcePath')]
    [Alias("Force")]
    [switch]
    $TempMASTForce,

    # Load with the provided Paths
    [Parameter(Mandatory=$true,
               ParameterSetName='Development')]
    [Alias("Dev","Develope","Development")]
    [switch]
    $TempMASTDev
)
Begin
{
    ## Save Time for loading time benchmark
    $TempMASTTimer = @()
    $TempMASTTimer += @{Name="Start";Time=Get-Date}

    ## Conditions for 3 sec PopUp to load Dev
    [bool] $TempMASTDevPopup = ($env:USERNAME -match "Auriok")

    #region ######## ----- Declare Constants ----- #############################

    New-Variable -Name MASTConstAllUsersAllHosts -Value "AllUsersAllHosts" -Option ReadOnly -Force
    New-Variable -Name MASTConstAllUsersCurrentHost -Value "AllUsersCurrentHost" -Option ReadOnly -Force
    New-Variable -Name MASTConstCurrentUserAllHosts -Value "CurrentUserAllHosts" -Option ReadOnly -Force
    New-Variable -Name MASTConstCurrentUserCurrentHost -Value "CurrentUserCurrentHost" -Option ReadOnly -Force
    New-Variable -Name MASTConstRemoteProfile -Value "RemoteProfile" -Option ReadOnly -Force

    New-Variable -Name MASTConstLive -Value "Live" -Option ReadOnly -Force
    New-Variable -Name MASTConstDev -Value "Dev" -Option ReadOnly -Force

    New-Variable -Name MASTLoaderFunction -Value "Start-MASTLoader" -Description "Name of the LoaderFunction" -Force

    if ((Get-Variable MASTProfileScope -ErrorAction SilentlyContinue) -eq $null)
    {
        New-Variable -Name MASTProfileScope -Value @()
    }

    #endregion ##### ----- Declare Constants ----- #############################

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
        }
        Process
        {
            switch ($ScriptPath)
            {
                ## Return value equal to profilescope
                "$($profile.$MASTConstAllUsersAllHosts)" { $ReturnVal = $MASTConstAllUsersAllHosts }
                "$($profile.$MASTConstAllUsersCurrentHost)" { $ReturnVal = $MASTConstAllUsersCurrentHost }
                "$($profile.$MASTConstCurrentUserAllHosts)" { $ReturnVal = $MASTConstCurrentUserAllHosts }
                "$($profile.$MASTConstCurrentUserCurrentHost)" { $ReturnVal = $MASTConstCurrentUserCurrentHost }
                default
                {
                    ## if the Scriptpath dies not match a profilepath check other scenarios
                    if ( -not $profile -and $Host.Name -match "Remote" )
                    {
                        $ReturnVal = $MASTConstRemoteProfile
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

    function Get-MASTEnvironment
    {
        <#
        .SYNOPSIS
            Returns if use Dev or Live Environment for MAST can be enhanced for more Environments
        #>
        [CmdletBinding()]
        Param(
            [Parameter(Position=0)]
            [bool] $UseDev,
            [Parameter(Position=1)]
            [bool] $UsePopup,
            [Parameter(Position=2)]
            [int] $Timer = 3
        )
        Begin
        {
            ## Initialise ReturnVal
            $ReturnEnv = $MASTConstLive
        }
        Process
        {
            if ($UseDev)
            {
                $ReturnEnv = $MASTConstDev
            }
            elseif ($UsePopup)
            {
                $MyPopup = new-object -comobject wscript.shell
        
                if ($MyPopup.Popup("Load Dev-Environment?",$Timer,"Dev",4) -eq 6)
                {
                    $ReturnEnv = $MASTConstDev
                }
            }
        }
        End
        {
            ## Return ProfileScope
            Write-Output $ReturnEnv
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
                $ReturnVal = "Core\MAST-Core_Loader_PSv5.ps1"
            }
            else
            {
                switch ($PSVersionTable.PSVersion)
                {
                    ## check which Loader to use dependant on PSVersion
                    #{$_ -ge [version]"5.1"} {$TempMASTLoader = "Core\MAST-Core_Loader_PSv5_1.ps1"; break} ## geplant den MAST-Loader als Klasse zu implementieren
                    {$_ -ge [version]"4.0"} {$ReturnVal = "Core\MAST-Core_Loader_PSv4.ps1"; break}
                    {$_ -ge [version]"2.0"} {$ReturnVal = "Core\MAST-Core_Loader_PSv2.ps1"; break}
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
    $MASTProfileScope += $TempMASTProfileScope = Get-MASTProfileScope -ScriptPath $MyInvocation.MyCommand.Path
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

    ## Check if live or dev environment
    $MASTEnviron = $TempMASTEnviron = Get-MASTEnvironment $TempMASTDev $TempMASTDevPopup
    Write-Verbose "Environment: $TempMASTEnviron"

    ## Check if Online
    if (Test-Path -Path (Join-Path $TempMASTPath.Online $MASTEnviron))
    {
        Write-Verbose "MAST is Online"
        $MASTIsOnline = $true
        $TempMASTBasePath = $TempMASTPath.Online
    }
    elseif (Test-Path -Path (Join-Path $TempMASTPath.Local $MASTEnviron))
    {
        Write-Verbose "MAST is Offline"
        $MASTIsOnline = $false
        $TempMASTBasePath = $TempMASTPath.Local
    }

    ## Get Script for MAST-Loader
    $TempMASTLoader = Get-MASTLoaderScript ($TempMASTEnviron -eq $MASTConstDev)

    #region ######## ----- Start Loader ----- ##################################

    if (Get-Variable TempMASTBasePath -ValueOnly -ErrorAction SilentlyContinue)
    {
        if (Get-Variable TempMASTLoader -ValueOnly -ErrorAction SilentlyContinue)
        {
            $TempMASTPathLoader = Join-Path (Join-Path $TempMASTBasePath $TempMASTEnviron) $TempMASTLoader

            if (Test-Path -Path $TempMASTPathLoader) {
                
                ## Get Time for loading time benchmark
                $TempMASTTimer += @{Name="Start-Loader";Time=Get-Date}
                
                try
                {
                    . $TempMASTPathLoader
                }
                catch
                {
                    Write-Warning "An Error occured in the Loader-Scriptfile ($TempMASTLoader)"
                }

                if (Get-Command $MASTLoaderFunction -ErrorAction SilentlyContinue)
                {
                    ## if the Loader was encapsulated in a function, call it now with parameters
                    . $MASTLoaderFunction -MASTBasePath $TempMASTBasePath  -MASTEnviron $TempMASTEnviron -MASTProfileScope $TempMASTProfileScope
                }
            }
            else {
                Write-Host "   !!! The determined MAST-Loader ($TempMASTPathLoader) could not be found !!!   " -BackgroundColor Red -ForegroundColor Yellow
            }
        }
        else {
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

    if ($TempMASTEnviron -eq $MASTConstDev)
    {
        ## if in Dev-Mode write Timing Benchmark
        $TempMASTTimer += @{Name="Finish";Time=Get-Date}
        for ($iTimer=1;$iTimer -lt $TempMASTTimer.Count;$iTimer++)
        {
            Write-Host ("$($TempMASTTimer[$iTimer].Name): {0:N0} Second ({1:N0} MilSec)" -f $($TempMASTTimer[$iTimer].Time - $TempMASTTimer[$iTimer-1].Time).TotalSeconds, $($TempMASTTimer[$iTimer].Time - $TempMASTTimer[$iTimer-1].Time).TotalMilliseconds) -BackgroundColor Gray -ForegroundColor Black
        }
        Write-Host ("Start-Finish: {0:N0} Second ({1:N0} MilSec)" -f $($TempMASTTimer[$TempMASTTimer.Count-1].Time - $TempMASTTimer[0].Time).TotalSeconds, $($TempMASTTimer[$TempMASTTimer.Count-1].Time - $TempMASTTimer[0].Time).TotalMilliseconds) -BackgroundColor Gray -ForegroundColor Black
        
        Remove-Variable "TempMAST*" -Force -ErrorAction SilentlyContinue
    }
    else
    {
        ## if not in Dev-Mode remove all unneeded temp Variables
        Remove-Variable "TempMAST*" -Force -ErrorAction SilentlyContinue
        Write-Host
    }
    
    #endregion ##### ----- Cleanup Tasks ----- #################################
}
