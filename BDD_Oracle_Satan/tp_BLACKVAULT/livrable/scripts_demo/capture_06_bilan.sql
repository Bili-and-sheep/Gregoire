-- ============================================================
-- CAPTURE 6 : Bilan Blue Team — synthèse post-attaque
-- Connexion : blackvault / BlackVault#2025 @ FREEPDB1
-- ============================================================

-- 6A) Toutes les alertes déclenchées pendant le scénario
SELECT id_alerte                                         AS "ID",
       type_alerte                                       AS "Type d'alerte",
       username                                          AS "Auteur",
       TO_CHAR(date_alerte,'YYYY-MM-DD HH24:MI:SS')     AS "Date/heure",
       SUBSTR(details, 1, 120)                           AS "Détails",
       statut                                            AS "Statut"
FROM   alertes_securite
ORDER  BY date_alerte DESC;

-- 6B) Résumé par type d'alerte
SELECT type_alerte              AS "Type d'alerte",
       COUNT(*)                 AS "Nombre",
       MIN(TO_CHAR(date_alerte,'HH24:MI:SS')) AS "Première détection"
FROM   alertes_securite
GROUP  BY type_alerte
ORDER  BY COUNT(*) DESC;

-- 6C) Score de risque dynamique des témoins actifs (top 10)
SELECT t.num_dossier                      AS "Dossier",
       t.niveau_risque                    AS "Niveau risque",
       fn_calcul_score_risque(t.id_temoin) AS "Score dynamique /100"
FROM   temoins t
WHERE  t.is_honeytoken = 0
AND    t.statut = 'ACTIF'
ORDER  BY fn_calcul_score_risque(t.id_temoin) DESC
FETCH FIRST 10 ROWS ONLY;

-- 6D) Rapport final des accès sensibles
SELECT username      AS "Utilisateur",
       table_accedee AS "Table accédée",
       action        AS "Action",
       COUNT(*)      AS "Nb accès"
FROM   log_acces_sensibles
GROUP  BY username, table_accedee, action
ORDER  BY username, table_accedee;
