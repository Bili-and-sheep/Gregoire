-- ============================================================
-- CAPTURE 3 : Tables leurres / Synonymes publics
-- ETAPE 1 : Connexion bv_suspect / Suspect#2025 @ FREEPDB1
-- ============================================================

-- [RED TEAM] L'attaquant accède aux synonymes publics attractifs

-- Crédentiels administrateur (leurre)
SELECT username AS "Username",
       password  AS "Password (faux)",
       role_db   AS "Rôle"
FROM   admin_credentials;

-- Clés de chiffrement de sauvegarde (leurre)
SELECT key_id     AS "ID Clé",
       key_name   AS "Nom",
       key_value  AS "Valeur (fausse)",
       algorithm  AS "Algorithme"
FROM   backup_enc_keys;

-- Liste des témoins (leurre / données masquées)
SELECT *
FROM   witness_list;

-- ============================================================
-- ETAPE 2 : Connexion blackvault / BlackVault#2025
-- Vérifier que les accès ont été loggés
-- ============================================================

SELECT username      AS "Utilisateur",
       table_accedee AS "Table",
       action        AS "Action",
       TO_CHAR(date_acces,'YYYY-MM-DD HH24:MI:SS') AS "Date/heure",
       SUBSTR(details, 1, 120) AS "Détails"
FROM   log_acces_sensibles
WHERE  username = 'BV_SUSPECT'
ORDER  BY date_acces DESC;
