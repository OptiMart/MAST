Dieser Ordner dient nur als Ablage f�r ausf�hrbare Skript-Dateien.
Um auf diese von anderen Programmen zu verweisen.

Z.B. kann in der GPP "Skript ausf�hren (Start-Herunterfahren)" nur eine Tats�chliche Skriptdatei ausgew�hlt werden

Beispiel (Einbinden Dot-Sourcing und direktes Ausf�hren):
  . (Join-Path $MASTPath.Liv.Lib "PS-Func_Send-MailEfkoGroup.ps1")
  Send-MailEfkoGroup -Subject "Achtung"

  Diese Datei kann dann direkt ausgef�hrt werden und schickt eine Mail mit den Standardwerten und dem Betreff "Achtung"

Beispiel