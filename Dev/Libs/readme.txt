In diesem Ordner werden alle Skripte mit "nützlichen" Funktionen zentral abgespeichert.
Der Grundgedanke ist, dass die Funktionen hier so allgemein geschrieben werden wie möglich um in mehreren Situationen angewandt werden zu können.
Diese Funktionen können dann mit verschiedenen Parametern gestartet bzw. im .\Includes Ordner für bestimmte Zwecke vorbereitet werden.

Hier werden alle zentralen Funktionen abgespeichert

-) Powershell Module
  Module müssen in eigenen Unterordnern angelegt werden ->
  .\Libs\PowerShellModul1\PowerShellModul1.psd1

-) Einzelne Skripte mit einer Funktion
  Funktionen werden in einfachen Scriptdateien abgespeichert (*.ps1)
  Diese beinhalten genau eine Funktion und die Datei hat genau den selben Namen
  Funktion: Get-VitanaUser
  Dateiname: PS-Func_Get-VitanaUser.ps1

  Natürlich können in diesen Funktionen auch verschachtelte "unter" Funktionen enthalten sein.
  Der Wiederverwertbarkeit zuliebe wäre es oft sinnvoll solche Funktionen separat zu schreiben.

-) Sammlungen von Zusammengehörigen Funktionen
  Manchmal kann es Sinn machen mehrere Funktionen zum selben Thema in eine Skript-Datei zu Packen
  Diese Dateien sollten dann den Präfix "PS-FuncColl_Ueberbegriff.ps1" bekommen.
  Der Name des Überbegriffs sollte so sprechend wie möglich gewählt werden.

Die Namensgebung in Powershell erfolgt nach dem Verb-Noun Prinzip.
Die allgemeinen Funktionen in diesem Ordner sollten auch nach diesem Prinzip benannt werden.

Eine Liste mit den "gültigen" Verben erhält man in Powershell über den Befehl "verb"
