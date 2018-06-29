if (!("MASTUtilities" -as [type]))
{
    . (Join-Path $PSScriptRoot "MAST-CoreClass_Utilities.ps1")
}

if (!("MASTDictionary" -as [type]))
{
    . (Join-Path $PSScriptRoot "MAST-CoreClass_Dictionary.ps1")
}

if (!("MASTTranslator" -as [type]))
{
    . (Join-Path $PSScriptRoot "MAST-CoreClass_Translator.ps1")
}

if (!("MASTPath" -as [type]))
{
    . (Join-Path $PSScriptRoot "MAST-CoreClass_Path.ps1")
}

if (!("MASTLoader" -as [type]))
{
    . (Join-Path $PSScriptRoot "MAST-CoreClass_Loader.ps1")
}

if (!("MASTBase" -as [type]))
{
    . (Join-Path $PSScriptRoot "MAST-CoreClass_Base.ps1")
}