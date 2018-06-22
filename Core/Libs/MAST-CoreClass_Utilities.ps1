class MASTUtilities
{
    static [hashtable] MergeHashtables($HashTables, [ScriptBlock] $Operator)
    {
        ## Merge Hastables
        $Output = [MASTUtilities]::MergeHashtables($HashTables)

        ## Apply Operator on Keys
        foreach ($Key in @($Output.Keys))
        {
            $_ = @($Output.$Key)
            $Output.$Key = Invoke-Command $Operator
        }

        ## Return Hastable
        return $Output

    }

    static [hashtable] MergeHashtables($HashTables)
    {
        ## Initialise Return Hastable
        $Output = @{}

        ## Process all Input Hastables
        foreach ($Hashtable in $HashTables)
        {
            if ($Hashtable -is [hashtable])
            {
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

        ## Return Hastable
        return $Output
    }

    MASTUtilities ()
    {
        
    }
}