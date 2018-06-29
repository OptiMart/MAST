class MASTTranslator
{
    hidden [cultureinfo] $DefaultLanguage = "en"
    hidden [cultureinfo] $ActiveLanguage
    hidden [MASTDictionary[]] $Dictionaries

    # Constructor Set Userdefined active target language
    MASTTranslator ([string] $Lang)
    {
        $this.SetLanguage($Lang)
    }

    # Constructor Set current OS language as active target language
    MASTTranslator ()
    {
        $this.SetLanguage([cultureinfo]::CurrentCulture)
    }
    
    # Add a new Dictionary (add/overwrite)
    [bool] AddDictionary ([string] $Lang, $Dictionary)
    {
        ## Check ob korrekte Sprache
        if ([cultureinfo]::GetCultures([System.Globalization.CultureTypes]::AllCultures).Name -eq $Lang)
        {
            $DictLang = [cultureinfo]::new($Lang)
        }
        elseif ([cultureinfo]::GetCultures([System.Globalization.CultureTypes]::AllCultures).Name -eq ($Lang -replace "_", "-"))
        {
            $DictLang = [cultureinfo]::new($Lang -replace "_", "-")
        }
        else
        {
            return $false
        }
        
        ## Create new Dictionary
        $NewDict = [MASTDictionary]::new($DictLang, $Dictionary)

        ## Check if already loaded
        if ($this.LanguageIsLoaded($DictLang))
        {
            $this.GetDictionary($DictLang) = $NewDict
        }
        else
        {
            $this.Dictionaries += $NewDict
        }

        return $true
    }


    [void] AddText ([cultureinfo] $Lang, [hashtable] $obj)
    {
        if ($this.LanguageIsLoaded($Lang))
        {
            $this.GetDictionary($Lang).AddText($obj)
        }
        else
        {
            $this.Dictionaries += [MASTDictionary]::new($Lang, $obj)
        }
    }

    [MASTDictionary] GetDictionary ([cultureinfo] $Lang)
    {
        if (-not $this.LanguageIsLoaded($Lang))
        {
            $this.AddDictionary($Lang, @{})
        } 

        return $this.Dictionaries | Where-Object Culture -EQ $Lang
    }

    <#[bool] AddDictionary ([string] $Lang, [string] $Path)
    {
        return $this.AddDictionary($Lang, $Path, "MASTDictionary")
    }#>
    
    ## Lists all Loaded Languages
    [cultureinfo[]] GetLoadedLanguages ()
    {
        [cultureinfo[]] $RetVal = @()

        foreach ($Dict in $this.Dictionaries)
        {
            $RetVal += $Dict.Culture
        }

        return $RetVal
    }

    [bool] LanguageIsLoaded ([cultureinfo] $Lang)
    {
        return ($this.GetLoadedLanguages() -contains $Lang)
    }

    # Set active targetlLanguage
    [void] SetLanguage([string] $Lang)
    {
        ## Check ob korrekte Sprache
        if ([cultureinfo]::GetCultures([System.Globalization.CultureTypes]::AllCultures).Name -eq $Lang)
        {
            $this.ActiveLanguage = [cultureinfo]::new($Lang)
        }
        elseif ([cultureinfo]::GetCultures([System.Globalization.CultureTypes]::AllCultures).Name -eq ($Lang -replace "_", "-"))
        {
            $this.ActiveLanguage = [cultureinfo]::new($Lang -replace "_", "-")
        }
        else
        {
            throw "The Language $Lang does not exist"
        }
    }
                
    # Get translated Text
    [string] GetText([string] $Text)
    {
        ## initialisiere Returnwert
        [string] $RetText = ""

        #if ($this.GetDictionary($this.ActiveLanguage))
        #{
            ## Lade den Text mit dem übergebenen Platzhalter
            $RetText = $this.GetDictionary($this.ActiveLanguage).GetText($Text)
        #}
        
        
        ## Lade den Text aus der Parent Culture
        if (-not $RetText -and $this.GetDictionary($this.ActiveLanguage.Parent))
        {
            $RetText = $this.GetDictionary($this.ActiveLanguage.Parent).GetText($Text)
        }

        ## Lade den Text aus einer anderen Sprache mit gleicher Parent
        if (-not $RetText)
        {
            $SimCult = $this.GetLoadedLanguages() | Where-Object {$_.Name -Match "^$($this.ActiveLanguage.Parent)-" -and $_ -ne $this.ActiveLanguage } | Sort-Object -Property LCID | Select-Object -First 1
            
            if ($SimCult) {
                $RetText = $this.GetDictionary($SimCult).GetText($Text)
            }
        }

        ## Lade aus der default Language
        if (-not $RetText -and $this.GetDictionary($this.DefaultLanguage))
        {
            $RetText = $this.GetDictionary($this.DefaultLanguage).GetText($Text)
        }

        if (-not $RetText)
        {
            $RetText = $Text
        }

        ## Return Outputtext
        return $RetText
    }

    [string] ToString() {
        return "MAST Translator - Target Language $($this.ActiveLanguage.DisplayName)"
    }
}
