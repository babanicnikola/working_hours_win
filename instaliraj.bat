@echo off
echo instalacija u toku
echo ..................
md "c:\Projekat Radni Sati"
copy db.mdb "c:\Projekat Radni Sati\db.mdb"
copy "Radni Sati.exe" "c:\Projekat Radni Sati\Radni Sati.exe"
cls
echo Instaliracija zavrsena!
pause