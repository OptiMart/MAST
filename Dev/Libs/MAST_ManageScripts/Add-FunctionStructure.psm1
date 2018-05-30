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
