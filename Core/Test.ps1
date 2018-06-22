. (Join-Path $PSScriptRoot "\Libs\MAST-Core_ClassLoader.ps1")
. (Join-Path $PSScriptRoot "\Data\MAST-CoreData_Dictionary.ps1")

Remove-Variable MASTCore -Force

$MASTCore = [MASTCore]::new()
$MASTCore.LoadDictionary("de-AT",$MASTDictionaryDEAT)
$MASTCore.LoadDictionary("de-DE",$MASTDictionaryDEDE)
$MASTCore.LoadDictionary("de",$MASTDictionaryDE)
$MASTCore.LoadDictionary("en",$MASTDictionaryEN)

$MASTCore.Translator.SetLanguage("es-es")

#Remove BOM
#($a -replace "^$([convert]::ToChar(65279))" , "")[0]