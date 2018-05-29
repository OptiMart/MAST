In diesem Ordner werden alle Skripte mit "n�tzlichen" Funktionen zentral abgespeichert.
Der Grundgedanke ist, dass die Funktionen hier so allgemein geschrieben werden wie m�glich um in mehreren Situationen angewandt werden zu k�nnen.
Diese Funktionen k�nnen dann mit verschiedenen Parametern gestartet bzw. im .\Includes Ordner f�r bestimmte Zwecke vorbereitet werden.

Hier werden alle zentralen Funktionen abgespeichert

-) Powershell Module
  Module m�ssen in eigenen Unterordnern angelegt werden ->
  .\Libs\PowerShellModul1\PowerShellModul1.psd1

-) Einzelne Skripte mit einer Funktion
  Funktionen werden in einfachen Scriptdateien abgespeichert (*.ps1)
  Diese beinhalten genau eine Funktion und die Datei hat genau den selben Namen
  Funktion: Get-VitanaUser
  Dateiname: PS-Func_Get-VitanaUser.ps1

  Nat�rlich k�nnen in diesen Funktionen auch verschachtelte "unter" Funktionen enthalten sein.
  Der Wiederverwertbarkeit zuliebe w�re es oft sinnvoll solche Funktionen separat zu schreiben.

-) Sammlungen von Zusammengeh�rigen Funktionen
  Manchmal kann es Sinn machen mehrere Funktionen zum selben Thema in eine Skript-Datei zu Packen
  Diese Dateien sollten dann den Pr�fix "PS-FuncColl_Ueberbegriff.ps1" bekommen.
  Der Name des �berbegriffs sollte so sprechend wie m�glich gew�hlt werden.

Die Namensgebung in Powershell erfolgt nach dem Verb-Noun Prinzip.
Die allgemeinen Funktionen in diesem Ordner sollten auch nach diesem Prinzip benannt werden.

Eine Liste mit den "g�ltigen" Verben erh�lt man in Powershell �ber den Befehl "verb"
