-- ============================================================
-- BLACKVAULT - Script 04 : Data Deception
-- 4 mécanismes obligatoires :
--   1. HoneyToken avec FGA
--   2. Vues + Synonymes publics vers tables de leurre
--   3. Watermarking
--   4. Polyinstanciation
-- Executer apres 03_plsql.sql
-- ============================================================

CONNECT blackvault/"BlackVault#2025"@FREEPDB1

-- ============================================================
-- MECANISME 1 : HONEYTOKEN avec FGA
-- Dossier AEGIS-OMEGA = record piegé
-- Tout SELECT sur ce dossier déclenche une alerte
-- ============================================================

-- Procédure handler FGA (appelée automatiquement lors de l'accès)
CREATE OR REPLACE PROCEDURE sp_alerte_honeytoken(
  schema_name IN VARCHAR2,
  table_name  IN VARCHAR2
)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  INSERT INTO alertes_securite (
    id_alerte, type_alerte, username, date_alerte, details, statut
  ) VALUES (
    seq_alertes.NEXTVAL,
    'HONEYTOKEN_ACCESS',
    SYS_CONTEXT('USERENV', 'SESSION_USER'),
    SYSTIMESTAMP,
    '[ALERTE CRITIQUE] Acces au dossier HONEYTOKEN AEGIS-OMEGA depuis IP=' ||
    SYS_CONTEXT('USERENV', 'IP_ADDRESS') ||
    ' | Session=' || SYS_CONTEXT('USERENV', 'SESSIONID') ||
    ' | OS_User=' || SYS_CONTEXT('USERENV', 'OS_USER') ||
    ' | Table=' || schema_name || '.' || table_name,
    'NOUVEAU'
  );
  COMMIT;
END sp_alerte_honeytoken;
/

-- Suppression de la politique si elle existe déjà (idempotent)
BEGIN
  DBMS_FGA.DROP_POLICY(
    object_schema => 'BLACKVAULT',
    object_name   => 'TEMOINS',
    policy_name   => 'POL_HONEYTOKEN_AEGIS'
  );
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Création de la politique FGA sur le HoneyToken
BEGIN
  DBMS_FGA.ADD_POLICY(
    object_schema   => 'BLACKVAULT',
    object_name     => 'TEMOINS',
    policy_name     => 'POL_HONEYTOKEN_AEGIS',
    audit_condition => 'IS_HONEYTOKEN = 1',
    audit_column    => 'NUM_DOSSIER,NIVEAU_RISQUE,STATUT',
    handler_schema  => 'BLACKVAULT',
    handler_module  => 'SP_ALERTE_HONEYTOKEN',
    statement_types => 'SELECT',
    enable          => TRUE,
    audit_trail     => DBMS_FGA.DB + DBMS_FGA.EXTENDED
  );
END;
/

-- Politique FGA sur IDENTITES_REELLES (Top Secret)
BEGIN
  DBMS_FGA.DROP_POLICY(
    object_schema => 'BLACKVAULT',
    object_name   => 'IDENTITES_REELLES',
    policy_name   => 'POL_IDENTITES_REELLES_ACCESS'
  );
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE OR REPLACE PROCEDURE sp_alerte_identite_reelle(
  schema_name IN VARCHAR2,
  table_name  IN VARCHAR2
)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  INSERT INTO log_acces_sensibles (
    id_log, username, table_accedee, action, date_acces, details
  ) VALUES (
    seq_log_acces.NEXTVAL,
    SYS_CONTEXT('USERENV', 'SESSION_USER'),
    'IDENTITES_REELLES',
    'SELECT',
    SYSTIMESTAMP,
    '[FGA] Acces identite reelle | IP=' || SYS_CONTEXT('USERENV', 'IP_ADDRESS')
  );
  COMMIT;
END sp_alerte_identite_reelle;
/

BEGIN
  DBMS_FGA.ADD_POLICY(
    object_schema   => 'BLACKVAULT',
    object_name     => 'IDENTITES_REELLES',
    policy_name     => 'POL_IDENTITES_REELLES_ACCESS',
    audit_condition => '1=1',
    handler_schema  => 'BLACKVAULT',
    handler_module  => 'SP_ALERTE_IDENTITE_REELLE',
    statement_types => 'SELECT',
    enable          => TRUE
  );
END;
/

PROMPT [OK] HoneyToken FGA configure sur TEMOINS (AEGIS-OMEGA) et IDENTITES_REELLES


-- ============================================================
-- MECANISME 2 : VUES + SYNONYMES PUBLICS vers tables de leurre
-- Principe : utilisateur légitime → données réelles
--            utilisateur suspect/inconnu → données leurre + log
-- ============================================================

-- Trigger sur les tables de leurre : log chaque accès
CREATE OR REPLACE PROCEDURE sp_log_acces_leurre(p_table IN VARCHAR2)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  INSERT INTO alertes_securite (
    id_alerte, type_alerte, username, date_alerte, details, statut
  ) VALUES (
    seq_alertes.NEXTVAL,
    'LEURRE_ACCESS',
    SYS_CONTEXT('USERENV', 'SESSION_USER'),
    SYSTIMESTAMP,
    '[LEURRE] Acces table de leurre ' || p_table ||
    ' | IP=' || SYS_CONTEXT('USERENV', 'IP_ADDRESS') ||
    ' | OS=' || SYS_CONTEXT('USERENV', 'OS_USER'),
    'NOUVEAU'
  );
  INSERT INTO log_acces_sensibles (
    id_log, username, table_accedee, action, date_acces, details
  ) VALUES (
    seq_log_acces.NEXTVAL,
    SYS_CONTEXT('USERENV', 'SESSION_USER'),
    p_table,
    'SELECT',
    SYSTIMESTAMP,
    '[PIEGE DECLENCHE] Utilisateur a consulte table de leurre'
  );
  COMMIT;
END sp_log_acces_leurre;
/

-- Vue sécurisée TEMOINS_MASTER :
-- utilisateur habilité → vrais témoins
-- utilisateur suspect → données leurre + déclenchement alerte
CREATE OR REPLACE VIEW vw_temoins_secure AS
  SELECT
    CASE
      WHEN SYS_CONTEXT('USERENV','SESSION_USER')
           IN ('BV_DIRECTEUR','BV_COORDINATEUR','BV_ADMIN','BLACKVAULT')
      THEN t.num_dossier
      ELSE wml.codename
    END AS num_dossier,
    CASE
      WHEN SYS_CONTEXT('USERENV','SESSION_USER')
           IN ('BV_DIRECTEUR','BV_COORDINATEUR','BV_ADMIN','BLACKVAULT')
      THEN t.niveau_risque
      ELSE wml.threat_lvl
    END AS niveau_risque,
    CASE
      WHEN SYS_CONTEXT('USERENV','SESSION_USER')
           IN ('BV_DIRECTEUR','BV_COORDINATEUR','BV_ADMIN','BLACKVAULT')
      THEN t.statut
      ELSE 'DECOY'
    END AS statut
  FROM temoins t
  CROSS JOIN (SELECT * FROM leurre_witness_master_list WHERE id = 1) wml
  WHERE t.is_honeytoken = 0;

-- Vue principale avec aiguillage selon utilisateur (utilisée par le synonyme WITNESS_LIST)
-- Recréation avec un aiguillage clair
CREATE OR REPLACE VIEW vw_temoins_master AS
  SELECT
    CASE SYS_CONTEXT('USERENV','SESSION_USER')
      WHEN 'BV_DIRECTEUR'    THEN num_dossier
      WHEN 'BV_COORDINATEUR' THEN num_dossier
      WHEN 'BV_ADMIN'        THEN num_dossier
      WHEN 'BLACKVAULT'      THEN num_dossier
      ELSE 'GHOST-' || SUBSTR(num_dossier, 1, 3)
    END AS num_dossier,
    CASE SYS_CONTEXT('USERENV','SESSION_USER')
      WHEN 'BV_DIRECTEUR'    THEN niveau_risque
      WHEN 'BV_COORDINATEUR' THEN niveau_risque
      WHEN 'BV_ANALYSTE'     THEN 'CONFIDENTIEL'
      ELSE 'INCONNU'
    END AS niveau_risque,
    statut,
    id_programme
  FROM temoins
  WHERE is_honeytoken = 0;

-- Vue de leurre spécifique pour suspect (très attractive et piégée)
CREATE OR REPLACE VIEW vw_leurre_master_secret AS
  SELECT
    wml.codename     AS "WITNESS_ID",
    wml.real_name    AS "REAL_IDENTITY",
    wml.location     AS "CURRENT_LOCATION",
    wml.threat_lvl   AS "THREAT_LEVEL",
    wml.case_ref     AS "CASE_REFERENCE",
    'ULTRA-SECRET'   AS "CLASSIFICATION"
  FROM leurre_witness_master_list wml;

-- Grant de la vue leurre au suspect
GRANT SELECT ON vw_leurre_master_secret TO bv_suspect;
GRANT SELECT ON leurre_admin_credentials TO bv_suspect;
GRANT SELECT ON leurre_backup_encryption_keys TO bv_suspect;

-- Recréation des synonymes publics (avec la vue piège)
-- (déjà créés dans 01, on les recrée pour pointer vers la vue correcte)
BEGIN
  EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM witness_list';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
CREATE PUBLIC SYNONYM witness_list FOR blackvault.vw_temoins_master;

-- FGA sur les tables de leurre pour tracer accès suspects
BEGIN
  DBMS_FGA.DROP_POLICY('BLACKVAULT','LEURRE_WITNESS_MASTER_LIST','POL_LEURRE_WML');
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE OR REPLACE PROCEDURE sp_fga_leurre_wml(s IN VARCHAR2, t IN VARCHAR2)
IS PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  INSERT INTO alertes_securite VALUES (
    seq_alertes.NEXTVAL,'LEURRE_FGA_ACCESS',
    SYS_CONTEXT('USERENV','SESSION_USER'),SYSTIMESTAMP,
    '[LEURRE FGA] '||s||'.'||t||' consulte par '||
    SYS_CONTEXT('USERENV','OS_USER')||' IP='||
    SYS_CONTEXT('USERENV','IP_ADDRESS'),'NOUVEAU'
  ); COMMIT;
END;
/

BEGIN
  DBMS_FGA.ADD_POLICY(
    object_schema   => 'BLACKVAULT',
    object_name     => 'LEURRE_WITNESS_MASTER_LIST',
    policy_name     => 'POL_LEURRE_WML',
    audit_condition => '1=1',
    handler_schema  => 'BLACKVAULT',
    handler_module  => 'SP_FGA_LEURRE_WML',
    statement_types => 'SELECT',
    enable          => TRUE
  );
END;
/

PROMPT [OK] Vues de leurre et synonymes publics configures


-- ============================================================
-- MECANISME 3 : WATERMARKING
-- Chaque utilisateur voit une version légèrement différente
-- des données, permettant d'identifier l'origine d'une fuite
-- ============================================================

-- Fonction de génération de signature watermark
CREATE OR REPLACE FUNCTION fn_generate_watermark(
  p_username IN VARCHAR2,
  p_id_temoin IN NUMBER
) RETURN VARCHAR2
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  v_signature  VARCHAR2(128);
  v_salt       VARCHAR2(20) := 'BLACKVAULT2025';
  v_raw        VARCHAR2(200);
BEGIN
  -- Signature = hash de username + id_temoin + sel interne
  v_raw := p_username || '|' || p_id_temoin || '|' || v_salt ||
           '|' || TO_CHAR(SYSDATE, 'YYYYMMDD');

  v_signature := RAWTOHEX(
    UTL_RAW.CAST_TO_RAW(
      SUBSTR(v_raw, 1, 32)
    )
  );

  -- Enregistrement de la watermark générée
  INSERT INTO registre_watermarks (
    id_watermark, username, id_temoin, signature, date_generation, contexte
  ) VALUES (
    seq_watermarks.NEXTVAL, p_username, p_id_temoin, v_signature,
    SYSTIMESTAMP, 'Vue watermarkee - acces automatique'
  );

  RETURN v_signature;
END fn_generate_watermark;
/

-- Vue watermarkée : données légèrement modifiées selon utilisateur
-- Le num_dossier reçoit un suffixe invisible selon le user
-- (espace Unicode ou caractère de même largeur selon niveau habilitation)
CREATE OR REPLACE VIEW vw_temoins_watermarked AS
  SELECT
    t.id_temoin,
    t.num_dossier ||
      CASE SYS_CONTEXT('USERENV','SESSION_USER')
        WHEN 'BV_DIRECTEUR'    THEN CHR(8203)          -- Zero-width space
        WHEN 'BV_COORDINATEUR' THEN CHR(8204)          -- Zero-width non-joiner
        WHEN 'BV_ANALYSTE'     THEN CHR(8205)          -- Zero-width joiner
        ELSE                        CHR(8206)          -- Left-to-right mark
      END AS num_dossier,
    t.niveau_risque,
    t.statut,
    t.date_entree,
    t.id_programme,
    fn_generate_watermark(
      SYS_CONTEXT('USERENV','SESSION_USER'),
      t.id_temoin
    ) AS watermark_signature
  FROM temoins t
  WHERE t.is_honeytoken = 0;

-- Vue publique watermarkée (sans exposer la signature en clair)
-- La signature est enregistrée silencieusement dans REGISTRE_WATERMARKS
CREATE OR REPLACE VIEW vw_export_temoins AS
  SELECT
    id_temoin,
    num_dossier,
    niveau_risque,
    statut,
    date_entree,
    id_programme
  FROM vw_temoins_watermarked;

GRANT SELECT ON vw_export_temoins TO bv_directeur, bv_coordinateur, bv_analyste;
GRANT SELECT ON registre_watermarks TO bv_directeur, bv_admin;

-- Procédure de vérification watermark : retrouver l'origine d'une fuite
CREATE OR REPLACE PROCEDURE sp_identifier_fuite(
  p_signature IN VARCHAR2
)
IS
  v_username   VARCHAR2(50);
  v_date       TIMESTAMP;
  v_temoin     VARCHAR2(20);
BEGIN
  SELECT rw.username, rw.date_generation, t.num_dossier
  INTO v_username, v_date, v_temoin
  FROM registre_watermarks rw
  JOIN temoins t ON t.id_temoin = rw.id_temoin
  WHERE rw.signature = p_signature
  FETCH FIRST 1 ROWS ONLY;

  DBMS_OUTPUT.PUT_LINE('=== ANALYSE FUITE ===');
  DBMS_OUTPUT.PUT_LINE('Signature trouvee : ' || p_signature);
  DBMS_OUTPUT.PUT_LINE('Utilisateur source: ' || v_username);
  DBMS_OUTPUT.PUT_LINE('Date acces       : ' || TO_CHAR(v_date, 'YYYY-MM-DD HH24:MI:SS'));
  DBMS_OUTPUT.PUT_LINE('Dossier consulte : ' || v_temoin);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Signature inconnue - watermark externe au système');
END sp_identifier_fuite;
/

PROMPT [OK] Watermarking configure (vue + fonction + registre + procedure analyse)


-- ============================================================
-- MECANISME 4 : POLYINSTANCIATION
-- Meme id_temoin = données différentes selon habilitation
-- Vue filtrée dynamiquement selon SESSION_USER
-- ============================================================

-- La table LOCALISATIONS_POLY est déjà créée dans 01 et peuplée dans 02
-- On crée ici les vues et mécanismes de contrôle

-- Vue principale polyinstanciée : chaque user voit sa version
CREATE OR REPLACE VIEW vw_localisation_poly AS
  SELECT
    lp.id_temoin,
    t.num_dossier,
    lp.type_lieu,
    lp.ville,
    lp.pays,
    lp.adresse,
    lp.niveau_habilitation AS niveau_acces,
    lp.est_leurre
  FROM localisations_poly lp
  JOIN temoins t ON t.id_temoin = lp.id_temoin
  WHERE lp.niveau_habilitation = (
    CASE SYS_CONTEXT('USERENV','SESSION_USER')
      WHEN 'BV_DIRECTEUR'    THEN 'TOP_SECRET'
      WHEN 'BV_COORDINATEUR' THEN 'SECRET'
      WHEN 'BV_ANALYSTE'     THEN 'CONFIDENTIEL'
      ELSE                        'LEURRE'     -- Tout user inconnu = leurre
    END
  );

-- Fonction de contrôle habilitation : vérifie si un user peut accéder
CREATE OR REPLACE FUNCTION fn_check_habilitation(
  p_username      IN VARCHAR2,
  p_niveau_requis IN VARCHAR2
) RETURN NUMBER
IS
  v_habilitation VARCHAR2(15);
  v_ordre        NUMBER;
  v_ordre_requis NUMBER;
BEGIN
  SELECT habilitation INTO v_habilitation
  FROM utilisateurs WHERE username = p_username AND statut_actif = 1;

  -- Ordre hiérarchique
  v_ordre := CASE v_habilitation
    WHEN 'PUBLIC'       THEN 1
    WHEN 'CONFIDENTIEL' THEN 2
    WHEN 'SECRET'       THEN 3
    WHEN 'TOP_SECRET'   THEN 4
    ELSE 0
  END;

  v_ordre_requis := CASE p_niveau_requis
    WHEN 'PUBLIC'       THEN 1
    WHEN 'CONFIDENTIEL' THEN 2
    WHEN 'SECRET'       THEN 3
    WHEN 'TOP_SECRET'   THEN 4
    ELSE 99
  END;

  IF v_ordre >= v_ordre_requis THEN
    RETURN 1; -- Autorisé (Bell-LaPadula : No Read Up respecté)
  ELSE
    RETURN 0; -- Refusé
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN RETURN 0;
END fn_check_habilitation;
/

-- Grant des vues polyinstanciées à tous les users
GRANT SELECT ON vw_localisation_poly TO bv_directeur, bv_coordinateur, bv_analyste, bv_suspect;
GRANT SELECT ON vw_temoins_watermarked TO bv_directeur, bv_coordinateur, bv_analyste;

-- Vérification rapide : simulation des 4 vues selon utilisateur
-- (à exécuter connecté avec chaque user pour voir le résultat différent)
PROMPT
PROMPT === VERIFICATION POLYINSTANCIATION ===
PROMPT Connectez-vous avec chaque user et faites :
PROMPT SELECT * FROM blackvault.vw_localisation_poly;
PROMPT
PROMPT BV_DIRECTEUR    => Vraie adresse complete (TOP_SECRET)
PROMPT BV_COORDINATEUR => Ville + pays seulement (SECRET)
PROMPT BV_ANALYSTE     => Region banalisee (CONFIDENTIEL)
PROMPT BV_SUSPECT      => Fausse adresse piege (LEURRE)
PROMPT

-- Démo inline pour vérification
SELECT 'TOP_SECRET' AS niveau, lp.id_temoin, lp.ville, lp.pays, lp.adresse
FROM localisations_poly lp WHERE lp.niveau_habilitation = 'TOP_SECRET' AND lp.id_temoin = 7
UNION ALL
SELECT 'SECRET', lp.id_temoin, lp.ville, lp.pays, lp.adresse
FROM localisations_poly lp WHERE lp.niveau_habilitation = 'SECRET' AND lp.id_temoin = 7
UNION ALL
SELECT 'CONFIDENTIEL', lp.id_temoin, lp.ville, lp.pays, lp.adresse
FROM localisations_poly lp WHERE lp.niveau_habilitation = 'CONFIDENTIEL' AND lp.id_temoin = 7
UNION ALL
SELECT 'LEURRE', lp.id_temoin, lp.ville, lp.pays, lp.adresse
FROM localisations_poly lp WHERE lp.niveau_habilitation = 'LEURRE' AND lp.id_temoin = 7;

COMMIT;

PROMPT
PROMPT ========================================
PROMPT Data Deception configure avec succes :
PROMPT [1] HoneyToken FGA sur AEGIS-OMEGA
PROMPT [2] Vues + Synonymes publics de leurre
PROMPT [3] Watermarking avec registre de fuites
PROMPT [4] Polyinstanciation localisations
PROMPT Ordre suivant : 05_demo.sql
PROMPT ========================================
