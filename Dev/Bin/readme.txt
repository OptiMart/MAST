Dieser Ordner dient nur als Ablage für ausführbare Skript-Dateien.
Um auf diese von anderen Programmen zu verweisen.

Z.B. kann in der GPP "Skript ausführen (Start-Herunterfahren)" nur eine Tatsächliche Skriptdatei ausgewählt werden

Beispiel (Einbinden Dot-Sourcing und direktes Ausführen):
  . (Join-Path $MASTPath.Liv.Lib "PS-Func_Test-MS17-010.ps1")
  Test-MS17-010.ps1

  Diese Datei kann dann direkt ausgeführt werden und Testet die auf die Schwachstelle MS17-010
