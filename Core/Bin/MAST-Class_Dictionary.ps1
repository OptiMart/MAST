class MASTDictionary
{
    hidden [hashtable] $Dict
    [cultureinfo] $Culture

    MASTDictionary ([cultureinfo] $Culture, [hashtable] $Dict)
    {
        $this.Dict = $Dict
        #$this.Dict = New-Object psobject -Property $Dict
        $this.Culture = $Culture
    }

    [void] AddText ($obj)
    {
        $this.Dict = [MASTUtilities]::MergeHashtables(@($this.Dict, $obj),{$_[-1]})
    }

    [string] GetText ([string] $Tag)
    {
        try
        {
            $RetText = $this.Dict.$Tag
        }
        catch
        {
            $RetText = ""
        }

        return $RetText
    }

    [string] ToString ()
    {
        return $this.Culture.DisplayName
    }
}
