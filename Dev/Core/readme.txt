Hier liegen die Kerndateien für das Managing&Administrating Scripts-Tool (MAST)

MAST-Local-Profile.ps1
  Dies ist die Profil-Datei die an einen lokalen Profilpfad als profile.ps1 kopiert werden muss
  Sie wird automatisch aus dem Live-Verzeichnis per GPO (EfGrSePowershellProfile) in AllUsersAllHosts kopiert

MAST-Core_Loader*.ps1
  Sind die MAST-Loader Dateien die vom profile.ps1 je nach Situation (Version) geladen werden

MAST-CoreData_*.ps1
  Sind Dateien mit Variablen ähnlich dem Ordner (Data)

MAST-CoreFunc_*.ps1
  Sind Dateien mit Kernfunktionen die automatisch eingebunden werden