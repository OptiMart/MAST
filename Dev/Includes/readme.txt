Powershelldateien in diesem Ordner werden automatisch geladen.
Es können beliebige Unterordner zur besseren Verwaltung angelegt werden.

Die Dateien werden anhand ihres Dateinamens zugeordnet.
Jede zu ladende Datei muss einen Dateinamen in folgendem Format haben:

PS_xxxxxx_ABCDEF.ps1

xxxxxx ... ist der Platzhalter für die Zuordnung (nicht Casesensitive)
ABCDEF ... ist ein Beschreibender Name für den zu ladenden Inhalt

xxxxxx -> Variablen

-) global -> wird von jedem geladen
   zB: PS_global_NotwendigeFunktionen.ps1

-) "Standort" -> wird von den Computern auf dem zutreffenden AD-Site geladen
   zB: PS_Wien_AllgemeineFunktionen.ps1 wird von allen Computern am Standort Wien geladen

-) "Computername" -> Wird von dem Computer mit dem entsprechenden Namen geladen
   zB: PS_ef-dc01_TaskFunktionen.ps1 wird nur vom Computer ef-dc01 (efko Domänencontroller) geladen

-) "Username" -> Wird nur von dem User mit dem entsprechenden Namen geladen
   zB: PS_adminvit_StandardFunktionen.ps1 wird nut vom Benutzer AdminVIT geladen

-) "Gruppen" -> wird aus dem Pfad HKCU:\Software\efko\PS\Gruppen und HKLM:\Software\efko\PS\Gruppen geladen
   Die dort hinterlegten Strings (getrennt durch ";" und ",") werden als Pattern verwendet
   PS_GrpString_SpezifischeFunktion.ps1

-) "Remote" -> Wird bei Remotesitzungen mit dem RemoteProfile geladen

Die Scripte sollten immer nur Funktionen beinhalten und keinen direkt ausführbaren Code
Es sei denn es ist definitiv so beabsichtigt (z.B. laden weiterer Module/Scripte)

Wenn nicht anders auf den Computern eingestellt akzeptieren sie die Scripte nur wenn sie signiert sind

