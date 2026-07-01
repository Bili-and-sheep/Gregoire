-- ============================================================
-- BLACKVAULT - Script 05 : Scénario Red/Blue Team
-- Démonstration complète des mécanismes de Data Deception
-- Executer apres 04_deception.sql
-- ============================================================

-- ============================================================
-- BLUE TEAM : SETUP - Vérification que tout est en place
-- ============================================================
CONNECT blackvault/"BlackVault#2025"@FREEPDB1

PROMPT =============================================
PROMPT [BLUE TEAM] Verification de l''infrastructure
PROMPT =============================================

-- Vérification des politiques FGA actives
SELECT policy_name, object_name, enabled, handler_module
FROM dba_audit_policies
WHERE object_owner = 'BLACKVAULT'
ORDER BY object_name;

-- Vérification du HoneyToken en place
SELECT num_dossier, niveau_risque, statut, is_honeytoken
FROM temoins
WHERE is_honeytoken = 1;

-- Vérification des tables de leurre
SELECT 'LEURRE_ADMIN_CREDENTIALS'    AS table_leurre, COUNT(*) nb FROM leurre_admin_credentials
UNION ALL
SELECT 'LEURRE_WITNESS_MASTER_LIST',  COUNT(*) FROM leurre_witness_master_list
UNION ALL
SELECT 'LEURRE_BACKUP_ENCRYPTION_KEYS', COUNT(*) FROM leurre_backup_encryption_keys;

-- Alertes actuelles (avant attaque)
SELECT COUNT(*) nb_alertes_initiales FROM alertes_securite;

PROMPT [BLUE TEAM] Etat initial : 0 alerte de securite.
PROMPT [BLUE TEAM] Infrastructure prete. Transfert au Red Team.

-- ============================================================
-- RED TEAM : PHASE 1 - Reconnaissance
-- L''attaquant a compromis le compte BV_SUSPECT
-- ============================================================
CONNECT bv_suspect/"Suspect#2025"@FREEPDB1

PROMPT
PROMPT =============================================
PROMPT [RED TEAM] Phase 1 : Reconnaissance initiale
PROMPT =============================================

-- L'attaquant explore les objets accessibles
SELECT table_name, privilege
FROM session_privs
WHERE privilege LIKE '%TABLE%'
UNION
SELECT synonym_name, 'SYNONYM' FROM user_synonyms
UNION
SELECT synonym_name, 'PUBLIC SYNONYM' FROM all_synonyms
WHERE table_owner = 'BLACKVAULT'
AND synonym_name IN ('WITNESS_LIST','ADMIN_CREDENTIALS','MASTER_IDENTITIES','BACKUP_ENC_KEYS');

PROMPT [RED TEAM] Synonymes publics trouvés ! Tentative d''accès...

-- ============================================================
-- RED TEAM : PHASE 2 - Accès aux synonymes publics (PIÈGE 1)
-- L'attaquant trouve et consulte WITNESS_LIST
-- => Déclenche le log mais voit des données floues
-- ============================================================
PROMPT
PROMPT [RED TEAM] Phase 2 : Acces a WITNESS_LIST
SELECT * FROM witness_list;
-- => COORDINATEUR et DIRECTEUR voient les vrais dossiers
-- => SUSPECT voit des versions masquées/leurre

-- L'attaquant découvre les tables de leurre avec des noms attractifs
PROMPT [RED TEAM] Acces a ADMIN_CREDENTIALS (table de leurre)...
SELECT * FROM admin_credentials;
-- => Données leurre + ALERTE déclenchée en arrière-plan

-- L'attaquant essaie BACKUP_ENC_KEYS
PROMPT [RED TEAM] Acces aux cles de chiffrement (leurre)...
SELECT * FROM backup_enc_keys;

-- ============================================================
-- RED TEAM : PHASE 3 - Tentative accès HoneyToken (PIÈGE 2)
-- L'attaquant cherche des dossiers très sensibles
-- ============================================================
PROMPT
PROMPT [RED TEAM] Phase 3 : Recherche dossiers critiques...
-- L'attaquant fait une recherche sur les niveaux critiques
-- Cela déclenche la politique FGA si AEGIS-OMEGA est retourné
CONNECT bv_analyste/"Analyste#2025"@FREEPDB1

-- Simulation : un analyste compromis cherche le dossier OMEGA
SELECT num_dossier, niveau_risque, statut
FROM blackvault.temoins
WHERE niveau_risque = 'CRITIQUE';
-- => Le dossier AEGIS-OMEGA (honeytoken) apparait => ALERTE FGA déclenchée !

PROMPT [RED TEAM] Le dossier AEGIS-OMEGA est visible - tentative d''acces direct...
SELECT *
FROM blackvault.temoins
WHERE num_dossier = 'AEGIS-OMEGA';
-- => ALERTE CRITIQUE générée automatiquement dans ALERTES_SECURITE

-- ============================================================
-- RED TEAM : PHASE 4 - Polyinstanciation (PIÈGE 3)
-- Différents utilisateurs voient différentes localisations
-- ============================================================
PROMPT
PROMPT [RED TEAM] Phase 4 : Consultation localisations (Polyinstanciation)

-- Vue de l'analyste
CONNECT bv_analyste/"Analyste#2025"@FREEPDB1
PROMPT [ANALYSTE] Localisation du temoin 7 :
SELECT id_temoin, type_lieu, ville, pays, adresse, niveau_acces
FROM blackvault.vw_localisation_poly
WHERE id_temoin = 7;
-- => Voit : Europe occidentale / données banalisées

-- Vue du coordinateur
CONNECT bv_coordinateur/"Coord#2025"@FREEPDB1
PROMPT [COORDINATEUR] Localisation du temoin 7 :
SELECT id_temoin, type_lieu, ville, pays, adresse, niveau_acces
FROM blackvault.vw_localisation_poly
WHERE id_temoin = 7;
-- => Voit : Région Léman, Suisse (operationnel)

-- Vue du directeur
CONNECT bv_directeur/"Direct#2025"@FREEPDB1
PROMPT [DIRECTEUR] Localisation du temoin 7 :
SELECT id_temoin, type_lieu, ville, pays, adresse, niveau_acces
FROM blackvault.vw_localisation_poly
WHERE id_temoin = 7;
-- => Voit : Route des Acacias 14, Satigny, Genève (vraie adresse)

-- Vue du suspect (leurre)
CONNECT bv_suspect/"Suspect#2025"@FREEPDB1
PROMPT [SUSPECT] Localisation du temoin 7 :
SELECT id_temoin, type_lieu, ville, pays, adresse, niveau_acces
FROM blackvault.vw_localisation_poly
WHERE id_temoin = 7;
-- => Voit : Hotel de Crillon, Paris (totalement fausse !)

-- ============================================================
-- RED TEAM : PHASE 5 - Watermarking (PIÈGE 4)
-- L'attaquant exporte des données via la vue watermarkée
-- ============================================================
CONNECT bv_coordinateur/"Coord#2025"@FREEPDB1
PROMPT
PROMPT [RED TEAM] Phase 5 : Export de donnees via vue watermarkee

-- Simulation d'un export de données (comme un attaquant qui exfiltre)
SELECT id_temoin, num_dossier, niveau_risque, statut
FROM blackvault.vw_export_temoins
FETCH FIRST 5 ROWS ONLY;
-- => Chaque ligne est silencieusement watermarkée
-- => La signature est enregistrée dans REGISTRE_WATERMARKS

CONNECT bv_analyste/"Analyste#2025"@FREEPDB1
SELECT id_temoin, num_dossier, niveau_risque
FROM blackvault.vw_export_temoins
FETCH FIRST 5 ROWS ONLY;
-- => Watermark différente pour l'analyste

-- ============================================================
-- BLUE TEAM : DÉTECTION - Analyse post-incident
-- ============================================================
CONNECT blackvault/"BlackVault#2025"@FREEPDB1

PROMPT
PROMPT =============================================
PROMPT [BLUE TEAM] Detection : Analyse post-attaque
PROMPT =============================================

-- ALERTE 1 : Vérification des alertes générées
PROMPT --- Alertes de securite declenchees ---
SELECT
  a.id_alerte,
  a.type_alerte,
  a.username,
  TO_CHAR(a.date_alerte, 'YYYY-MM-DD HH24:MI:SS') AS date_alerte,
  SUBSTR(a.details, 1, 120) AS details,
  a.statut
FROM alertes_securite a
ORDER BY a.date_alerte DESC;

-- ALERTE 2 : Log des accès sensibles
PROMPT --- Log des acces sensibles ---
SELECT
  username,
  table_accedee,
  action,
  TO_CHAR(date_acces, 'YYYY-MM-DD HH24:MI:SS') AS date_acces,
  SUBSTR(details, 1, 100) AS details
FROM log_acces_sensibles
ORDER BY date_acces DESC;

-- ALERTE 3 : Registre des watermarks (identification de la fuite)
PROMPT --- Registre des watermarks (qui a exporte quoi) ---
SELECT
  rw.username,
  t.num_dossier,
  rw.signature,
  TO_CHAR(rw.date_generation, 'YYYY-MM-DD HH24:MI:SS') AS date_generation,
  rw.contexte
FROM registre_watermarks rw
JOIN temoins t ON t.id_temoin = rw.id_temoin
ORDER BY rw.date_generation DESC;

-- IDENTIFICATION FUITE : simulation
PROMPT --- Simulation identification d''une fuite par watermark ---
SET SERVEROUTPUT ON;
DECLARE
  v_sig VARCHAR2(128);
BEGIN
  -- Récupérer la première signature enregistrée
  SELECT signature INTO v_sig
  FROM registre_watermarks
  FETCH FIRST 1 ROWS ONLY;

  DBMS_OUTPUT.PUT_LINE('Signature de fuite detectee : ' || v_sig);
  sp_identifier_fuite(v_sig);
END;
/

-- ALERTE 4 : Score de risque des témoins les plus exposés
PROMPT --- Score de risque actuel des temoins critiques ---
SELECT
  t.num_dossier,
  t.niveau_risque,
  fn_calcul_score_risque(t.id_temoin) AS score_dynamique
FROM temoins t
WHERE t.is_honeytoken = 0 AND t.statut = 'ACTIF'
ORDER BY score_dynamique DESC
FETCH FIRST 10 ROWS ONLY;

-- BILAN DE L'ATTAQUE
PROMPT
PROMPT =============================================
PROMPT [BLUE TEAM] Bilan de l''operation
PROMPT =============================================
SELECT
  type_alerte,
  COUNT(*) AS nb_alertes,
  MIN(TO_CHAR(date_alerte,'HH24:MI:SS')) AS premiere_alerte
FROM alertes_securite
GROUP BY type_alerte
ORDER BY nb_alertes DESC;

PROMPT
PROMPT === RAPPORT FINAL ===
PROMPT [1] HONEYTOKEN : Acces au dossier AEGIS-OMEGA detecte et trace
PROMPT [2] LEURRES    : Attaquant a consulte les tables de leurre (sans vrai contenu)
PROMPT [3] WATERMARK  : Tous les exports identifies et attribuables
PROMPT [4] POLYINST   : Attaquant a recu une fausse localisation (Hotel de Crillon)
PROMPT
PROMPT Resultat : attaquant identifie, desinformé, trace. Vrais secrets intacts.
PROMPT ============================================================
