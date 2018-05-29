class MASTLoader
{

    MASTLoader ()
    {
        #$this.Dictionary = [MASTDict]::new()
    }

    MASTLoader ([string] $Lang)
    {
        #$this.Dictionary = [MASTDict]::new($Lang)
    }

}
