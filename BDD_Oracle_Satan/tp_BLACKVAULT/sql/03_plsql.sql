-- ============================================================
-- BLACKVAULT - Script 03 : PL/SQL
-- 1 Fonction + 1 Procédure
-- Executer apres 02_insert_data.sql
-- ============================================================

CONNECT blackvault/"BlackVault#2025"@FREEPDB1

-- ============================================================
-- FONCTION : FN_CALCUL_SCORE_RISQUE
-- Calcule un score de risque composite (0-100) pour un temoin
-- Prend en compte :
--   - niveau_risque declare (40%)
--   - menaces actives (40%)
--   - derniere evaluation (20%)
-- ============================================================
CREATE OR REPLACE FUNCTION fn_calcul_score_risque(p_id_temoin IN NUMBER)
RETURN NUMBER
IS
  v_niveau_risque    VARCHAR2(10);
  v_score_base       NUMBER := 0;
  v_score_menaces    NUMBER := 0;
  v_score_eval       NUMBER := 0;
  v_nb_menaces       NUMBER := 0;
  v_gravite_max      NUMBER := 0;
  v_derniere_eval    NUMBER := NULL;
  v_score_final      NUMBER := 0;
BEGIN
  -- Niveau de risque déclaré (contribue à 40% du score)
  SELECT niveau_risque INTO v_niveau_risque
  FROM temoins WHERE id_temoin = p_id_temoin;

  v_score_base := CASE v_niveau_risque
    WHEN 'FAIBLE'    THEN 15
    WHEN 'MODERE'    THEN 35
    WHEN 'ELEVE'     THEN 65
    WHEN 'CRITIQUE'  THEN 90
    ELSE 0
  END;

  -- Menaces actives : nb de menaces + gravité max (40%)
  SELECT COUNT(*), NVL(MAX(gravite), 0)
  INTO v_nb_menaces, v_gravite_max
  FROM menaces
  WHERE id_temoin = p_id_temoin AND statut = 'ACTIF';

  -- Score menaces : gravité max * 12 + nb menaces * 4 (plafond 100)
  v_score_menaces := LEAST(v_gravite_max * 12 + v_nb_menaces * 4, 100);

  -- Dernière évaluation officielle (20%)
  BEGIN
    SELECT score INTO v_derniere_eval
    FROM evaluations_risque
    WHERE id_temoin = p_id_temoin
    ORDER BY date_evaluation DESC
    FETCH FIRST 1 ROWS ONLY;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN v_derniere_eval := NULL;
  END;

  -- Score final pondéré
  IF v_derniere_eval IS NOT NULL THEN
    v_score_final := ROUND(v_score_base * 0.4 + v_score_menaces * 0.4 + v_derniere_eval * 0.2);
  ELSE
    v_score_final := ROUND(v_score_base * 0.5 + v_score_menaces * 0.5);
  END IF;

  -- Plafonner entre 0 et 100
  RETURN LEAST(GREATEST(v_score_final, 0), 100);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN -1; -- Temoin introuvable
  WHEN OTHERS THEN
    RETURN -2; -- Erreur technique
END fn_calcul_score_risque;
/

-- Test rapide de la fonction
PROMPT --- Test FN_CALCUL_SCORE_RISQUE ---
SELECT
  t.num_dossier,
  t.niveau_risque,
  fn_calcul_score_risque(t.id_temoin) AS score_calcule
FROM temoins t
WHERE t.is_honeytoken = 0
ORDER BY score_calcule DESC
FETCH FIRST 5 ROWS ONLY;


-- ============================================================
-- PROCEDURE : SP_RELOCALISER_TEMOIN
-- Relocalisaton complète d'un témoin :
--   1. Ferme la localisation active
--   2. Crée la nouvelle localisation
--   3. Enregistre le transfert
--   4. Met à jour le statut du témoin
--   5. Log dans LOG_ACCES_SENSIBLES
-- ============================================================
CREATE OR REPLACE PROCEDURE sp_relocaliser_temoin(
  p_id_temoin      IN NUMBER,
  p_ville          IN VARCHAR2,
  p_pays           IN VARCHAR2,
  p_type_lieu      IN VARCHAR2,
  p_adresse        IN VARCHAR2,
  p_motif          IN VARCHAR2,
  p_id_agent_auth  IN NUMBER
)
IS
  v_id_loc_depart   NUMBER := NULL;
  v_id_loc_arrivee  NUMBER;
  v_num_dossier     VARCHAR2(20);
  v_statut_temoin   VARCHAR2(15);
BEGIN
  -- Vérification que le temoin existe
  SELECT num_dossier, statut
  INTO v_num_dossier, v_statut_temoin
  FROM temoins
  WHERE id_temoin = p_id_temoin;

  IF v_statut_temoin IN ('SORTI', 'DECEDE') THEN
    RAISE_APPLICATION_ERROR(-20001,
      'Temoin ' || v_num_dossier || ' non eligible : statut ' || v_statut_temoin);
  END IF;

  -- Fermeture de la localisation active
  BEGIN
    SELECT id_localisation INTO v_id_loc_depart
    FROM localisations
    WHERE id_temoin = p_id_temoin AND actif = 1
    FETCH FIRST 1 ROWS ONLY;

    UPDATE localisations
    SET actif = 0, date_fin = SYSDATE
    WHERE id_localisation = v_id_loc_depart;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_id_loc_depart := NULL; -- Pas de localisation active (première fois)
  END;

  -- Création de la nouvelle localisation
  INSERT INTO localisations (
    id_localisation, id_temoin, type_lieu, ville, pays, adresse, date_debut, actif
  ) VALUES (
    seq_localisations.NEXTVAL, p_id_temoin, p_type_lieu, p_ville, p_pays, p_adresse, SYSDATE, 1
  ) RETURNING id_localisation INTO v_id_loc_arrivee;

  -- Enregistrement du transfert
  INSERT INTO transferts (
    id_transfert, id_temoin, id_loc_depart, id_loc_arrivee,
    date_transfert, motif, id_agent_auth, statut
  ) VALUES (
    seq_transferts.NEXTVAL, p_id_temoin, v_id_loc_depart, v_id_loc_arrivee,
    SYSDATE, p_motif, p_id_agent_auth, 'EFFECTUE'
  );

  -- Mise à jour statut du témoin
  UPDATE temoins
  SET statut = 'RELOCALISE'
  WHERE id_temoin = p_id_temoin AND statut = 'ACTIF';

  -- Journalisation sécurisée
  INSERT INTO log_acces_sensibles (
    id_log, username, table_accedee, action, date_acces, details
  ) VALUES (
    seq_log_acces.NEXTVAL,
    SYS_CONTEXT('USERENV', 'SESSION_USER'),
    'TEMOINS+LOCALISATIONS+TRANSFERTS',
    'UPDATE',
    SYSTIMESTAMP,
    'Relocalisation temoin ' || v_num_dossier || ' vers ' || p_ville || ', ' || p_pays
  );

  COMMIT;

  DBMS_OUTPUT.PUT_LINE('[OK] Temoin ' || v_num_dossier ||
    ' relocalisé vers ' || p_ville || ' (' || p_pays || ')');
  DBMS_OUTPUT.PUT_LINE('[OK] Transfert enregistré, ancienne loc: ' ||
    NVL(TO_CHAR(v_id_loc_depart), 'AUCUNE') ||
    ' → nouvelle loc: ' || v_id_loc_arrivee);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20002, 'Temoin ID=' || p_id_temoin || ' introuvable.');
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20099, 'Erreur relocalisation: ' || SQLERRM);
END sp_relocaliser_temoin;
/

-- Test de la procedure
PROMPT --- Test SP_RELOCALISER_TEMOIN ---
SET SERVEROUTPUT ON;

-- Relocalisation du temoin 2 (BVT-2019-002) vers Montpellier
BEGIN
  sp_relocaliser_temoin(
    p_id_temoin     => 2,
    p_ville         => 'Montpellier',
    p_pays          => 'France',
    p_type_lieu     => 'SAFE_HOUSE',
    p_adresse       => '78 rue de la Vieille Tour',
    p_motif         => 'Relocalisation préventive - activité réseau Falcon détectée à Bordeaux',
    p_id_agent_auth => 3
  );
END;
/

-- Vérification
SELECT loc.ville, loc.pays, loc.actif, loc.date_debut
FROM localisations loc
WHERE loc.id_temoin = 2
ORDER BY loc.date_debut;

PROMPT ========================================
PROMPT PL/SQL cree et teste avec succes.
PROMPT Ordre suivant : 04_deception.sql
PROMPT ========================================
