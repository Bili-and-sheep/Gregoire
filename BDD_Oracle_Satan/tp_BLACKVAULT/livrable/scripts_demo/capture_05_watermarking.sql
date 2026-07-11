-- ============================================================
-- CAPTURE 5 : Watermarking — traçabilité des exports
-- ============================================================

-- ---- ETAPE 1 : Connexion bv_coordinateur / Coord#2025 ----
-- Export silencieusement watermarké
SELECT id_temoin     AS "ID Témoin",
       num_dossier   AS "Dossier",
       niveau_risque AS "Niveau risque",
       statut        AS "Statut"
FROM   blackvault.vw_export_temoins
FETCH FIRST 5 ROWS ONLY;

-- ---- ETAPE 2 : Connexion bv_analyste / Analyste#2025 ----
-- Export avec un watermark différent
SELECT id_temoin     AS "ID Témoin",
       num_dossier   AS "Dossier",
       niveau_risque AS "Niveau risque"
FROM   blackvault.vw_export_temoins
FETCH FIRST 5 ROWS ONLY;

-- ============================================================
-- ETAPE 3 : Connexion blackvault / BlackVault#2025
-- Registre des watermarks : qui a exporté quoi
-- ============================================================
SELECT rw.username                                        AS "Utilisateur",
       t.num_dossier                                      AS "Dossier exporté",
       SUBSTR(rw.signature, 1, 40) || '...'              AS "Signature (tronquée)",
       TO_CHAR(rw.date_generation,'YYYY-MM-DD HH24:MI:SS') AS "Date export",
       rw.contexte                                        AS "Contexte"
FROM   registre_watermarks rw
JOIN   temoins t ON t.id_temoin = rw.id_temoin
ORDER  BY rw.date_generation DESC;

-- ============================================================
-- ETAPE 4 : Identification de la source d'une fuite
-- (toujours connexion blackvault)
-- ============================================================
SET SERVEROUTPUT ON;
DECLARE
  v_sig VARCHAR2(128);
BEGIN
  -- Prend la première signature enregistrée (simuler une fuite)
  SELECT signature INTO v_sig
  FROM   registre_watermarks
  WHERE  ROWNUM = 1;

  DBMS_OUTPUT.PUT_LINE('=== SIMULATION IDENTIFICATION FUITE ===');
  DBMS_OUTPUT.PUT_LINE('Signature interceptée : ' || v_sig);
  DBMS_OUTPUT.PUT_LINE('');
  sp_identifier_fuite(v_sig);
END;
/
