SELECT 
    segment_name AS table_name,
    ROUND(bytes / 1024, 2) AS taille_ko
FROM user_segments
WHERE segment_type = 'TABLE'
ORDER BY taille_ko DESC;

-- Privilèges système
SELECT privilege FROM user_sys_privs;

-- Privilèges sur objets
SELECT privilege, table_name FROM user_tab_privs;

-- Rôles attribués
SELECT granted_role FROM user_role_privs;