# TP_DC-DNS

NewUser

malcom-riz@Bertrand.local
Root1234

## Partie 2
1. Que signifie ADDS ? DNS ?
ADDS : Active Directory Domaine Service
DNS : Domaine name service

2. A quoi sert un DNS ? un DC ?
DNS : translatter un nom de domaine en IP et inversement
DC : Domain controller 

3. Le DNS peut-il être séparé du DC ?
non

4. Dans quelle OU est situé le compte administrateur ? Quels sont ses privilèges ?
OU , Administrateur
5. Que font les commandes 2 et 3 en partie C ?
set le dns via le server DHCP
set l'optation d'ip via un server DHCP
6. Quel est le système numérique pour « fd00:1 » ?
HexaDecimal

7. A quoi correspondent les enregistrements de type A ? AAAA?|
A : IpV4
AAAA : IpV6

8. Quel type d'enregistrement correspond à LDAP ? Kerberos ? DNS ?
Kerberos : SRV
LDAP : SRV
DNS : SOA / NS
9. Quelles sont les adresses loopback en IPv4 ? IPv6 ?
IPv4 : 127.0.0.1
IPv6 : fd00::1
10. A quoi correspondent les serveurs racines ? Combien en existe-t-il ?
Il en exite qu'un seul (hors redondance), il régice tout les nom de domaine .org . com etc...
11. Quelle est la différence entre les comptes « SDC01\administrateur » et « Info\administrateur » ?
L'un est admin du domaine SDC01 l'autre du domaine Info
12. Que signifient les « :: » dans « fd00::1 » ?
Que toute les valeur entre fd00 et 1 sont = 0