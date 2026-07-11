-- ============================================================
-- BLACKVAULT - Script 01 : Creation du schema
-- Oracle DB 23ai (FREEPDB1)
-- Executer en tant que SYS ou DBA : sqlplus sys/password@FREEPDB1 as sysdba
-- Re-executable : DROP + CREATE
-- ============================================================

-- ---- SUPPRESSION DES USERS EXISTANTS ----
BEGIN
  BEGIN EXECUTE IMMEDIATE 'DROP USER BLACKVAULT CASCADE';      EXCEPTION WHEN OTHERS THEN NULL; END;
  BEGIN EXECUTE IMMEDIATE 'DROP USER BV_ADMIN CASCADE';        EXCEPTION WHEN OTHERS THEN NULL; END;
  BEGIN EXECUTE IMMEDIATE 'DROP USER BV_ANALYSTE CASCADE';     EXCEPTION WHEN OTHERS THEN NULL; END;
  BEGIN EXECUTE IMMEDIATE 'DROP USER BV_COORDINATEUR CASCADE'; EXCEPTION WHEN OTHERS THEN NULL; END;
  BEGIN EXECUTE IMMEDIATE 'DROP USER BV_DIRECTEUR CASCADE';    EXCEPTION WHEN OTHERS THEN NULL; END;
  BEGIN EXECUTE IMMEDIATE 'DROP USER BV_SUSPECT CASCADE';      EXCEPTION WHEN OTHERS THEN NULL; END;
END;
/

-- ---- CREATION DU PROPRIETAIRE DU SCHEMA ----
CREATE USER blackvault IDENTIFIED BY "BlackVault#2025"
  DEFAULT TABLESPACE USERS
  QUOTA UNLIMITED ON USERS;

GRANT CREATE SESSION     TO blackvault;
GRANT CREATE TABLE       TO blackvault;
GRANT CREATE SEQUENCE    TO blackvault;
GRANT CREATE VIEW        TO blackvault;
GRANT CREATE PROCEDURE   TO blackvault;
GRANT CREATE TRIGGER     TO blackvault;
GRANT CREATE SYNONYM     TO blackvault;
GRANT CREATE PUBLIC SYNONYM TO blackvault;
GRANT DROP PUBLIC SYNONYM   TO blackvault;
GRANT EXECUTE ON DBMS_FGA   TO blackvault;

-- ---- CREATION DES USERS APPLICATIFS ----
CREATE USER bv_admin        IDENTIFIED BY "Admin#2025"   DEFAULT TABLESPACE USERS QUOTA 0 ON USERS;
CREATE USER bv_analyste     IDENTIFIED BY "Analyste#2025" DEFAULT TABLESPACE USERS QUOTA 0 ON USERS;
CREATE USER bv_coordinateur IDENTIFIED BY "Coord#2025"   DEFAULT TABLESPACE USERS QUOTA 0 ON USERS;
CREATE USER bv_directeur    IDENTIFIED BY "Direct#2025"  DEFAULT TABLESPACE USERS QUOTA 0 ON USERS;
CREATE USER bv_suspect      IDENTIFIED BY "Suspect#2025" DEFAULT TABLESPACE USERS QUOTA 0 ON USERS;

GRANT CREATE SESSION TO bv_admin, bv_analyste, bv_coordinateur, bv_directeur, bv_suspect;

-- ============================================================
-- SEQUENCES
-- ============================================================
CONNECT blackvault/"BlackVault#2025"@FREEPDB1

CREATE SEQUENCE seq_programmes     START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_temoins        START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_identites_r    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_nouvelles_id   START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_localisations  START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_affaires       START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_menaces        START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_agents         START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_assignations   START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_contacts       START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_documents      START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_transferts     START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_evaluations    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_communications START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_utilisateurs   START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_log_connexions START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_log_acces      START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_alertes        START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_watermarks     START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_poly           START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- ============================================================
-- TABLE 1 : PROGRAMMES_PROTECTION (Public / Haute intégrité)
-- ============================================================
CREATE TABLE programmes_protection (
  id_programme   NUMBER        DEFAULT seq_programmes.NEXTVAL PRIMARY KEY,
  nom            VARCHAR2(100) NOT NULL,
  pays           VARCHAR2(50)  NOT NULL,
  description    VARCHAR2(500),
  date_creation  DATE          NOT NULL,
  statut         VARCHAR2(10)  DEFAULT 'ACTIF'
    CONSTRAINT chk_prog_statut CHECK (statut IN ('ACTIF','SUSPENDU','ARCHIVE'))
);

-- ============================================================
-- TABLE 2 : AGENTS_PROTECTION (Confidentiel / Haute intégrité)
-- (avant TEMOINS car CONTACTS_AUTORISES en a besoin via FK inverse)
-- ============================================================
CREATE TABLE agents_protection (
  id_agent        NUMBER        DEFAULT seq_agents.NEXTVAL PRIMARY KEY,
  matricule       VARCHAR2(20)  UNIQUE NOT NULL,
  nom             VARCHAR2(100) NOT NULL,
  prenom          VARCHAR2(100) NOT NULL,
  grade           VARCHAR2(50),
  habilitation    VARCHAR2(15)  NOT NULL
    CONSTRAINT chk_agent_hab CHECK (habilitation IN ('PUBLIC','CONFIDENTIEL','SECRET','TOP_SECRET')),
  statut          VARCHAR2(10)  DEFAULT 'ACTIF'
    CONSTRAINT chk_agent_stat CHECK (statut IN ('ACTIF','INACTIF','SUSPENDU')),
  username_oracle VARCHAR2(50)
);

-- ============================================================
-- TABLE 3 : TEMOINS (Secret / Haute intégrité)
-- ============================================================
CREATE TABLE temoins (
  id_temoin      NUMBER        DEFAULT seq_temoins.NEXTVAL PRIMARY KEY,
  num_dossier    VARCHAR2(20)  UNIQUE NOT NULL,
  date_entree    DATE          NOT NULL,
  niveau_risque  VARCHAR2(10)  NOT NULL
    CONSTRAINT chk_tem_risque CHECK (niveau_risque IN ('FAIBLE','MODERE','ELEVE','CRITIQUE')),
  statut         VARCHAR2(15)  DEFAULT 'ACTIF'
    CONSTRAINT chk_tem_statut CHECK (statut IN ('ACTIF','RELOCALISE','SORTI','DECEDE')),
  id_programme   NUMBER        NOT NULL,
  is_honeytoken  NUMBER(1)     DEFAULT 0
    CONSTRAINT chk_honey CHECK (is_honeytoken IN (0,1)),
  CONSTRAINT fk_tem_prog FOREIGN KEY (id_programme) REFERENCES programmes_protection(id_programme)
);

-- ============================================================
-- TABLE 4 : IDENTITES_REELLES (Top Secret / Haute intégrité)
-- ============================================================
CREATE TABLE identites_reelles (
  id_identite    NUMBER        DEFAULT seq_identites_r.NEXTVAL PRIMARY KEY,
  id_temoin      NUMBER        UNIQUE NOT NULL,
  nom            VARCHAR2(100) NOT NULL,
  prenom         VARCHAR2(100) NOT NULL,
  date_naissance DATE,
  nationalite    VARCHAR2(50),
  num_identite   VARCHAR2(30)  UNIQUE,
  hash_verif     VARCHAR2(64),
  CONSTRAINT fk_idr_tem FOREIGN KEY (id_temoin) REFERENCES temoins(id_temoin)
);

-- ============================================================
-- TABLE 5 : NOUVELLES_IDENTITES / identités de couverture (Secret)
-- ============================================================
CREATE TABLE nouvelles_identites (
  id_nouvelle_id    NUMBER        DEFAULT seq_nouvelles_id.NEXTVAL PRIMARY KEY,
  id_temoin         NUMBER        NOT NULL,
  nom_couverture    VARCHAR2(100) NOT NULL,
  prenom_couverture VARCHAR2(100) NOT NULL,
  ddn_couverture    DATE,
  profession        VARCHAR2(100),
  date_attribution  DATE          NOT NULL,
  statut_actif      NUMBER(1)     DEFAULT 1
    CONSTRAINT chk_nid_actif CHECK (statut_actif IN (0,1)),
  CONSTRAINT fk_nid_tem FOREIGN KEY (id_temoin) REFERENCES temoins(id_temoin)
);

-- ============================================================
-- TABLE 6 : LOCALISATIONS (Top Secret / Haute intégrité)
-- ============================================================
CREATE TABLE localisations (
  id_localisation NUMBER        DEFAULT seq_localisations.NEXTVAL PRIMARY KEY,
  id_temoin       NUMBER        NOT NULL,
  type_lieu       VARCHAR2(15)
    CONSTRAINT chk_loc_type CHECK (type_lieu IN ('SAFE_HOUSE','APPARTEMENT','HOTEL','ETRANGER')),
  ville           VARCHAR2(100),
  pays            VARCHAR2(50),
  adresse         VARCHAR2(200),
  date_debut      DATE          NOT NULL,
  date_fin        DATE,
  actif           NUMBER(1)     DEFAULT 1
    CONSTRAINT chk_loc_actif CHECK (actif IN (0,1)),
  CONSTRAINT fk_loc_tem FOREIGN KEY (id_temoin) REFERENCES temoins(id_temoin)
);

-- ============================================================
-- TABLE 7 : AFFAIRES (Confidentiel / Haute intégrité)
-- ============================================================
CREATE TABLE affaires (
  id_affaire     NUMBER        DEFAULT seq_affaires.NEXTVAL PRIMARY KEY,
  reference      VARCHAR2(30)  UNIQUE NOT NULL,
  titre          VARCHAR2(200) NOT NULL,
  type_affaire   VARCHAR2(20)
    CONSTRAINT chk_aff_type CHECK (type_affaire IN ('CRIME_ORGANISE','TERRORISME','CORRUPTION','TRAFIC','AUTRE')),
  juridiction    VARCHAR2(100),
  date_ouverture DATE          NOT NULL,
  statut         VARCHAR2(20)
);

-- ============================================================
-- TABLE 8 : TEMOINS_AFFAIRES (Confidentiel / table de liaison)
-- ============================================================
CREATE TABLE temoins_affaires (
  id_temoin    NUMBER       NOT NULL,
  id_affaire   NUMBER       NOT NULL,
  role_temoin  VARCHAR2(50),
  date_liaison DATE,
  CONSTRAINT pk_tem_aff PRIMARY KEY (id_temoin, id_affaire),
  CONSTRAINT fk_ta_tem FOREIGN KEY (id_temoin)  REFERENCES temoins(id_temoin),
  CONSTRAINT fk_ta_aff FOREIGN KEY (id_affaire) REFERENCES affaires(id_affaire)
);

-- ============================================================
-- TABLE 9 : MENACES (Secret / Haute intégrité)
-- ============================================================
CREATE TABLE menaces (
  id_menace      NUMBER        DEFAULT seq_menaces.NEXTVAL PRIMARY KEY,
  id_temoin      NUMBER        NOT NULL,
  source         VARCHAR2(200),
  type_menace    VARCHAR2(15)
    CONSTRAINT chk_men_type CHECK (type_menace IN ('ASSASSINAT','INTIMIDATION','ENLEVEMENT','CYBERATTAQUE')),
  gravite        NUMBER(1)
    CONSTRAINT chk_men_grav CHECK (gravite BETWEEN 1 AND 5),
  date_detection DATE          NOT NULL,
  statut         VARCHAR2(20),
  details        CLOB,
  CONSTRAINT fk_men_tem FOREIGN KEY (id_temoin) REFERENCES temoins(id_temoin)
);

-- ============================================================
-- TABLE 10 : ASSIGNATIONS (Secret / Haute intégrité)
-- ============================================================
CREATE TABLE assignations (
  id_assignation NUMBER        DEFAULT seq_assignations.NEXTVAL PRIMARY KEY,
  id_temoin      NUMBER        NOT NULL,
  id_agent       NUMBER        NOT NULL,
  date_debut     DATE          NOT NULL,
  date_fin       DATE,
  role_assign    VARCHAR2(15)
    CONSTRAINT chk_ass_role CHECK (role_assign IN ('PRINCIPAL','SECONDAIRE','SURVEILLANCE')),
  CONSTRAINT fk_ass_tem FOREIGN KEY (id_temoin) REFERENCES temoins(id_temoin),
  CONSTRAINT fk_ass_agt FOREIGN KEY (id_agent)  REFERENCES agents_protection(id_agent)
);

-- ============================================================
-- TABLE 11 : CONTACTS_AUTORISES (Top Secret / Haute intégrité)
-- ============================================================
CREATE TABLE contacts_autorises (
  id_contact       NUMBER        DEFAULT seq_contacts.NEXTVAL PRIMARY KEY,
  id_temoin        NUMBER        NOT NULL,
  nom_contact      VARCHAR2(100) NOT NULL,
  lien             VARCHAR2(100),
  moyen_contact    VARCHAR2(50),
  frequence        VARCHAR2(50),
  id_agent_appro   NUMBER,
  CONSTRAINT fk_ct_tem FOREIGN KEY (id_temoin)      REFERENCES temoins(id_temoin),
  CONSTRAINT fk_ct_agt FOREIGN KEY (id_agent_appro) REFERENCES agents_protection(id_agent)
);

-- ============================================================
-- TABLE 12 : DOCUMENTS_IDENTITE (Secret / Haute intégrité)
-- ============================================================
CREATE TABLE documents_identite (
  id_document        NUMBER        DEFAULT seq_documents.NEXTVAL PRIMARY KEY,
  id_nouvelle_id     NUMBER        NOT NULL,
  type_doc           VARCHAR2(15)
    CONSTRAINT chk_doc_type CHECK (type_doc IN ('CNI','PASSEPORT','PERMIS','CARTE_VITALE')),
  numero             VARCHAR2(50)  UNIQUE NOT NULL,
  date_emission      DATE,
  date_expiration    DATE,
  autorite_emission  VARCHAR2(100),
  CONSTRAINT fk_doc_nid FOREIGN KEY (id_nouvelle_id) REFERENCES nouvelles_identites(id_nouvelle_id)
);

-- ============================================================
-- TABLE 13 : TRANSFERTS (Top Secret / Haute intégrité)
-- ============================================================
CREATE TABLE transferts (
  id_transfert    NUMBER        DEFAULT seq_transferts.NEXTVAL PRIMARY KEY,
  id_temoin       NUMBER        NOT NULL,
  id_loc_depart   NUMBER,
  id_loc_arrivee  NUMBER,
  date_transfert  DATE          NOT NULL,
  motif           VARCHAR2(200),
  id_agent_auth   NUMBER,
  statut          VARCHAR2(20)  DEFAULT 'EFFECTUE',
  CONSTRAINT fk_tr_tem  FOREIGN KEY (id_temoin)      REFERENCES temoins(id_temoin),
  CONSTRAINT fk_tr_ldep FOREIGN KEY (id_loc_depart)  REFERENCES localisations(id_localisation),
  CONSTRAINT fk_tr_larr FOREIGN KEY (id_loc_arrivee) REFERENCES localisations(id_localisation),
  CONSTRAINT fk_tr_agt  FOREIGN KEY (id_agent_auth)  REFERENCES agents_protection(id_agent)
);

-- ============================================================
-- TABLE 14 : EVALUATIONS_RISQUE (Confidentiel / Haute intégrité)
-- ============================================================
CREATE TABLE evaluations_risque (
  id_evaluation   NUMBER        DEFAULT seq_evaluations.NEXTVAL PRIMARY KEY,
  id_temoin       NUMBER        NOT NULL,
  date_evaluation DATE          NOT NULL,
  score           NUMBER(3)
    CONSTRAINT chk_eval_score CHECK (score BETWEEN 0 AND 100),
  id_evaluateur   NUMBER,
  commentaire     VARCHAR2(500),
  date_prochaine  DATE,
  CONSTRAINT fk_ev_tem FOREIGN KEY (id_temoin)    REFERENCES temoins(id_temoin),
  CONSTRAINT fk_ev_agt FOREIGN KEY (id_evaluateur) REFERENCES agents_protection(id_agent)
);

-- ============================================================
-- TABLE 15 : COMMUNICATIONS (Secret / Basse intégrité)
-- ============================================================
CREATE TABLE communications (
  id_comm         NUMBER        DEFAULT seq_communications.NEXTVAL PRIMARY KEY,
  id_temoin       NUMBER        NOT NULL,
  id_contact      NUMBER,
  date_comm       DATE          NOT NULL,
  type_comm       VARCHAR2(50),
  duree_min       NUMBER,
  id_agent_super  NUMBER,
  notes           VARCHAR2(500),
  CONSTRAINT fk_cm_tem FOREIGN KEY (id_temoin)     REFERENCES temoins(id_temoin),
  CONSTRAINT fk_cm_ct  FOREIGN KEY (id_contact)    REFERENCES contacts_autorises(id_contact),
  CONSTRAINT fk_cm_agt FOREIGN KEY (id_agent_super) REFERENCES agents_protection(id_agent)
);

-- ============================================================
-- TABLE 16 : UTILISATEURS (Confidentiel / Haute intégrité)
-- ============================================================
CREATE TABLE utilisateurs (
  id_utilisateur NUMBER        DEFAULT seq_utilisateurs.NEXTVAL PRIMARY KEY,
  username       VARCHAR2(50)  UNIQUE NOT NULL,
  role_user      VARCHAR2(15)
    CONSTRAINT chk_usr_role CHECK (role_user IN ('ADMIN','ANALYSTE','COORDINATEUR','DIRECTEUR')),
  habilitation   VARCHAR2(15)
    CONSTRAINT chk_usr_hab CHECK (habilitation IN ('PUBLIC','CONFIDENTIEL','SECRET','TOP_SECRET')),
  statut_actif   NUMBER(1)     DEFAULT 1
    CONSTRAINT chk_usr_actif CHECK (statut_actif IN (0,1))
);

-- ============================================================
-- TABLE 17 : LOG_CONNEXIONS (Public / Basse intégrité)
-- ============================================================
CREATE TABLE log_connexions (
  id_log         NUMBER        DEFAULT seq_log_connexions.NEXTVAL PRIMARY KEY,
  username       VARCHAR2(50),
  date_connexion TIMESTAMP     DEFAULT SYSTIMESTAMP,
  ip_address     VARCHAR2(45),
  succes         NUMBER(1)
    CONSTRAINT chk_logc_succ CHECK (succes IN (0,1))
);

-- ============================================================
-- TABLE 18 : LOG_ACCES_SENSIBLES (Confidentiel / Basse intégrité)
-- ============================================================
CREATE TABLE log_acces_sensibles (
  id_log        NUMBER        DEFAULT seq_log_acces.NEXTVAL PRIMARY KEY,
  username      VARCHAR2(50),
  table_accedee VARCHAR2(50),
  action        VARCHAR2(10),
  date_acces    TIMESTAMP     DEFAULT SYSTIMESTAMP,
  details       VARCHAR2(500)
);

-- ============================================================
-- TABLE 19 : ALERTES_SECURITE (Confidentiel / Basse intégrité)
-- ============================================================
CREATE TABLE alertes_securite (
  id_alerte   NUMBER         DEFAULT seq_alertes.NEXTVAL PRIMARY KEY,
  type_alerte VARCHAR2(50),
  username    VARCHAR2(50),
  date_alerte TIMESTAMP      DEFAULT SYSTIMESTAMP,
  details     VARCHAR2(1000),
  statut      VARCHAR2(10)   DEFAULT 'NOUVEAU'
    CONSTRAINT chk_alrt_stat CHECK (statut IN ('NOUVEAU','EN_COURS','FERME'))
);

-- ============================================================
-- TABLE DECEPTION 1 : REGISTRE_WATERMARKS
-- ============================================================
CREATE TABLE registre_watermarks (
  id_watermark    NUMBER        DEFAULT seq_watermarks.NEXTVAL PRIMARY KEY,
  username        VARCHAR2(50)  NOT NULL,
  id_temoin       NUMBER,
  signature       VARCHAR2(128) NOT NULL,
  date_generation TIMESTAMP     DEFAULT SYSTIMESTAMP,
  contexte        VARCHAR2(200),
  CONSTRAINT fk_wm_tem FOREIGN KEY (id_temoin) REFERENCES temoins(id_temoin)
);

-- ============================================================
-- TABLE DECEPTION 2 : LOCALISATIONS_POLY (Polyinstanciation)
-- ============================================================
CREATE TABLE localisations_poly (
  id_poly            NUMBER        DEFAULT seq_poly.NEXTVAL PRIMARY KEY,
  id_temoin          NUMBER        NOT NULL,
  niveau_habilitation VARCHAR2(15) NOT NULL
    CONSTRAINT chk_poly_niv CHECK (niveau_habilitation IN ('TOP_SECRET','SECRET','CONFIDENTIEL','LEURRE')),
  type_lieu          VARCHAR2(15),
  ville              VARCHAR2(100),
  pays               VARCHAR2(50),
  adresse            VARCHAR2(200),
  est_leurre         NUMBER(1)     DEFAULT 0,
  CONSTRAINT fk_poly_tem FOREIGN KEY (id_temoin) REFERENCES temoins(id_temoin)
);

-- ============================================================
-- TABLES DE LEURRE
-- ============================================================
CREATE TABLE leurre_admin_credentials (
  id          NUMBER PRIMARY KEY,
  username    VARCHAR2(50),
  password    VARCHAR2(100),
  role        VARCHAR2(50),
  last_login  DATE,
  notes       VARCHAR2(200)
);

CREATE TABLE leurre_witness_master_list (
  id          NUMBER PRIMARY KEY,
  codename    VARCHAR2(50),
  real_name   VARCHAR2(100),
  location    VARCHAR2(200),
  threat_lvl  VARCHAR2(10),
  case_ref    VARCHAR2(30)
);

CREATE TABLE leurre_backup_encryption_keys (
  id          NUMBER PRIMARY KEY,
  key_name    VARCHAR2(50),
  key_value   VARCHAR2(256),
  algorithm   VARCHAR2(20),
  created_at  DATE,
  expires_at  DATE
);

-- ============================================================
-- VUES METIER
-- ============================================================

-- Vue masquée TEMOINS pour ANALYSTE (masque num_dossier complet)
CREATE OR REPLACE VIEW vw_temoins_analyste AS
  SELECT
    id_temoin,
    SUBSTR(num_dossier, 1, 4) || '-XXXX' AS num_dossier,
    date_entree,
    niveau_risque,
    statut,
    id_programme
  FROM temoins
  WHERE is_honeytoken = 0;

-- Vue polyinstanciation LOCALISATIONS selon utilisateur connecté
CREATE OR REPLACE VIEW vw_localisation_securisee AS
  SELECT lp.id_temoin, lp.type_lieu, lp.ville, lp.pays, lp.adresse, lp.niveau_habilitation
  FROM localisations_poly lp
  WHERE lp.niveau_habilitation = (
    CASE SYS_CONTEXT('USERENV','SESSION_USER')
      WHEN 'BV_DIRECTEUR'    THEN 'TOP_SECRET'
      WHEN 'BV_COORDINATEUR' THEN 'SECRET'
      WHEN 'BV_ANALYSTE'     THEN 'CONFIDENTIEL'
      ELSE 'LEURRE'
    END
  );

-- Vue leurre : redirige les utilisateurs suspects vers les leurres
CREATE OR REPLACE VIEW vw_temoins_master AS
  SELECT
    CASE WHEN SYS_CONTEXT('USERENV','SESSION_USER') IN ('BV_DIRECTEUR','BV_COORDINATEUR','BV_ADMIN')
      THEN num_dossier
      ELSE 'COMPROMIS-' || SUBSTR(num_dossier, 1, 4)
    END AS num_dossier,
    CASE WHEN SYS_CONTEXT('USERENV','SESSION_USER') IN ('BV_DIRECTEUR','BV_COORDINATEUR','BV_ADMIN')
      THEN niveau_risque
      ELSE 'INCONNU'
    END AS niveau_risque,
    statut,
    id_programme
  FROM temoins
  WHERE is_honeytoken = 0;

-- Vue watermarkée des témoins
CREATE OR REPLACE VIEW vw_temoins_watermarked AS
  SELECT
    t.id_temoin,
    t.num_dossier || RPAD(' ', MOD(ASCII(SYS_CONTEXT('USERENV','SESSION_USER')),5)+1, ' ') AS num_dossier_wm,
    t.niveau_risque,
    t.statut,
    SYS_CONTEXT('USERENV','SESSION_USER') AS accessed_by
  FROM temoins t
  WHERE t.is_honeytoken = 0;

-- ============================================================
-- SYNONYMES PUBLICS (piège pour les attaquants)
-- ============================================================
CREATE PUBLIC SYNONYM witness_list         FOR blackvault.vw_temoins_master;
CREATE PUBLIC SYNONYM admin_credentials    FOR blackvault.leurre_admin_credentials;
CREATE PUBLIC SYNONYM master_identities    FOR blackvault.leurre_witness_master_list;
CREATE PUBLIC SYNONYM backup_enc_keys      FOR blackvault.leurre_backup_encryption_keys;

-- ============================================================
-- GRANTS selon matrice d'acces
-- ============================================================

-- BV_ADMIN : gestion users + logs
GRANT SELECT ON programmes_protection  TO bv_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON utilisateurs TO bv_admin;
GRANT SELECT ON log_connexions         TO bv_admin;
GRANT SELECT ON log_acces_sensibles    TO bv_admin;
GRANT SELECT ON alertes_securite       TO bv_admin;

-- BV_ANALYSTE : consultation limitee (SELECT TEMOINS requis pour que FGA HoneyToken se declenche)
GRANT SELECT ON temoins                TO bv_analyste;
GRANT SELECT ON programmes_protection  TO bv_analyste;
GRANT SELECT ON vw_temoins_analyste    TO bv_analyste;
GRANT SELECT ON affaires               TO bv_analyste;
GRANT SELECT ON temoins_affaires       TO bv_analyste;
GRANT SELECT ON agents_protection      TO bv_analyste;
GRANT SELECT ON communications         TO bv_analyste;
GRANT SELECT, INSERT, UPDATE ON menaces          TO bv_analyste;
GRANT SELECT, INSERT, UPDATE ON evaluations_risque TO bv_analyste;
GRANT SELECT ON vw_localisation_securisee TO bv_analyste;
GRANT SELECT ON vw_temoins_watermarked    TO bv_analyste;
GRANT SELECT ON witness_list              TO bv_analyste;

-- BV_COORDINATEUR : operations
GRANT SELECT ON programmes_protection    TO bv_coordinateur;
GRANT SELECT, INSERT, UPDATE ON temoins             TO bv_coordinateur;
GRANT SELECT, INSERT, UPDATE ON nouvelles_identites TO bv_coordinateur;
GRANT SELECT, INSERT, UPDATE ON localisations       TO bv_coordinateur;
GRANT SELECT ON affaires                TO bv_coordinateur;
GRANT SELECT, INSERT, UPDATE ON temoins_affaires TO bv_coordinateur;
GRANT SELECT ON menaces                 TO bv_coordinateur;
GRANT SELECT, INSERT, UPDATE ON agents_protection   TO bv_coordinateur;
GRANT SELECT, INSERT, UPDATE ON assignations        TO bv_coordinateur;
GRANT SELECT, INSERT, UPDATE ON contacts_autorises  TO bv_coordinateur;
GRANT SELECT, INSERT, UPDATE ON documents_identite  TO bv_coordinateur;
GRANT SELECT, INSERT, UPDATE ON transferts          TO bv_coordinateur;
GRANT SELECT ON evaluations_risque       TO bv_coordinateur;
GRANT SELECT ON communications           TO bv_coordinateur;
GRANT SELECT ON vw_localisation_securisee TO bv_coordinateur;
GRANT SELECT ON vw_temoins_watermarked    TO bv_coordinateur;
GRANT SELECT ON witness_list              TO bv_coordinateur;

-- BV_DIRECTEUR : acces complet (lecture) sauf admin
GRANT SELECT, INSERT, UPDATE ON programmes_protection TO bv_directeur;
GRANT SELECT, INSERT, UPDATE, DELETE ON temoins             TO bv_directeur;
GRANT SELECT ON identites_reelles        TO bv_directeur;
GRANT SELECT, INSERT, UPDATE ON nouvelles_identites TO bv_directeur;
GRANT SELECT, INSERT, UPDATE ON localisations       TO bv_directeur;
GRANT SELECT, INSERT, UPDATE, DELETE ON affaires    TO bv_directeur;
GRANT SELECT, INSERT, UPDATE, DELETE ON temoins_affaires TO bv_directeur;
GRANT SELECT, INSERT, UPDATE, DELETE ON menaces     TO bv_directeur;
GRANT SELECT, INSERT, UPDATE, DELETE ON agents_protection TO bv_directeur;
GRANT SELECT, INSERT, UPDATE, DELETE ON assignations      TO bv_directeur;
GRANT SELECT, INSERT, UPDATE ON contacts_autorises  TO bv_directeur;
GRANT SELECT, INSERT, UPDATE ON documents_identite  TO bv_directeur;
GRANT SELECT, INSERT, UPDATE ON transferts          TO bv_directeur;
GRANT SELECT, INSERT, UPDATE ON evaluations_risque  TO bv_directeur;
GRANT SELECT, INSERT, UPDATE ON communications      TO bv_directeur;
GRANT SELECT ON utilisateurs             TO bv_directeur;
GRANT SELECT ON log_connexions           TO bv_directeur;
GRANT SELECT ON log_acces_sensibles      TO bv_directeur;
GRANT SELECT ON alertes_securite         TO bv_directeur;
GRANT SELECT ON vw_localisation_securisee TO bv_directeur;
GRANT SELECT ON vw_temoins_watermarked    TO bv_directeur;
GRANT SELECT ON witness_list              TO bv_directeur;

-- BV_SUSPECT : acces uniquement aux synonymes publics (pieges)
GRANT SELECT ON witness_list           TO bv_suspect;
GRANT SELECT ON admin_credentials      TO bv_suspect;
GRANT SELECT ON master_identities      TO bv_suspect;
GRANT SELECT ON backup_enc_keys        TO bv_suspect;
GRANT SELECT ON vw_localisation_securisee TO bv_suspect;

COMMIT;

PROMPT ========================================
PROMPT Schema BLACKVAULT cree avec succes.
PROMPT Ordre suivant : 02_insert_data.sql
PROMPT ========================================
