# TP_Administration et création d'objets ADDS
[TP4-ADDS.pdf](PDF/TP4-ADDS.pdf)


## Partie 1 : ACTIVATION DE LA CORBEILLE AD
OK

## Partie 2 : CREATION D'OBJETS (via interface graphique)

1. Création d'une OU test  
OK 


2. Création d'un utilisateur test  
OK


3. Création d'un ordinateur test  
OK


4. Création d'un groupe test  
OK


5. Ajout d'un membre au groupe Test  
OK


## Partie 3 : CREATION D'OBJETS (automatisation via commandes)

1. **Automatiser la création de comptes d'utilisateurs**  
SO BECAUSE WINDOWS IS THE WORST OPERATING SYSTEME OF THE LAST DECADE.  
IF FOR SOME REASON THE SCRIPT DON'T WORK BUT IS SHEMATICLY CORRECT YOU NEED
TO JUST CREATE A NEED FILE.BASH PASTE THE CONTENTE FROM ONE TO AN OTHER AND BOOM
MAGIC IT WORK NOW

```powershell
dn,objectClass,givenName,sn,sAMAccountName,userPrincipalName,userAccountControl
"CN=Jean PEUPLU,OU=Test-TP,DC=Bertrand,DC=local",user,Jean,PEUPLU,JP,jpeuplu@Bertrand.local,514
"CN=Elie HARIVERA,OU=Test-TP,DC=Bertrand,DC=local",user,Elie,HARIVERA,EH,eharivera@Bertrand.local,514
"CN=Mehdi TUNPEUX,OU=Test-TP,DC=Bertrand,DC=local",user,Medhi,TUNPEUX,MT,mtunpeux@madealaine.local,514
"CN=Ella REUSSI,OU=Test-TP,DC=Bertrand,DC=local",user,Hella,REUSSI,ER,hreussi@Bertrand.local,514
"CN=ALAIN PROVISTE,OU=Test-TP,DC=Bertrand,DC=local",user,Alain,Proviste,AP,aproviste@Bertrand.local,514
"CN=Alex AMIN,OU=Test-TP,DC=Bertrand,DC=local",user,Alex,AMIN,AA,aamin@Bertrand.local,514
"CN=Alex SEPSION,OU=Test-TP,DC=Bertrand,DC=local",user,Alex,SEPSION,AS,asepsion@Bertrand.local,514
```

2. **Création d'un groupe avec DSadd**  
```powershell
dsadd group "CN=DSTest, OU=Test-TP, DC=Bertrand, DC=local" -samid DSTest -secgrp yes -scope g
```

secgrp : A security group (yes) or a distribution group (no) default=Yes.
scope : Domain local (l), global (g), or universal (u)   default=g

3.  **Modification des appartenances au groupe avec DSmod**

```powershell
dsmod group "CN=Test, OU=Test-TP, DC=Bertrand, DC=local" -addmbr
"CN=Jean PEUPLU, OU=Test-TP, DC=Bertrand, DC=local" "CN=DSTest, OU=Test-TP, DC=Bertrand, DC=local"
```

```powershell
dsmod group "CN=DSTest,OU=Test-TP,DC=Bertrand,DC=local" -addmbr
"CN=Jean PEUPLU, OU=Test-TP, DC=Bertrand, DC=local" "CN=DSTest, OU=Test-TP, DC=Bertrand,DC=local"
"CN=Alex AMIN, OU=Test-TP, DC=Bertrand, DC=local" "CN=DSTest, OU=Test-TP, DC=Bertrand, DC=local"
```

4. **Affichage des appartenances au groupe avec DSget**

   * Show the member of a group
```powershell
dsget group "CN=Test, OU=Test-TP, DC=Bertrand, DC=local" -members
```
    * Show the member of a group with expansion (nested groups)
```powershell
dsget group "CN=Test, OU=Test-TP, DC=Bertrand, DC=local" -members -expand
```

Appartance d'un user au groupe

```powershell
dsget user "CN=Elie HARIVRA, OU=Test-TP, DC=Bertrand, DC=local" -memberof
```

5. **Modification de l'appartenance aux groupes avec LDIFDE**

```powershell
dn: CN=Test,OU=Test-TP,DC=Bertrand,DC=local
changetype: modify
add: member
member: CN=Elie HARIVERA,OU=Test-TP,DC=Bertrand,DC=local
member: CN=Mehdi TUNPEUX,OU=Test-TP,DC=Bertrand,DC=local
-

dn: CN=Test,OU=Test-TP,DC=Bertrand,DC=local
changetype: modify
delete: member
member: CN=Jean JB. BON,OU=Test-TP,DC=Bertrand,DC=local
-
```
```cmd
ldifde -i -f "%userprofile%\documents\GroupModif.ldf"
```

Error in the question 4
Dans le composant logiciel enfichable Utilisateurs et ordinateurs Active Directory, s'assurer que les
appartenances au groupe Test ont changé selon les instructions du fichier LDIF. Il devrait contenir à présent
Elie HARIVRA, Medhi TUNPEUX et Jean BON.

We removed Jean JB. BON from the group in the LDIFDE script so he shouldn't be in the group anymore.

5. **Création d'un ordinateur avec DSadd**

```powershell
dsadd computer "CN=DESKTOP_Test_ADDS, OU=Test-TP, DC=Bertrand, DC=local"
```


## PARTIE 4 : CREATION D'OBJETS SELON UNE NOMENCLATURE ETABLIE (automatisationviascriptet/oucommandes)
