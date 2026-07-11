-- ============================================================
-- CAPTURE 1 : Infrastructure initiale (Blue Team)
-- Connexion : blackvault / BlackVault#2025 @ FREEPDB1
-- ============================================================

-- 1A) Politiques FGA actives
SELECT policy_name        AS "Politique FGA",
       object_name        AS "Table protégée",
       enabled            AS "Active",
       handler_module     AS "Handler PL/SQL"
FROM   dba_audit_policies
WHERE  object_owner = 'BLACKVAULT'
ORDER  BY object_name;

-- 1B) HoneyToken en place
SELECT num_dossier     AS "Dossier",
       niveau_risque   AS "Niveau risque",
       statut          AS "Statut",
       is_honeytoken   AS "🍯 HoneyToken"
FROM   temoins
WHERE  is_honeytoken = 1;

-- 1C) Tables de leurre peuplées
SELECT 'LEURRE_ADMIN_CREDENTIALS'     AS "Table leurre", COUNT(*) AS "Nb lignes"
FROM   leurre_admin_credentials
UNION ALL
SELECT 'LEURRE_WITNESS_MASTER_LIST',   COUNT(*) FROM leurre_witness_master_list
UNION ALL
SELECT 'LEURRE_BACKUP_ENCRYPTION_KEYS', COUNT(*) FROM leurre_backup_encryption_keys;
