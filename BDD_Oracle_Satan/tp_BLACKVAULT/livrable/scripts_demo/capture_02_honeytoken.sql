-- ============================================================
-- CAPTURE 2 : HoneyToken FGA - Déclenchement de l'alerte
-- ETAPE 1 : Executer ce bloc en tant que bv_analyste / Analyste#2025 @ FREEPDB1
-- ============================================================

-- [RED TEAM] L'analyste compromis cherche des dossiers critiques
-- => Cette requête retourne AEGIS-OMEGA et déclenche la politique FGA

SELECT num_dossier   AS "Dossier",
       niveau_risque AS "Niveau risque",
       statut        AS "Statut"
FROM   blackvault.temoins
WHERE  niveau_risque = 'CRITIQUE';

-- [RED TEAM] Accès direct au honeytoken => ALERTE CRITIQUE déclenchée
SELECT id_temoin     AS "ID",
       num_dossier   AS "Dossier",
       niveau_risque AS "Risque",
       statut        AS "Statut",
       is_honeytoken AS "HoneyToken"
FROM   blackvault.temoins
WHERE  num_dossier = 'AEGIS-OMEGA';

-- ============================================================
-- ETAPE 2 : Basculer la connexion sur blackvault / BlackVault#2025
-- Puis exécuter ce bloc pour voir l'alerte générée
-- ============================================================

SELECT id_alerte                                          AS "ID",
       type_alerte                                        AS "Type d'alerte",
       username                                           AS "Utilisateur",
       TO_CHAR(date_alerte, 'YYYY-MM-DD HH24:MI:SS')     AS "Date/heure",
       SUBSTR(details, 1, 200)                            AS "Détails"
FROM   alertes_securite
WHERE  type_alerte LIKE '%HONEYTOKEN%'
ORDER  BY date_alerte DESC;
