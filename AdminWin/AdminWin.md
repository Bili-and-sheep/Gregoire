# Partie 1
## A
### 1 -
### 2 - 
```powershell
Color -
    0 = Noir        8 = Gris
    1 = Bleu        9 = Bleu clair
    2 = Vert        A = Vert clair
    3 = Bleu-gris   B = Cyan
    4 = Rouge       C = Rouge clair
    5 = Violet      D = Violet clair
    6 = Jaune       E = Jaune clair
    7 = Blanc       F = Blanc brillant
```
### 3 - 
```powershell
date
```
### 4 - 
```powershell
TASKLIST
cmd.exe                      32056 RDP-Tcp#0                  2     5 936 Ko
```

### 5 -
```powershell
START  /max notepad.exe
START  /min notepad.exe
```

### 6 -
```powershell
TASKLIST
Notepad.exe                  34392 RDP-Tcp#0                  2   114 472 Ko
TASKKILL /PID 34392
```

### 7 -
```powershell
vol c:
 Le volume dans le lecteur C n’a pas de nom.
 Le numéro de série du volume est D6E7-26B0
```

### 8 -
```powershell
VER
Version du système d’exploitation:          10.0.26100 N/A build 26100
```

### 9 -
```powershell
systeminfo
Mémoire physique totale:                    65 459 Mo
Mémoire physique disponible:                54 395 Mo
Mémoire virtuelle : taille maximale:        69 555 Mo
Mémoire virtuelle : disponible:             57 778 Mo
Mémoire virtuelle : en cours d’utilisation: 11 777 Mo
```

### 10 -
```powershell
doskey /listsize=<size>
```

### 11 -
```powershell
VER && chdir
```

### 12 -
```powershell
date >  && chdir
```

### 13 - Affiche l'utlisateur actif

### 14 - Performs operations on registry subkey information and values in registry entries

### 15 - Schedule programm
Programme la copie d'un fichier vers un server (pour de la redondance)

### 16 - 
```powershell
.exe=Exefile
.ost=Outlook.File.ost.15
.rtf=Word.RTF.8
.scp=SPCFile
.vbs=VBSFile
.vsd=VisioViewer.Viewer
```


## B
### 1 -
### 2 -
### 3 -
### 4 -
```powershell
DIR
```
### 5 -
```powershell
attrib test.txt
A                    C:\Users\Andre\Desktop\TP_EA\TP_CMD\test.txt
```

### 6 -
```powershell
attrib +R test.txt

attrib test.txt
A    R               C:\Users\Andre\Desktop\TP_EA\TP_CMD\test.txt

echo fichier wiliiiiiii > test.txt
Accès refusé.
```
### 7 - Crée un fichier avec contenue vide par défault
### 8 -
```powershell
echo fichier nul > essai.dat
```

### 8 -
```powershell
RENAME
RENAME essai.dat essai1.dat
```

### 9 -
```powershell
COPY
COPY essai1.dat essai2.dat
```

### 10 -
```powershell
COPY
COPY essai1.dat essai2.dat
```