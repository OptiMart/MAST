Dieser Ordner dient nur als Ablage f�r ausf�hrbare Skript-Dateien.
Um auf diese von anderen Programmen zu verweisen.

Z.B. kann in der GPP "Skript ausf�hren (Start-Herunterfahren)" nur eine Tats�chliche Skriptdatei ausgew�hlt werden

Beispiel (Einbinden Dot-Sourcing und direktes Ausf�hren):
  . (Join-Path $MASTPath.Liv.Lib "PS-Func_Test-MS17-010.ps1")
  Test-MS17-010.ps1

  Diese Datei kann dann direkt ausgef�hrt werden und Testet die auf die Schwachstelle MS17-010
