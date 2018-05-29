Dieser Ordner dient nur als Ablage für ausführbare Skript-Dateien.
Um auf diese von anderen Programmen zu verweisen.

Z.B. kann in der GPP "Skript ausführen (Start-Herunterfahren)" nur eine Tatsächliche Skriptdatei ausgewählt werden

Beispiel (Einbinden Dot-Sourcing und direktes Ausführen):
  . (Join-Path $MASTPath.Liv.Lib "PS-Func_Send-MailEfkoGroup.ps1")
  Send-MailEfkoGroup -Subject "Achtung"

  Diese Datei kann dann direkt ausgeführt werden und schickt eine Mail mit den Standardwerten und dem Betreff "Achtung"

Beispiel