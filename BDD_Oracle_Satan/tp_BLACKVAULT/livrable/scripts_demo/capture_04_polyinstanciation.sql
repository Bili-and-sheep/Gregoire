-- ============================================================
-- CAPTURE 4 : Polyinstanciation — 4 vues pour le même témoin
-- Executer les 4 blocs avec la connexion correspondante
-- Le plus visuel : ouvrir 4 onglets SQL Developer en parallèle
-- ============================================================

-- ---- BLOC A : bv_analyste / Analyste#2025 ----
-- Niveau CONFIDENTIEL => données banalisées
SELECT id_temoin     AS "ID Témoin",
       type_lieu     AS "Type lieu",
       ville         AS "Ville",
       pays          AS "Pays",
       adresse       AS "Adresse",
       niveau_acces  AS "Niveau acces"
FROM   blackvault.vw_localisation_poly
WHERE  id_temoin = 7;

-- ---- BLOC B : bv_coordinateur / Coord#2025 ----
-- Niveau SECRET => localisation opérationnelle
SELECT id_temoin     AS "ID Témoin",
       type_lieu     AS "Type lieu",
       ville         AS "Ville",
       pays          AS "Pays",
       adresse       AS "Adresse",
       niveau_acces  AS "Niveau acces"
FROM   blackvault.vw_localisation_poly
WHERE  id_temoin = 7;

-- ---- BLOC C : bv_directeur / Direct#2025 ----
-- Niveau TOP_SECRET => vraie adresse complète
SELECT id_temoin     AS "ID Témoin",
       type_lieu     AS "Type lieu",
       ville         AS "Ville",
       pays          AS "Pays",
       adresse       AS "Adresse",
       niveau_acces  AS "Niveau acces"
FROM   blackvault.vw_localisation_poly
WHERE  id_temoin = 7;

-- ---- BLOC D : bv_suspect / Suspect#2025 ----
-- LEURRE => fausse adresse (Hôtel de Crillon, Paris)
SELECT id_temoin     AS "ID Témoin",
       type_lieu     AS "Type lieu",
       ville         AS "Ville",
       pays          AS "Pays",
       adresse       AS "Adresse",
       niveau_acces  AS "Niveau acces"
FROM   blackvault.vw_localisation_poly
WHERE  id_temoin = 7;

-- ============================================================
-- VERIFICATION (connexion blackvault) : les 4 versions en base
-- ============================================================
-- Connexion : blackvault / BlackVault#2025
SELECT niveau_habilitation AS "Niveau habilitation",
       type_lieu           AS "Type lieu",
       ville               AS "Ville",
       pays                AS "Pays",
       SUBSTR(adresse,1,50) AS "Adresse",
       est_leurre          AS "Est leurre"
FROM   localisations_poly
WHERE  id_temoin = 7
ORDER  BY DECODE(niveau_habilitation,'TOP_SECRET',1,'SECRET',2,'CONFIDENTIEL',3,'LEURRE',4);
