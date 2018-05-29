Ordnerstruktur

.\Libs\
  -> Ordner mit allgemeinen Modulen und Funktionen (*.psm1, *.ps1)
     So allgemein wie möglich gehalten um dann in verschiedenen Szenarien benutzt werden zu können

.\Includes\
  -> Ordner mit den direkt nachzuladenden Skripten
     Die Dateien werden über ihren Dateinamen Usern/Computern zugewiesen

.\Data\
  -> Ordner mit Dateien die nur Variablen enthalten
     Hier können Variablen leicht erweitert/angepasst werden um für Allgemeine Funktionen zur Verfügung zu stehen

.\Bin\
  -> Ordner mit Skriptdateien mit direkt ausführbarem Code

.\Core\
  -> Ordner mit allen Kern-Dateien für den MAST-Loader
