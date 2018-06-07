function Check-MASTLoaderVersion
{
<#
.NOTES
    Name: Check-MASTLoaderVersion
    Autor: Martin Strobl
    Version History:
    1.0 - 07.06.2018 - Initial Release.
.SYNOPSIS
    This Function checks for previous loaded MASTVersions and returns true if loading should continue
.DESCRIPTION
#>
    [CmdletBinding()]
    Param(
        # Version to check
        [Parameter(Mandatory,Position=0)]
        [version]
        $Version,

        # Callers Scope
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $Scope = "unknown",

        # Write Output to Host
        [Parameter()]
        [switch]
        $Output
    )
    Begin
    {
        ## Initialise Returnvalue
        $Return = $true

        ## Set wich command to use for Text Output
        if ($Output)
        {
            $OutputCommand = "Write-Host"
        }
        else
        {
            $OutputCommand = "Write-Verbose"
        }
    }
    PRocess
    {
        if (Get-Variable MASTLoaderVersion -ErrorAction SilentlyContinue)
        {
            ## MASTLoaderVersion already exists

            if ($Version -gt $MASTLoaderVersion)
            {
                ## Current loading Version is greater than the existing

                & $OutputCommand "There is a newer MAST-Loader ($Scope) v$Version" # -ForegroundColor Yellow

                ## Choice Popups only appear in ISE
                if ($Host.Name -match "ISE")
                {
                    $TempMASTPopup = new-object -comobject wscript.shell

                    if ($TempMASTPopup.popup("There is a newer MAST-Loader ($Scope) v$Version`r`nContinue Loading?",5,"Additional Loader",4) -eq 6)
                    {
                        & $OutputCommand "Positive user interaction -> return true"
                    }
                    else
                    {
                        & $OutputCommand "Negative user interaction -> return false"
                        $Return = $false
                    }
                }
                else
                {
                    & $OutputCommand "Not running in ISE -> return true"
                    $Return = $true
                }
            }
            elseif ($Version -eq $MASTLoaderVersion)
            {
                ## Current loading Version is the same as the the existing

                & $OutputCommand "There is another MAST-Loader with the same version ($Scope) v$Version"

                ## Choice Popups only appear in ISE
                if ($Host.Name -match "ISE") {

                    $TempMASTPopup = new-object -comobject wscript.shell

                    if ($TempMASTPopup.popup("There is another MAST-Loader with the same version ($Scope) v$Version`r`nContinue Loading?",5,"Additional Loader",4) -eq 6)
                    {
                        & $OutputCommand "Positive user interaction -> return true"
                    }
                    else
                    {
                        & $OutputCommand "Negative user interaction -> return false"
                        $Return = $false
                    }
                }
                else
                {
                    & $OutputCommand "Not running in ISE -> return false"
                    $Return = $false
                }
            }
            else {
                & $OutputCommand "The current Version is older then the already loaded -> return true"
            }
        }
        else
        {
            & $OutputCommand "No previously loaded MAST found -> return true"
        }
    }
    End
    {
        ## Return
        Write-Output $Return
    }
}