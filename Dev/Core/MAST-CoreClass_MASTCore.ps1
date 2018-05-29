class MASTCore
{
    static [version] $Version = [version]::new(1,1,1,0)
    static [string] $Name = "Manage & Administrate Scripts - Tool"
    hidden [MASTTranslator] $Translator = [MASTTranslator]::new()
    hidden [MASTLoader] $Loader
    hidden [bool] $IsOnline

    MASTCore ()
    {
        #$this.Dictionary = [MASTDict]::new()
    }

    MASTCore ([string] $Lang)
    {
        #$this.Dictionary = [MASTDict]::new($Lang)
    }

    static [hashtable] MergeHashtables ($Input, [ScriptBlock] $Operator)
    {
        $Output = @{}
        foreach ($Hashtable in $Input)
        {
            if ($Hashtable -is [Hashtable]) {
                foreach ($Key in $Hashtable.Keys) {
                    $Output.$Key = if ($Output.ContainsKey($Key))
                    {
                        @($Output.$Key) + $Hashtable.$Key
                    }
                    else
                    {
                        $Hashtable.$Key
                    }
                }
            }
        }

        if ($Operator)
        {
            foreach ($Key in @($Output.Keys))
            {
                $_ = @($Output.$Key)
                $Output.$Key = Invoke-Command $Operator
            }
        }
    
        return $Output
    }

    static [hashtable] MergeHashtables ($Input)
    {
        return [MASTCore]::MergeHashtables($Input, {$_})
    }

    [void] LoadDictionary ([string] $Lang, $Dictionary)
    {
        $this.Translator.LoadDictionary($Lang, $Dictionary)
    }

    [string] GetText ([string] $s)
    {
        return $this.Translator.GetText($s)
    }

    [bool] IsOnline ()
    { 
        return $this.IsOnline
    }

    [string] ToString ()
    {
        return "$($this::Name) (Ver. $($this::Version))"
    }
}
