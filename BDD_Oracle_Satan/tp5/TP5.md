Voici la réponse complète au TP05, structurée en deux parties.

---

# TP05 — Bell-LaPadula & Biba sur RWC23

## Partie 1 : Classification (sur papier)

### 1. Classification en confidentialité (Bell-LaPadula)

| Table | Niveau | Justification |
|---|---|---|
| `RWC_PAYS` | **Public** | Données publiques (noms de pays) |
| `RWC_TOURNOIS` | **Public** | Informations officielles publiées |
| `RWC_POULES` | **Public** | Composition des poules disponible partout |
| `RWC_STADES` | **Public** | Informations géographiques publiques |
| `RWC_EQUIPES` | **Public** | Équipes et leur poule, données publiques |
| `RWC_MATCHS` | **Public** | Calendrier et scores, données publiques |
| `RWC_RESULTATS` | **Public** | Scores et résultats, données publiques |
| `RWC_MATCHS_STG` | **Confidentiel** | Table de staging interne, données brutes non validées |
| `RWC_JOUEURS` | **Confidentiel** | Données personnelles (nom, date de naissance) |
| `RWC_POSTES` | **Confidentiel** | Composition précise des équipes (usage interne) |
| `RWC_FANS` | **Confidentiel** | Données personnelles (nom, email) — RGPD |
| `RWC_TICKETS` | **Secret** | Données commerciales et financières sensibles (prix, transactions) |

### 2. Classification en intégrité (Biba)

| Table | Niveau | Justification |
|---|---|---|
| `RWC_PAYS` | **Haute** | Référentiel stable, production |
| `RWC_TOURNOIS` | **Haute** | Données officielles, production |
| `RWC_POULES` | **Haute** | Référentiel de base, production |
| `RWC_STADES` | **Haute** | Référentiel stable, production |
| `RWC_EQUIPES` | **Haute** | Données officielles, production |
| `RWC_MATCHS` | **Haute** | Données validées et normalisées |
| `RWC_RESULTATS` | **Haute** | Données validées et normalisées |
| `RWC_JOUEURS` | **Haute** | Données de production (identités officielles) |
| `RWC_POSTES` | **Haute** | Données de production |
| `RWC_FANS` | **Haute** | Données de production (inscriptions officielles) |
| `RWC_TICKETS` | **Haute** | Transactions financières, production |
| `RWC_MATCHS_STG` | **Basse** | Table de staging/import — données non encore validées |

---

### 3. Accès autorisés par profil selon Bell-LaPadula & Biba

**Niveaux des profils :**

| Profil | Niveau confidentialité | Niveau intégrité |
|---|---|---|
| `PUBLIC_WEB` | Public (0) | Basse |
| `MARKETING_USER` | Public (1) | Basse |
| `FINANCE_ADMIN` | Confidentiel (2) | Haute |
| `DBA_ADMIN` | Secret (3) | Haute |

**Règles appliquées :**
- **Bell-LaPadula** : lecture = niveau ≤ niveau de l'objet (*no read up*) ; écriture = niveau ≥ niveau de l'objet (*no write down*)
- **Biba** : lecture = niveau ≥ niveau de l'objet (*no read down*) ; écriture = niveau ≤ niveau de l'objet (*no write up*)

| Profil | Tables lisibles (Bell-LaPadula) | Tables modifiables (Biba) | Notes |
|---|---|---|---|
| `PUBLIC_WEB` | Tables **Public** uniquement : PAYS, TOURNOIS, POULES, STADES, EQUIPES, MATCHS, RESULTATS | Aucune (niveau Basse = ne peut écrire que dans Basse, soit `MATCHS_STG` — mais niveau trop bas pour y accéder en confidentialité) | **RWC_FANS : NON** (Confidentiel > Public) |
| `MARKETING_USER` | Tables **Public** uniquement (même niveau que PUBLIC_WEB en confidentialité) | `RWC_MATCHS_STG` (Basse, Confidentiel) | **RWC_TICKETS : NON** (Secret > Public) |
| `FINANCE_ADMIN` | Tables **Public + Confidentiel** : toutes sauf TICKETS (Secret) | Tables **Haute** (Confidentiel) : JOUEURS, POSTES, FANS | **RWC_MATCHS_STG (Basse) : NON** — Biba interdit l'écriture vers le bas depuis un niveau Haute |
| `DBA_ADMIN` | **Toutes** les tables | **Toutes** les tables | Accès complet |

> **Réponse question 6 :**
> - `PUBLIC_WEB` peut-il lire `RWC_FANS` ? → **NON** (FANS = Confidentiel, PUBLIC_WEB = Public → *no read up* Bell-LaPadula)
> - `MARKETING_USER` peut-il lire `RWC_TICKETS` ? → **NON** (TICKETS = Secret, MARKETING_USER = Public → *no read up*)
> - `FINANCE_ADMIN` peut-il écrire dans `RWC_MATCHS_STG` ? → **NON** — bien que FINANCE_ADMIN ait accès à MATCHS_STG en confidentialité (Confidentiel ≥ Confidentiel), Biba interdit l'écriture vers une table de **niveau d'intégrité inférieur** (*no write down*) pour préserver l'intégrité des données de production.

---

## Partie 2 : Implémentation Oracle

```sql
-- ================================================================
-- TP05 - Bell-LaPadula & Biba sur RWC23
-- Connexion initiale : system@FREEPDB1
-- ================================================================

-- ----------------------------------------------------------------
-- ÉTAPE 4 : Création des 4 utilisateurs Oracle
-- ----------------------------------------------------------------
CONN system@FREEPDB1

-- Suppression des utilisateurs s'ils existent déjà
BEGIN
  FOR u IN (
    SELECT username FROM dba_users
    WHERE username IN ('PUBLIC_WEB','MARKETING_USER','FINANCE_ADMIN','DBA_ADMIN')
  ) LOOP
    EXECUTE IMMEDIATE 'DROP USER ' || u.username || ' CASCADE';
  END LOOP;
END;
/

-- Création des utilisateurs avec mot de passe (btw mauvaise pratique car les mots de passe sont envoyés en clair dans la base de données)
CREATE USER public_web      IDENTIFIED BY "Rwc23_PubWeb!";
CREATE USER marketing_user  IDENTIFIED BY "Rwc23_Mktg!";
CREATE USER finance_admin   IDENTIFIED BY "Rwc23_Fin!";
CREATE USER dba_admin       IDENTIFIED BY "Rwc23_Dba!";

-- Droit de connexion minimal
GRANT CREATE SESSION TO public_web;
GRANT CREATE SESSION TO marketing_user;
GRANT CREATE SESSION TO finance_admin;
GRANT CREATE SESSION TO dba_admin;

-- ----------------------------------------------------------------
-- ÉTAPE 5 : Implémentation Bell-LaPadula + Biba avec GRANT/REVOKE
-- ----------------------------------------------------------------

-- ============================================================
-- PUBLIC_WEB : lit uniquement les tables Public (niveau 0)
-- Aucun droit d'écriture (intégrité Basse = ne peut pas corrompre la production)
-- ============================================================
GRANT SELECT ON rwc23.rwc_pays       TO public_web;
GRANT SELECT ON rwc23.rwc_tournois   TO public_web;
GRANT SELECT ON rwc23.rwc_poules     TO public_web;
GRANT SELECT ON rwc23.rwc_stades     TO public_web;
GRANT SELECT ON rwc23.rwc_equipes    TO public_web;
GRANT SELECT ON rwc23.rwc_matchs     TO public_web;
GRANT SELECT ON rwc23.rwc_resultats  TO public_web;
-- RWC_FANS, RWC_JOUEURS, RWC_POSTES, RWC_TICKETS, RWC_MATCHS_STG : AUCUN DROIT

-- ============================================================
-- MARKETING_USER : lit tables Public (niveau 0)
-- Peut insérer dans le staging (Basse intégrité, Confidentiel)
-- Ne peut PAS lire Confidentiel/Secret (Bell-LaPadula : no read up)
-- ============================================================
GRANT SELECT ON rwc23.rwc_pays       TO marketing_user;
GRANT SELECT ON rwc23.rwc_tournois   TO marketing_user;
GRANT SELECT ON rwc23.rwc_poules     TO marketing_user;
GRANT SELECT ON rwc23.rwc_stades     TO marketing_user;
GRANT SELECT ON rwc23.rwc_equipes    TO marketing_user;
GRANT SELECT ON rwc23.rwc_matchs     TO marketing_user;
GRANT SELECT ON rwc23.rwc_resultats  TO marketing_user;
-- Écriture staging uniquement (niveau Basse, acceptable pour un utilisateur Basse)
GRANT INSERT ON rwc23.rwc_matchs_stg TO marketing_user;
-- RWC_FANS, RWC_JOUEURS, RWC_POSTES, RWC_TICKETS : AUCUN DROIT

-- ============================================================
-- FINANCE_ADMIN : lit Public + Confidentiel (Bell-LaPadula)
-- Peut écrire dans les tables Haute & Confidentiel (Biba : no write down)
-- Ne peut PAS écrire dans le Staging (Basse) → Biba no write down
-- ============================================================
GRANT SELECT ON rwc23.rwc_pays       TO finance_admin;
GRANT SELECT ON rwc23.rwc_tournois   TO finance_admin;
GRANT SELECT ON rwc23.rwc_poules     TO finance_admin;
GRANT SELECT ON rwc23.rwc_stades     TO finance_admin;
GRANT SELECT ON rwc23.rwc_equipes    TO finance_admin;
GRANT SELECT ON rwc23.rwc_matchs     TO finance_admin;
GRANT SELECT ON rwc23.rwc_resultats  TO finance_admin;
GRANT SELECT ON rwc23.rwc_matchs_stg TO finance_admin;  -- lecture staging : OK (Confidentiel >= Confidentiel)
GRANT SELECT ON rwc23.rwc_joueurs    TO finance_admin;
GRANT SELECT ON rwc23.rwc_postes     TO finance_admin;
GRANT SELECT ON rwc23.rwc_fans       TO finance_admin;
-- Écriture sur tables Haute/Confidentiel (Biba)
GRANT INSERT, UPDATE, DELETE ON rwc23.rwc_fans    TO finance_admin;
GRANT INSERT, UPDATE, DELETE ON rwc23.rwc_joueurs TO finance_admin;
GRANT INSERT, UPDATE, DELETE ON rwc23.rwc_postes  TO finance_admin;
-- RWC_TICKETS (Secret) : lecture et écriture INTERDITES
-- RWC_MATCHS_STG (Basse) : écriture INTERDITE (Biba no write down)

-- ============================================================
-- DBA_ADMIN : accès complet (Secret, Haute intégrité)
-- ============================================================
GRANT SELECT, INSERT, UPDATE, DELETE ON rwc23.rwc_pays        TO dba_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON rwc23.rwc_tournois    TO dba_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON rwc23.rwc_poules      TO dba_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON rwc23.rwc_stades      TO dba_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON rwc23.rwc_equipes     TO dba_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON rwc23.rwc_matchs      TO dba_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON rwc23.rwc_resultats   TO dba_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON rwc23.rwc_matchs_stg  TO dba_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON rwc23.rwc_joueurs     TO dba_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON rwc23.rwc_postes      TO dba_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON rwc23.rwc_fans        TO dba_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON rwc23.rwc_tickets     TO dba_admin;
```

---

## Étape 6 : Tests de connexion et vérification

```sql
-- ----------------------------------------------------------------
-- TEST 1 : PUBLIC_WEB → lecture RWC_FANS attendu : ERREUR ORA-00942
-- ----------------------------------------------------------------
CONN public_web/"Rwc23_PubWeb!"@FREEPDB1
SELECT COUNT(*) FROM rwc23.rwc_fans;
-- Résultat attendu : ORA-00942: table or view does not exist
-- Confirme Bell-LaPadula : no read up (Public ne lit pas Confidentiel)

-- ----------------------------------------------------------------
-- TEST 2 : MARKETING_USER → lecture RWC_TICKETS attendu : ERREUR
-- ----------------------------------------------------------------
CONN marketing_user/"Rwc23_Mktg!"@FREEPDB1
SELECT COUNT(*) FROM rwc23.rwc_tickets;
-- Résultat attendu : ORA-00942
-- Confirme Bell-LaPadula : no read up (Public ne lit pas Secret)

-- ----------------------------------------------------------------
-- TEST 3 : FINANCE_ADMIN → écriture dans RWC_MATCHS_STG attendu : ERREUR
-- ----------------------------------------------------------------
CONN finance_admin/"Rwc23_Fin!"@FREEPDB1
INSERT INTO rwc23.rwc_matchs_stg
  (match_code, match_tour, match_date, match_ville,
   match_equipe_locale, match_equipe_visiteur,
   match_equipe_locale_pts, match_equipe_visiteur_pts)
VALUES ('TEST01','POOL',SYSDATE,'Paris','France','Angleterre',30,20);
-- Résultat attendu : ORA-01031: insufficient privileges
-- Confirme Biba : no write down (Haute n'écrit pas dans Basse)

-- ----------------------------------------------------------------
-- TEST 4 : FINANCE_ADMIN → lecture RWC_FANS attendu : OK
-- ----------------------------------------------------------------
SELECT COUNT(*) FROM rwc23.rwc_fans;
-- Résultat attendu : 1000 (accès Confidentiel autorisé)

-- ----------------------------------------------------------------
-- TEST 5 : DBA_ADMIN → accès complet
-- ----------------------------------------------------------------
CONN dba_admin/"Rwc23_Dba!"@FREEPDB1
SELECT COUNT(*) FROM rwc23.rwc_tickets;  -- doit retourner 10000
SELECT COUNT(*) FROM rwc23.rwc_fans;     -- doit retourner 1000
INSERT INTO rwc23.rwc_matchs_stg
  (match_code, match_tour, match_date, match_ville,
   match_equipe_locale, match_equipe_visiteur,
   match_equipe_locale_pts, match_equipe_visiteur_pts)
VALUES ('TEST_DBA','POOL',SYSDATE,'Lyon','France','Irlande',25,18);
-- Tout doit fonctionner : DBA_ADMIN a le niveau Secret + Haute intégrité
ROLLBACK;
```

---

## Étape 7 : Justification des décisions

**Classification de `RWC_FANS` en Confidentiel** : la table contient `fan_email` et des données d'identité rattachées à un pays d'origine. Ces données relèvent du RGPD et ne doivent pas être exposées au public. Un utilisateur `PUBLIC_WEB` (portail web non authentifié) n'a aucune raison légitime d'y accéder.

**Classification de `RWC_TICKETS` en Secret** : les tickets contiennent des prix unitaires (`ticket_prix`), des dates d'achat et des associations fan/match — soit des données commerciales et financières sensibles. Seul le DBA ou un profil financier de haut niveau devrait pouvoir les consulter.

**`MARKETING_USER` limité au niveau Public** : le marketing a besoin de consulter les données publiques (matchs, équipes, résultats) pour des analyses de fréquentation, mais ne doit pas accéder aux données personnelles des fans (RGPD) ni aux données financières.

**Biba justifie le refus d'écriture de `FINANCE_ADMIN` dans le Staging** : si un utilisateur de haut niveau d'intégrité écrit dans une table de bas niveau (staging non validé), il risque de mélanger des données fiables avec des données brutes non contrôlées. Le staging doit rester une zone d'entrée réservée aux processus d'import de bas niveau, puis être promu vers la production uniquement par le DBA.

**`PUBLIC_WEB` sans aucun droit d'écriture** : niveau d'intégrité Basse combiné à un niveau de confidentialité Public = un acteur externe non maîtrisé. Toute écriture lui est interdite pour éviter toute injection ou corruption de données.


---

## Rappel TP
<img src="tO5.png" alt="MLD" width="700px">

---
  ## Crédit

  - [@Bili-and-sheep](https://www.github.com/Bili-and-sheep)
  - [@matissime](https://www.github.com/matissime)
