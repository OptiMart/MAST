# Klasse definieren
class MASTDict
{
    [string] $Language
    hidden [string] $ParentLang

    hidden [hashtable] $MASTDictionary = @{
        "TEXT_YES" = @{
            default = "Yes"
            en_US = "Yes"
            de_DE = "Ja"
        }
        "TEXT_NO" = @{
            default = "No"
            en_US = "No"
            de_DE = "Nein"
        }
    }

    # Konstruktor
    MASTDict ([string] $Lang)
    {
        $this.SetLanguage($Lang)
    }

    # Konstruktor
    MASTDict ()
    {
        $this.SetLanguage([cultureinfo]::CurrentUICulture.Name)
    }
                
    # Set Output Language
    [void] SetLanguage([string] $Lang)
    {
        $this.Language = $Lang -replace "-", "_"
        $this.ParentLang = ($this.Language -split "_")[0]
    }
                
    # Get translated Text
    [string] Text([string] $Text)
    {
        ## initialisiere Returnwert
        [string] $RetText = ""

        ## Laden den Text mit dem übergebenen Platzhalter
        try
        {
            $TextObj = $this.MASTDictionary.$Text
        }
        catch
        {
            ## Wenn der Text nicht angelegt ist wird der Suchstring zurückgegeben
            $RetText = $Text
            return $Text
        }

        ## Versuche den Text in der gewünschten Sprache zu erhalten
        try
        {
            $RetText = $TextObj.$($this.MASTLanguage)
            return $RetText
        }
        catch
        {}

        ## Versuche den Text in der Übergeordneten Sprache zu erhalten
        try
        {
            $RetText = ($TextObj.GetEnumerator() | Where-Object Name -Match "^$($this.ParentLang)_" | Select-Object -First 1).Value
            return $RetText
        }
        catch
        {
            ## Wenn der Text auch nicht in einer übergeordneten Sprache gefunden wurde dann wird der default wert zurückgegeben
            $RetText = $TextObj.default
        }

        return $RetText
    }
}
