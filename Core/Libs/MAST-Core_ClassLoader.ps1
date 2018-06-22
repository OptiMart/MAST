if (!("MASTCore" -as [type]))
{
    . (Join-Path $PSScriptRoot "MAST-CoreClass_Utilities.ps1")
    . (Join-Path $PSScriptRoot "MAST-CoreClass_Dictionary.ps1")
    . (Join-Path $PSScriptRoot "MAST-CoreClass_Loader.ps1")
    . (Join-Path $PSScriptRoot "MAST-CoreClass_MASTCore.ps1")
}