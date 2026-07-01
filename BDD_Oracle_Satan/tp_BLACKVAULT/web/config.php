<?php
// ============================================================
// BLACKVAULT - Configuration Oracle DB
// ============================================================

define('DB_HOST', 'localhost');
define('DB_PORT', '1521');
define('DB_SID',  'FREEPDB1');

// Credentials par profil utilisateur
const USERS = [
    'directeur'    => ['user' => 'bv_directeur',    'pass' => 'Direct#2025',   'role' => 'DIRECTEUR',    'hab' => 'TOP_SECRET'],
    'coordinateur' => ['user' => 'bv_coordinateur', 'pass' => 'Coord#2025',    'role' => 'COORDINATEUR', 'hab' => 'SECRET'],
    'analyste'     => ['user' => 'bv_analyste',     'pass' => 'Analyste#2025', 'role' => 'ANALYSTE',     'hab' => 'CONFIDENTIEL'],
    'admin'        => ['user' => 'bv_admin',         'pass' => 'Admin#2025',    'role' => 'ADMIN',        'hab' => 'CONFIDENTIEL'],
    'suspect'      => ['user' => 'bv_suspect',       'pass' => 'Suspect#2025',  'role' => 'SUSPECT',      'hab' => 'AUCUNE'],
];

function getDbConnection(string $profile): \OCI8Connection|false {
    if (!isset(USERS[$profile])) return false;
    $u = USERS[$profile];
    $dsn = DB_HOST . ':' . DB_PORT . '/' . DB_SID;
    $conn = @oci_connect($u['user'], $u['pass'], $dsn, 'AL32UTF8');
    return $conn;
}

function queryAll(\OCI8Connection $conn, string $sql, array $binds = []): array {
    $stmt = oci_parse($conn, $sql);
    foreach ($binds as $k => $v) oci_bind_by_name($stmt, $k, $v);
    oci_execute($stmt);
    $rows = [];
    while ($row = oci_fetch_assoc($stmt)) $rows[] = $row;
    oci_free_statement($stmt);
    return $rows;
}

function queryOne(\OCI8Connection $conn, string $sql, array $binds = []): array|null {
    $rows = queryAll($conn, $sql, $binds);
    return $rows[0] ?? null;
}

function getProfile(): array|null {
    session_start();
    if (!isset($_SESSION['profile'])) return null;
    return USERS[$_SESSION['profile']] ?? null;
}

function getCurrentProfile(): string {
    session_start();
    return $_SESSION['profile'] ?? '';
}

// Couleurs par rôle
function roleColor(string $role): string {
    return match($role) {
        'DIRECTEUR'    => 'text-red-400 bg-red-950',
        'COORDINATEUR' => 'text-orange-400 bg-orange-950',
        'ANALYSTE'     => 'text-blue-400 bg-blue-950',
        'ADMIN'        => 'text-purple-400 bg-purple-950',
        'SUSPECT'      => 'text-gray-400 bg-gray-900 line-through',
        default        => 'text-gray-400 bg-gray-900',
    };
}

function habColor(string $hab): string {
    return match($hab) {
        'TOP_SECRET'   => 'bg-red-600 text-white',
        'SECRET'       => 'bg-orange-500 text-white',
        'CONFIDENTIEL' => 'bg-yellow-500 text-black',
        'PUBLIC'       => 'bg-green-600 text-white',
        default        => 'bg-gray-600 text-white',
    };
}

function risqueColor(string $r): string {
    return match($r) {
        'CRITIQUE' => 'bg-red-600 text-white',
        'ELEVE'    => 'bg-orange-500 text-white',
        'MODERE'   => 'bg-yellow-500 text-black',
        'FAIBLE'   => 'bg-green-600 text-white',
        default    => 'bg-gray-500 text-white',
    };
}
