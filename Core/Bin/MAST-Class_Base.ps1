class MASTBase
{
    static [version] $Version = [version]::new(1,1,1,0)
    static [string] $Name = "Manage & Administrate Scripts - Tool"
    hidden [MASTTranslator] $Translator = [MASTTranslator]::new()
    hidden [MASTLoader] $Loader
    hidden [bool] $IsOnline

    MASTBase ()
    {
        
    }

    MASTBase ([string] $Lang)
    {
        $this.Translator.SetLanguage($Lang)
    }

    static [hashtable] MergeHashtables ($HashTables)
    {
        return [MASTUtilities]::MergeHashtables($HashTables, {$_[0]})
    }

    static [hashtable] MergeHashtables ($HashTables, [ScriptBlock] $Operator)
    {
        return [MASTUtilities]::MergeHashtables($HashTables, $Operator)
    }

    [void] LoadDictionary ([string] $Lang, $Dictionary)
    {
        $this.Translator.LoadDictionary($Lang, $Dictionary)
    }

    [string] GetText ([string] $String)
    {
        return $this.Translator.GetText($String)
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
