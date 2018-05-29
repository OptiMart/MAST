. (Join-Path $PSScriptRoot "MAST-CoreClass_Dictionary.ps1")
. (Join-Path $PSScriptRoot "MAST-CoreClass_Loader.ps1")
. (Join-Path $PSScriptRoot "MAST-CoreClass_MASTCore.ps1")

$MASTDictionaryDEAT = @{
    "TEXT_YES" = "Yup"
    "TEXT_NO" = "Nada"
}

$MASTDictionaryDEDE = @{
    "TEXT_TEST" = "Mein Test"
    "TEXT_YES" = "Ja"
    "TEXT_NO" = "Nein"
    "TEXT_DE" = "DEEE"
}

$MASTDictionaryEN = @{
    "TEXT_YES" = "Yes"
    "TEXT_NO" = "No"
    "TEXT_EN" = "EN"
}

$MASTDictionaryDe = @{
    "TEXT_YES" = "D_Yes"
    "TEXT_NO" = "D_No"
    "TEXT_DEF" = "Default"
}

Remove-Variable MASTCore -Force

$MASTCore = [MASTCore]::new()
$MASTCore.LoadDictionary("de-AT",$MASTDictionaryDEAT)
$MASTCore.LoadDictionary("de-DE",$MASTDictionaryDEDE)
$MASTCore.LoadDictionary("de",$MASTDictionaryDE)
$MASTCore.LoadDictionary("en",$MASTDictionaryEN)

$MASTCore.Translator.SetLanguage("es-es")