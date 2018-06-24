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
