Ordnerstruktur

.\Libs\
  -> Ordner mit allgemeinen Modulen und Funktionen (*.psm1, *.ps1)
     So allgemein wie m�glich gehalten um dann in verschiedenen Szenarien benutzt werden zu k�nnen

.\Includes\
  -> Ordner mit den direkt nachzuladenden Skripten
     Die Dateien werden �ber ihren Dateinamen Usern/Computern zugewiesen

.\Data\
  -> Ordner mit Dateien die nur Variablen enthalten
     Hier k�nnen Variablen leicht erweitert/angepasst werden um f�r Allgemeine Funktionen zur Verf�gung zu stehen

.\Bin\
  -> Ordner mit Skriptdateien mit direkt ausf�hrbarem Code

.\Core\
  -> Ordner mit allen Kern-Dateien f�r den MAST-Loader
