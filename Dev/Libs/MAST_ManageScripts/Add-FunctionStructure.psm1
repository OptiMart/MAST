function Add-FunctionStructure {
<# 
.SYNOPSIS
    Fügt Standardbausteine für die Erstellung von Funktionen in die aktuelle Datei im ISE ein
#>
    [CmdletBinding()]
    param(
        [parameter()] # Gibt die Gesamtstruktur zurück
        [switch] $Full,
        [parameter()] # Gibt nur die Requires Eigenschaften aus
        [switch] $Requires,
        [parameter()] # Gibt nur die Comment-Based-Help aus
        [switch] $Help,
        [parameter()] # Gibt einen Beipielhaften Parametersatz aus
        [switch] $Parameter,
        [parameter()] # Gibt das Grundgerüst begin, process, end aus
        [switch] $Structure
    )
    begin {
        Write-Verbose "--- $($MyInvocation.MyCommand) - Begin - Start"

        if ($Host.Name -notlike "*ISE*") {
            Write-Warning "Diese Funktion kann nur im Powershell ISE Host verwendet werden"
            break
        }

        ## Die Hashtable mit den Daten für die Struktur
        $FunctionStructure = @(
            @{
                Name = "Requires"
                Tabs = 0
                NewL = 2
                True = @($Full,$Requires)
                Cont = @(
                    "#Requires -Version 5.0",
                    "#Requires -RunAsAdministrator",
                    "#Requires -Modules ActiveDirectory")
            } ## Requires
            @{
                Name = "Head"
                Tabs = 0
                NewL = 1
                True = @($Full)
                Cont = @("function Verb-Noun {")
            } ## Head
            @{
                Name = "Help"
                Tabs = 0
                NewL = 1
                True = @($Full, $Help)
                Cont = @(
                    "<#",
                    ".NOTES",
                    "`tName: FunctionName",
                    "`tAutor: $($env:USERNAME)",
                    "`tVersion History:",
                    "`t`t$(Get-Date -Format dd.MM.yyyy) - Initial Release",
                    ".SYNOPSIS",
                    "`tKurzbeschreibung",
                    ".DESCRIPTION",
                    "`tLangtext Beschreibung",
                    ".PARAMETER X"
                    "`tParameter",
                    ".EXAMPLE",
                    "`tFunctionName -parameter",
                    "`tDies und das passiert",
                    "#>")
            } ## Help
            @{
                Name = "Body"
                Tabs = 1
                NewL = 1
                True = @($Full)
                Cont = @(
                    @{
                        Name = "Cmdlet"
                        Tabs = 0
                        NewL = 1
                        True = @($Full, $Parameter)
                        Cont = @("[CmdletBinding()]")
                    } ## Cmdlet, Body
                    @{
                        Name = "Param"
                        Tabs = 0
                        NewL = 1
                        True = @($Full, $Parameter)
                        Cont = @(
                            @{
                                Name = "Head"
                                Tabs = 0
                                NewL = 1
                                True = @($Full, $Parameter)
                                Cont = @("param(")
                            } ## Head, Param, Body
                            @{
                                Name = "Example"
                                Tabs = 1
                                NewL = 1
                                True = @($Full, $Parameter)
                                Cont = @(
                                    '[parameter(Mandatory=$true,Position=0,HelpMessage="Der Übergabe String")]'
                                    '[string] $myString = "default String Value"')
                            } ## Example, Param, Body
                            @{
                                Name = "Tail"
                                Tabs = 0
                                NewL = 1
                                True = @($Full, $Parameter)
                                Cont = @(")")
                            } ## Tail, Param, Body
                        )
                    } ## Param, Body
                    @{
                        Name = "Structure"
                        Tabs = 0
                        NewL = 1
                        True = @($Full, $Structure)
                        Cont = @(
                            @{
                                Name = "Begin"
                                Tabs = 0
                                NewL = 1
                                True = @($Full, $Structure)
                                Cont = @(
                                    @{
                                        Name = "Head"
                                        Tabs = 0
                                        NewL = 1
                                        True = @($Full, $Structure)
                                        Cont = @("begin {")
                                    } ## Head, Begin, Structure, Body
                                    @{
                                        Name = "Content"
                                        Tabs = 1
                                        NewL = 1
                                        True = @($Full, $Structure)
                                        Cont = @(
                                            'Write-Verbose "--- $($MyInvocation.MyCommand) - Begin - Start"',
                                            "",
                                            'Write-Verbose "--- $($MyInvocation.MyCommand) - Begin - End"')
                                    } ## Content, Begin, Structure, Body
                                    @{
                                        Name = "Tail"
                                        Tabs = 0
                                        NewL = 0
                                        True = @($Full, $Structure)
                                        Cont = @("}")
                                    } ## Tail, Begin, Structure, Body
                                )
                            } ## Begin, Structure, Body
                            @{
                                Name = "Process"
                                Tabs = 0
                                NewL = 1
                                True = @($Full, $Structure)
                                Cont = @(
                                    @{
                                        Name = "Head"
                                        Tabs = 0
                                        NewL = 1
                                        True = @($Full, $Structure)
                                        Cont = @("process {")
                                    } ## Head, Process, Structure, Body
                                    @{
                                        Name = "Content"
                                        Tabs = 1
                                        NewL = 1
                                        True = @($Full, $Structure)
                                        Cont = @(
                                            'Write-Verbose "--- $($MyInvocation.MyCommand) - Process - Start"',
                                            "",
                                            'Write-Verbose "--- $($MyInvocation.MyCommand) - Process - End"')
                                    } ## Content, Process, Structure, Body
                                    @{
                                        Name = "Tail"
                                        Tabs = 0
                                        NewL = 0
                                        True = @($Full, $Structure)
                                        Cont = @("}")
                                    } ## Tail, Process, Structure, Body
                                )
                            } ## Process, Structure, Body
                            @{
                                Name = "End"
                                Tabs = 0
                                NewL = 1
                                True = @($Full, $Structure)
                                Cont = @(
                                    @{
                                        Name = "Head"
                                        Tabs = 0
                                        NewL = 1
                                        True = @($Full, $Structure)
                                        Cont = @("end {")
                                    } ## Head, End, Structure, Body
                                    @{
                                        Name = "Content"
                                        Tabs = 1
                                        NewL = 1
                                        True = @($Full, $Structure)
                                        Cont = @(
                                            'Write-Verbose "--- $($MyInvocation.MyCommand) - End - Start"',
                                            "",
                                            'Write-Verbose "--- $($MyInvocation.MyCommand) - End - End"')
                                    } ## Content, End, Structure, Body
                                    @{
                                        Name = "Tail"
                                        Tabs = 0
                                        NewL = 1
                                        True = @($Full, $Structure)
                                        Cont = @("}")
                                    } ## Tail, End, Structure, Body
                                )
                            } ## End, Structure, Body
                        )
                    } ## Structure, Body
                )
            } ## Body
            @{
                Name = "Tail"
                Tabs = 0
                NewL = 1
                True = @($Full)
                Cont = @("}")
            } ## Tail
        )

        ## Platzhaltersymbole für Einrückung und Zeilenumbruch
        $StringTabs = "`t"
        $StringNewL = "`r`n"

        function Join-TextArray {
        <# 
        .SYNOPSIS
            Hilfsfunktion für rekursiven Aufruf und Zusammenbau des Ausgabestrings
        .PARAMETER
        #>
            [CmdletBinding()]
            param(
                [parameter(Mandatory=$true,Position=0)]
                $Object,
                [parameter(Mandatory=$false,Position=1)]
                [uint32] $Tabs=0
            )
            process {
                Write-Verbose "--- $($MyInvocation.MyCommand) - Process - Start"

                ## Initialisieren des Rückgabetext
                [string] $ReturnText = @()

                foreach ($obj in $Object) {
                    ## Überprüfe ob es sich um ein Sammelelement handelt
                    if ($($obj.Cont | Get-Member).TypeName -eq "System.Collections.Hashtable") {
                        Write-Verbose "$($obj.Name) -> Weiter zerlegen"

                        ## Funktion rekursiv aufrufen und die Tabstops mitgeben
                        $ReturnText += (Join-TextArray $obj.Cont -Tabs ($obj.Tabs + $Tabs))
                    }
                    ## Wenn es ein String-Array ist und für die Verarbeitung ausgewählt dann wird der Text verarbeitet
                    elseif ($($obj.Cont | Get-Member).TypeName -eq "System.String" -and $obj.True -contains $true) {
                        Write-Verbose "$($obj.Name) andrucken"

                        foreach ($Line in $obj.Cont) {
                            ## Der Textinhalt wird im Array Zeile für Zeile abgearbeitet
                            $ReturnText += ($StringTabs*($obj.Tabs + $Tabs)) + $Line 

                            if ($obj.Cont.IndexOf($Line) -lt $obj.Cont.Count) {
                                ## Bei allen Elemten ausser dem letzten wird ein Zeilenvorschub angefügt
                                $ReturnText += $StringNewL
                            }
                        }
                    }

                    ## Wenn aktuell eine NewLine angefügt werden soll, prüfe auf doppel NewLine
                    if ($obj.NewL -gt 0 -and $obj.True -contains $true) {
                        if ($ReturnText -match "$StringNewL$") {
                            $ReturnText += ($StringNewL*($obj.NewL-1))
                        }
                        else {
                            $ReturnText += ($StringNewL*$obj.NewL)
                        }
                    }
                }
                ## Übergib den fertigen Text der aktuellen Instanz
                $ReturnText

                Write-Verbose "--- $($MyInvocation.MyCommand) - Process - End"
            }
        }

        Write-Verbose "--- $($MyInvocation.MyCommand) - Begin - End"
    }
    process {
        Write-Verbose "--- $($MyInvocation.MyCommand) - Process - Start"

        ## Starte die Umwandlung des Arrays
        $OutputText = Join-TextArray $FunctionStructure

        ## Füge den Ermittelten Text in den aktuellen Editor ein
        $psISE.CurrentFile.Editor.InsertText($OutputText)

        Write-Verbose "--- $($MyInvocation.MyCommand) - Process - End"
    }
}

# SIG # Begin signature block
# MIIJXAYJKoZIhvcNAQcCoIIJTTCCCUkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUCdzrLFDBfPmMOWw142Bbw0Dt
# AnOgggbQMIIGzDCCBLSgAwIBAgIKHtjtxQABAAABvjANBgkqhkiG9w0BAQsFADBH
# MRUwEwYKCZImiZPyLGQBGRYFbG9jYWwxFDASBgoJkiaJk/IsZAEZFgRlZmtvMRgw
# FgYDVQQDEw9lZmtvLUVGLURDMDEtQ0EwHhcNMTgwMzIwMTA0MzQ5WhcNMjMwMzE5
# MTA0MzQ5WjCBpTELMAkGA1UEBhMCQVQxETAPBgNVBAcTCEVmZXJkaW5nMTAwLgYD
# VQQKEydlZmtvIEZyaXNjaGZydWNodCB1bmQgRGVsaWthdGVzc2VuIEdtYmgxCzAJ
# BgNVBAsTAklUMSUwIwYDVQQDExxlZmtvIFNvZnR3YXJlIFNpZ25hdHVyZSAyMDE4
# MR0wGwYJKoZIhvcNAQkBFg5vZmZpY2VAZWZrby5hdDCCASIwDQYJKoZIhvcNAQEB
# BQADggEPADCCAQoCggEBALSIKqvZr3MEiOKluy/263oXtSWrt84cu5FZheNJg4gE
# V0QqBhn+m8zPdz6cAMzKEN8nurPHnBBYIlJ81SVfC7z3zaaQ+NCU2H6yFS4S/dTw
# Q1PjFowXHzuobXri1yKCl3FAqwPi5JclFOkOxPEJVjF26xsiLeppLGkQSjCaMkrI
# I8tWIAlZ9VCW15P+unBliaIgHFNHUl3HzcahK5/U49F2d5mmF2U00vRMnVtxMGN/
# abH+DymrRxMryIB1/6aA7axnCsTpBjhv/ZqasQPOInDQVrLWD1QGCHxzv2hWjK4s
# BnBdnCDaw9ff/Kr8cKHGJN749Pv2LDPSe3MQGmWF6w8CAwEAAaOCAlkwggJVMDwG
# CSsGAQQBgjcVBwQvMC0GJSsGAQQBgjcVCITtkHzSvUOGyY8vgey0GIb2wXdxg936
# KoTujxYCAWQCASYwEwYDVR0lBAwwCgYIKwYBBQUHAwMwDgYDVR0PAQH/BAQDAgeA
# MBsGCSsGAQQBgjcVCgQOMAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFNymGh84qixJ
# 0PehgMf04u5NQMKOMB8GA1UdIwQYMBaAFPnoqPzz1G3G9BUtBop05S9cTbMSMIHP
# BgNVHR8EgccwgcQwgcGggb6ggbuGgbhsZGFwOi8vL0NOPWVma28tRUYtREMwMS1D
# QSgxKSxDTj1FRi1EQzAxLENOPUNEUCxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2aWNl
# cyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPWVma28sREM9bG9jYWw/
# Y2VydGlmaWNhdGVSZXZvY2F0aW9uTGlzdD9iYXNlP29iamVjdENsYXNzPWNSTERp
# c3RyaWJ1dGlvblBvaW50MIHABggrBgEFBQcBAQSBszCBsDCBrQYIKwYBBQUHMAKG
# gaBsZGFwOi8vL0NOPWVma28tRUYtREMwMS1DQSxDTj1BSUEsQ049UHVibGljJTIw
# S2V5JTIwU2VydmljZXMsQ049U2VydmljZXMsQ049Q29uZmlndXJhdGlvbixEQz1l
# ZmtvLERDPWxvY2FsP2NBQ2VydGlmaWNhdGU/YmFzZT9vYmplY3RDbGFzcz1jZXJ0
# aWZpY2F0aW9uQXV0aG9yaXR5MA0GCSqGSIb3DQEBCwUAA4ICAQAfidCB9iTuGnx/
# Gc00xhMBrFB6eoL0UHgF+T4oC7PkQWdb/Up4dfRqF0DQzazLfPnQdysmOWs/eahV
# 9gFu1lSY8bRJD6Jl2Fz5dHWtiR+FMw6stKkxq6+gGOa/NYX9KbZnxoJdRa1LgUi/
# /TT3jlw6Yc3KtYxX/rvmEnPji2soLkQf0oWpQ+hWTPl1dYUW/Tq3GbRmLkBx1phD
# P1Vfp9wqVWDKoSJOVntZWeEKFDqTL+3segSs2gzsjh0Zpe64mWCeIFlLw8JenZlF
# Lq5vmjr702rQ97RW3APOyNCM5hEjBrj+Ut9DHFQ8kKmA+R4ZhYNfUwViKZQ+Tp0+
# kPaJLDKLdPZIvzkUPAibkg1VktY/DRx4NC/+2BEEdQBVHAAzR7vq0Te+gV/yFvrs
# xf6D+rXq3K0HJs3mX3y6IaGBYsCh3ipb2xnr1twD282uB49u+wkVE8MIX8Bsmi66
# lhukxc32/5pNQvl9S4julzl5yE4ji5HjOvXPz2JqtaCZpxz19MzkFviAD73P9r2p
# Q+Bxxe4mjrb7ehJJJ0wxBIQvnj2bQFidTw+D8iw5TTp6Z0APR5AtPym43f250KdL
# j8VW4851JgkwhmEAOFQqreEhbSTbLD3B6LUNeY5IFRzSa+agOh57HGzlCY9bW/lo
# 6UjeSDZfG82TCf89Li1cv3HodsUp3jGCAfYwggHyAgEBMFUwRzEVMBMGCgmSJomT
# 8ixkARkWBWxvY2FsMRQwEgYKCZImiZPyLGQBGRYEZWZrbzEYMBYGA1UEAxMPZWZr
# by1FRi1EQzAxLUNBAgoe2O3FAAEAAAG+MAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3
# AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisG
# AQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQ3lhnca7GK
# baOsICfQvDOq6fKFQzANBgkqhkiG9w0BAQEFAASCAQCmoSRoB/y3hUa4iA1/qdh5
# CN8k+tkUqhFkkqWETJ5ZGj3XpK7ItvMZDYsxtiU/KRUeViD+OEjulzrV1uCcCz2h
# RdK4q7PxddjOVSlFBKhYpEYNauUZKmM69eU7QieB97rp1NyocQkPO6dnFNHnWJFS
# PwJszSnkfC3TJ69BrWIkd8mO+gbuj13pllTWBMSNa6N0Vrq5cbm+EBz9zGeL+4GX
# Bnjx/LO2tHG087jo16+r6s3DpnwQ+9tgqww8CfaVGmseTZd5WShcuo5UbUpAyZn8
# youHtWhbf7nNgw/g/WP8rhzoYhmnwJvWmbJV7mI31WYfkh/TcJ5s0vDFcv6yek/q
# SIG # End signature block
