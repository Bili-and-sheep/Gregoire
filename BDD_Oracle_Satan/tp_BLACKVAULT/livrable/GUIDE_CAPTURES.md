# OPÉRATION BLACKVAULT — Guide de captures d'écran

## Prérequis

Oracle Database 23ai / 26ai (FREEPDB1) doit être démarré.  
Outil recommandé : **SQL*Plus** ou **SQL Developer** (pour les captures visuelles).

```bash
# Connexion initiale en tant que DBA
sqlplus sys/"VotreMotDePasse"@FREEPDB1 AS SYSDBA
-- Puis executer les scripts dans l'ordre :
@sql/01_create_schema.sql
@sql/02_insert_data.sql
@sql/03_plsql.sql
@sql/04_deception.sql
```

---

## Capture 1 — Infrastructure Blue Team (vérification initiale)

**Objectif :** prouver que les politiques FGA, le HoneyToken et les leurres sont en place.

```sql
CONNECT blackvault/"BlackVault#2025"@FREEPDB1

-- 1a) Politiques FGA actives
SELECT policy_name, object_name, enabled, handler_module
FROM dba_audit_policies
WHERE object_owner = 'BLACKVAULT'
ORDER BY object_name;

-- 1b) HoneyToken en place
SELECT num_dossier, niveau_risque, statut, is_honeytoken
FROM temoins
WHERE is_honeytoken = 1;

-- 1c) Tables de leurre peuplées
SELECT 'LEURRE_ADMIN_CREDENTIALS' AS leurre, COUNT(*) nb
  FROM leurre_admin_credentials
UNION ALL
SELECT 'LEURRE_WITNESS_MASTER_LIST', COUNT(*) FROM leurre_witness_master_list
UNION ALL
SELECT 'LEURRE_BACKUP_ENCRYPTION_KEYS', COUNT(*) FROM leurre_backup_encryption_keys;
```

**Screenshot :** 3 requêtes avec leurs résultats visibles.  
Points à montrer : `ENABLED = YES` pour toutes les FGA, `IS_HONEYTOKEN = 1` pour AEGIS-OMEGA, comptages > 0 pour les leurres.

---

## Capture 2 — HoneyToken : déclenchement FGA

**Objectif :** montrer qu'accéder au dossier AEGIS-OMEGA déclenche une alerte automatique.

```sql
-- Connexion en analyste compromis
CONNECT bv_analyste/"Analyste#2025"@FREEPDB1

-- 2a) Recherche qui remonte le HoneyToken (déclenche FGA)
SELECT num_dossier, niveau_risque, statut
FROM blackvault.temoins
WHERE niveau_risque = 'CRITIQUE';

-- 2b) Accès direct au HoneyToken (alerte critique)
SELECT *
FROM blackvault.temoins
WHERE num_dossier = 'AEGIS-OMEGA';
```

```sql
-- Vérification côté Blue Team
CONNECT blackvault/"BlackVault#2025"@FREEPDB1

SELECT type_alerte, username,
       TO_CHAR(date_alerte,'YYYY-MM-DD HH24:MI:SS') AS date_alerte,
       SUBSTR(details, 1, 150) AS details
FROM alertes_securite
WHERE type_alerte LIKE '%HONEYTOKEN%'
ORDER BY date_alerte DESC;
```

**Screenshot :** requête sur TEMOINS (côté rouge) + alerte dans ALERTES_SECURITE (côté bleu).  
Points à montrer : `type_alerte = 'HONEYTOKEN_ACCES'`, username `BV_ANALYSTE`.

---

## Capture 3 — Tables Leurres / Synonymes publics

**Objectif :** montrer que l'attaquant accède à des données totalement fabriquées.

```sql
CONNECT bv_suspect/"Suspect#2025"@FREEPDB1

-- 3a) Synonyme public ADMIN_CREDENTIALS (leurre)
SELECT * FROM admin_credentials;

-- 3b) Synonyme public BACKUP_ENC_KEYS (leurre)
SELECT * FROM backup_enc_keys;

-- 3c) Synonyme public WITNESS_LIST (vue leurre)
SELECT * FROM witness_list;
```

```sql
-- Preuve Blue Team : l'accès a été loggé
CONNECT blackvault/"BlackVault#2025"@FREEPDB1

SELECT username, table_accedee, action,
       TO_CHAR(date_acces,'YYYY-MM-DD HH24:MI:SS') AS date_acces
FROM log_acces_sensibles
WHERE username = 'BV_SUSPECT'
ORDER BY date_acces DESC;
```

**Screenshot :** contenu des tables leurres (crédentiels/clés inventés) + log côté bleu.  
Points à montrer : les données sont fausses mais vraisemblables, l'accès est tracé.

---

## Capture 4 — Polyinstanciation : 4 niveaux pour le même témoin

**Objectif :** montrer que chaque rôle voit une localisation différente pour le témoin #7.

Ouvrir **4 sessions SQL*Plus en parallèle** (ou exécuter séquentiellement) :

```sql
-- SESSION A : Analyste (niveau CONFIDENTIEL)
CONNECT bv_analyste/"Analyste#2025"@FREEPDB1
SELECT id_temoin, type_lieu, ville, pays, adresse, niveau_acces
FROM blackvault.vw_localisation_poly
WHERE id_temoin = 7;
-- Attendu : données banalisées (Europe occidentale)

-- SESSION B : Coordinateur (niveau SECRET)
CONNECT bv_coordinateur/"Coord#2025"@FREEPDB1
SELECT id_temoin, type_lieu, ville, pays, adresse, niveau_acces
FROM blackvault.vw_localisation_poly
WHERE id_temoin = 7;
-- Attendu : région Léman, Suisse

-- SESSION C : Directeur (niveau TOP_SECRET)
CONNECT bv_directeur/"Direct#2025"@FREEPDB1
SELECT id_temoin, type_lieu, ville, pays, adresse, niveau_acces
FROM blackvault.vw_localisation_poly
WHERE id_temoin = 7;
-- Attendu : adresse complète réelle (Route des Acacias 14, Satigny, Genève)

-- SESSION D : Suspect (LEURRE)
CONNECT bv_suspect/"Suspect#2025"@FREEPDB1
SELECT id_temoin, type_lieu, ville, pays, adresse, niveau_acces
FROM blackvault.vw_localisation_poly
WHERE id_temoin = 7;
-- Attendu : adresse totalement fausse (Hôtel de Crillon, Paris)
```

**Screenshot :** idéalement les 4 résultats côte à côte.  
Points à montrer : même `id_temoin = 7`, 4 lignes avec des adresses radicalement différentes, `niveau_acces` visible.

---

## Capture 5 — Watermarking : traçabilité des exports

**Objectif :** montrer l'injection du watermark et l'identification d'une fuite.

```sql
-- 5a) Export par le coordinateur (watermark silencieux)
CONNECT bv_coordinateur/"Coord#2025"@FREEPDB1
SELECT id_temoin, num_dossier, niveau_risque, statut
FROM blackvault.vw_export_temoins
FETCH FIRST 5 ROWS ONLY;

-- 5b) Export par l'analyste (watermark différent)
CONNECT bv_analyste/"Analyste#2025"@FREEPDB1
SELECT id_temoin, num_dossier, niveau_risque
FROM blackvault.vw_export_temoins
FETCH FIRST 5 ROWS ONLY;
```

```sql
-- 5c) Blue Team : registre des watermarks
CONNECT blackvault/"BlackVault#2025"@FREEPDB1

SELECT rw.username, t.num_dossier, rw.signature,
       TO_CHAR(rw.date_generation,'YYYY-MM-DD HH24:MI:SS') AS date_generation
FROM registre_watermarks rw
JOIN temoins t ON t.id_temoin = rw.id_temoin
ORDER BY rw.date_generation DESC;

-- 5d) Identification de la source d'une fuite
SET SERVEROUTPUT ON;
DECLARE
  v_sig VARCHAR2(128);
BEGIN
  SELECT signature INTO v_sig
  FROM registre_watermarks
  WHERE ROWNUM = 1;
  DBMS_OUTPUT.PUT_LINE('Signature : ' || v_sig);
  sp_identifier_fuite(v_sig);
END;
/
```

**Screenshot :** REGISTRE_WATERMARKS avec 2 utilisateurs + output de SP_IDENTIFIER_FUITE.  
Points à montrer : 2 signatures différentes pour les 2 utilisateurs, la procédure identifie `BV_COORDINATEUR` ou `BV_ANALYSTE`.

---

## Capture 6 — Bilan Blue Team

**Objectif :** tableau de synthèse des alertes déclenchées.

```sql
CONNECT blackvault/"BlackVault#2025"@FREEPDB1

-- Bilan des alertes par type
SELECT type_alerte, COUNT(*) AS nb_alertes,
       MIN(TO_CHAR(date_alerte,'HH24:MI:SS')) AS premiere_alerte
FROM alertes_securite
GROUP BY type_alerte
ORDER BY nb_alertes DESC;

-- Score de risque des témoins actifs (top 10)
SELECT t.num_dossier, t.niveau_risque,
       fn_calcul_score_risque(t.id_temoin) AS score_dynamique
FROM temoins t
WHERE t.is_honeytoken = 0 AND t.statut = 'ACTIF'
ORDER BY score_dynamique DESC
FETCH FIRST 10 ROWS ONLY;
```

**Screenshot :** tableau de synthèse + scores de risque.  
Points à montrer : au moins 3 types d'alertes, score dynamique calculé par FN_CALCUL_SCORE_RISQUE.

---

## Résumé des captures nécessaires

| # | Mécanisme | Fichier suggéré |
|---|-----------|-----------------|
| 1 | Infrastructure initiale (FGA + HoneyToken + Leurres) | `captures/01_infra_initiale.png` |
| 2 | HoneyToken AEGIS-OMEGA + alerte FGA | `captures/02_honeytoken_fga.png` |
| 3 | Tables leurres + synonymes + log accès | `captures/03_leurres_synonymes.png` |
| 4 | Polyinstanciation (4 vues différentes) | `captures/04_polyinstanciation.png` |
| 5 | Watermarking + identification fuite | `captures/05_watermarking.png` |
| 6 | Bilan Blue Team (alertes + scores) | `captures/06_bilan_blue_team.png` |

Placer chaque capture dans le dossier `livrable/captures/`.
