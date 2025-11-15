# TP DC-DHCP

## Partie 1 Installation d'un Contrôleur de domaine

***Aller dans les outils du serveur et relever les programmes ajoutés pour la configuration des services de domaines AD et du DNS (répondre à la partie 3 n°2).*** 

Active Directory Administrative Center
Active Directory Domains and Trusts
Active Directory Module for Windows PowerShell
Active Directory Sites and Services
Active Directory Users and Computers
DNS

***Quel outil est lancé avec la commande dsa.msc ?***
a. Comment s'appelle le conteneur dans lequel est inscrit votre serveur ?
Active Directory Users and Computers [SDC01.Bertrand.local]

b. Où se trouve le compte administrateur du domaine ?
Bertrand.local/Users/



***Examiner le fichier Documents\SDC01.txt et le fichier XML Modèle de configuration du déploiement dans Documents. Que contiennent-ils ? Expliquer leurs utilités et comment s'en servir.***


Windows PowerShell script for AD DS Deployment

Import-Module ADDSDeployment
Install-ADDSForest `
-CreateDnsDelegation:$false `
-DatabasePath "C:\Windows\NTDS" `
-DomainMode "WinThreshold" `
-DomainName "Bertrand.local" `
-DomainNetbiosName "BERTRAND" `
-ForestMode "WinThreshold" `
-InstallDns:$true `
-LogPath "C:\Windows\NTDS" `
-NoRebootOnCompletion:$false `
-SysvolPath "C:\Windows\SYSVOL" `
-Force:$true



Il contient les paramétre modifié lors du déploiment (installation) du Service Active Directory


### Conclusion

Aucune Difficulté noté
Process simple et limpide
Aucune nouvelle connaissance car opération déja effectué plusieur fois (en école/entreprises)


## Partie 2 Installation et configuration d'un serveur DHCP
### A. Ajout du rôle Serveur DHCP
ok
### B. Configuration du Serveur DHCP
ok
### C. Ajout du rôle Serveur DHCP
ok

## Partie 3 Questions complémentaires
1. ip DNS : 192.168.96.96
2. AD * et DNS*
3. long
4. Ne pas pouvoir addresser des ip à des machines
5. Bail, permet de fixer un IP à une adress mac (utile pour des machiens avec des services qui tourne)
6. Expliquer ce que fait la commande en partie 2 C n°3 en décomposant pour chaque terme.; set l'optation d'ip via un server DHCP
7. Expliquer ce que fait la commande en partie 2 C n°4 en décomposant pour chaque terme.; set le dns via le server DHCP
8. pouvoir allouer les IP à des terminaux, les reservers et les exclures, 

