# TP DC-DHCP 

[TP2-DC-DHCP.pdf](PDF/TP2-DC-DHCP.pdf)

## Partie 1 Installation d'un Contrôleur de domaine

***Aller dans les outils du serveur et relever les programmes ajoutés pour la configuration des services de domaines AD et du DNS (répondre à la partie 3 n°2).*** 

 - Active Directory Administrative Center
 - Active Directory Domains and Trusts
 - Active Directory Module for Windows PowerShell
 - Active Directory Sites and Services
 - Active Directory Users and Computers
 - DNS

***Quel outil est lancé avec la commande dsa.msc ?***  
a. Comment s'appelle le conteneur dans lequel est inscrit votre serveur ?
Active Directory Users and Computers [SDC01.Bertrand.local]

b. Où se trouve le compte administrateur du domaine ?
Bertrand.local/Users/



***Examiner le fichier Documents\SDC01.txt et le fichier XML Modèle de configuration du déploiement dans Documents. Que contiennent-ils ? Expliquer leurs utilités et comment s'en servir.***


Windows PowerShell script for AD DS Deployment
```powershell
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
```


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

### Conclusion

Aucune Difficulté noté
Process simple et limpide
Aucune nouvelle connaissance car opération déja effectué plusieur fois (en école/entreprises)


## Partie 3 Questions complémentaires
1. Quelle est l'adresse IPv4 du DNS ?  
ip DNS : 192.168.96.96


2. Outils ajoutés à l'installation des services de domaines AD et du DNS.:
   - Active Directory Administrative Center
   - Active Directory Domains and Trusts
   - Active Directory Module for Windows PowerShell
   - Active Directory Sites and Services
   - Active Directory Users and Computers
   - ADSI Edit
   - DNS
   - Group Policy Management
   - Microsoft Azure Services
   - Print Management
   - Windows PowerShell ISE 
   - Windows PowerShell ISE


3. Role des outils ajoutés :
    - Active Directory Administrative Center : Gestion centralisée des objets AD
    - Active Directory Domains and Trusts : Gestion des relations de confiance entre domaines
    - Active Directory Module for Windows PowerShell : Automatisation des tâches AD via PowerShell
    - Active Directory Sites and Services : Gestion des sites et services AD
    - Active Directory Users and Computers : Gestion des utilisateurs et ordinateurs AD
    - ADSI Edit : Édition avancée des objets AD
    - DNS : Gestion des noms de domaine et résolution DNS
    - Group Policy Management 
    - Microsoft Azure Services : Gestion des services Azure liés à AD
    - Print Management : Gestion des imprimantes réseau
    - Windows PowerShell ISE : Environnement de script PowerShell avancé
    - Windows PowerShell ISE(x86) : Version 32 bits de l'environnement de script PowerShell avancé
 
  
4. Qu'est-ce qu'une plage d'exclusion et à quoi cela sert-il ?  
Ne pas pouvoir addresser des ip à des machines, bonne pratique pour des serveurs ou des machines avec des IP statique


5. Qu'est-ce qu'un bail ? Une réservation de bail ?  
Bail, permet de fixer un IP à une adress mac (utile pour des machiens avec des services qui tourne), réservation de bail permet de réserver une plage d'ip pour un usage spécifique (ex: imprimante reseau)


6. Expliquer ce que fait la commande en partie 2 C n°3 en décomposant pour chaque terme.
set l'optation d'ip via un server DHCP


7. Expliquer ce que fait la commande en partie 2 C n°4 en décomposant pour chaque terme.
set le dns via le server DHCP


8. Expliquer le principe général de fonctionnement du DHCP et plus en détail lors de l'obtention d'une
   adresse IP.  
Pouvoir allouer les IP à des terminaux, les reservers et les exclures,

C'est un “hand-shake“ entre le demandeur et serveur DHCP :
    - Client envoie une requete au serveur DHCP (DHCPDISCOVER)
    - Serveur repond avec une offre d'ip (DHCPOFFER)
    - Client accepte l'offre (DHCPREQUEST)
    - Serveur confirme l'allocation de l'ip (DHCPACK)
