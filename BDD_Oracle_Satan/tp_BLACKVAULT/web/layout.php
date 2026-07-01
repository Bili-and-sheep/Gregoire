<?php
// Layout commun — inclus en tête de chaque page
require_once __DIR__ . '/config.php';
session_start();

if (!isset($_SESSION['profile'])) {
    header('Location: index.php');
    exit;
}

$profile = $_SESSION['profile'];
$user    = USERS[$profile];
$pageName = $pageName ?? 'Dashboard';

function navLink(string $href, string $label, string $icon, string $current): string {
    $active = basename($_SERVER['PHP_SELF']) === $href
        ? 'bg-gray-800 text-white'
        : 'text-gray-400 hover:bg-gray-800 hover:text-white';
    return "<a href=\"$href\" class=\"flex items-center gap-3 px-4 py-2.5 rounded-lg $active transition-all text-sm\">
      <span class=\"text-lg\">$icon</span> $label
    </a>";
}
?>
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>BLACKVAULT — <?= htmlspecialchars($pageName) ?></title>
  <script src="https://cdn.tailwindcss.com"></script>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Share+Tech+Mono&family=Inter:wght@400;500;600;700&display=swap');
    body { font-family: 'Inter', sans-serif; }
    .mono { font-family: 'Share Tech Mono', monospace; }
    ::-webkit-scrollbar { width: 6px; }
    ::-webkit-scrollbar-track { background: #111; }
    ::-webkit-scrollbar-thumb { background: #333; border-radius: 3px; }
  </style>
</head>
<body class="bg-gray-950 text-gray-200 min-h-screen flex">

<!-- SIDEBAR -->
<aside class="w-64 min-h-screen bg-black border-r border-gray-800 flex flex-col">

  <!-- Logo -->
  <div class="px-6 py-5 border-b border-gray-800">
    <div class="text-red-500 font-bold text-xl tracking-widest">BLACKVAULT</div>
    <div class="text-gray-600 text-xs mono mt-0.5">BNPT • SYSTÈME CLASSIFIÉ</div>
  </div>

  <!-- Profil actif -->
  <div class="px-4 py-4 border-b border-gray-800">
    <div class="flex items-center gap-3">
      <div class="w-9 h-9 rounded-full bg-gray-800 flex items-center justify-center text-sm font-bold
                  <?= match($user['role']) {
                    'DIRECTEUR'    => 'text-red-400',
                    'COORDINATEUR' => 'text-orange-400',
                    'ANALYSTE'     => 'text-blue-400',
                    'ADMIN'        => 'text-purple-400',
                    default        => 'text-gray-500'
                  } ?>">
        <?= strtoupper(substr($user['role'], 0, 2)) ?>
      </div>
      <div>
        <div class="text-sm font-semibold text-gray-200"><?= htmlspecialchars($user['user']) ?></div>
        <div class="text-xs <?= habColor($user['hab']) ?> px-1.5 py-0.5 rounded mono inline-block mt-0.5">
          <?= $user['hab'] ?>
        </div>
      </div>
    </div>
  </div>

  <!-- Navigation -->
  <nav class="flex-1 px-3 py-4 space-y-1">
    <?= navLink('dashboard.php',  'Tableau de bord', '◈', $pageName) ?>
    <?= navLink('temoins.php',    'Témoins',          '👤', $pageName) ?>
    <?= navLink('localisations.php', 'Localisations',  '📍', $pageName) ?>
    <?= navLink('alerts.php',     'Alertes sécurité', '🚨', $pageName) ?>
    <?= navLink('watermarks.php', 'Watermarks',       '🔏', $pageName) ?>
    <?= navLink('deception.php',  'Data Deception',   '🎭', $pageName) ?>
  </nav>

  <!-- Logout -->
  <div class="px-3 py-4 border-t border-gray-800">
    <a href="index.php?logout=1"
       class="flex items-center gap-3 px-4 py-2 rounded-lg text-gray-600 hover:text-red-400 hover:bg-red-950/30 transition-all text-sm">
      <span>⎋</span> Déconnexion
    </a>
  </div>
</aside>

<!-- MAIN -->
<main class="flex-1 flex flex-col overflow-hidden">

  <!-- Topbar -->
  <header class="bg-black border-b border-gray-800 px-8 py-4 flex items-center justify-between">
    <div>
      <h1 class="text-lg font-semibold text-gray-100"><?= htmlspecialchars($pageName) ?></h1>
      <div class="text-xs text-gray-600 mono">
        <?= date('Y-m-d H:i:s') ?> UTC | Session Oracle: <?= htmlspecialchars($user['user']) ?>
      </div>
    </div>
    <div class="flex items-center gap-3">
      <?php if ($user['role'] === 'SUSPECT'): ?>
        <span class="text-xs bg-red-950 text-red-400 border border-red-800 px-3 py-1 rounded-full mono animate-pulse">
          ⚠ COMPTE SURVEILLE
        </span>
      <?php else: ?>
        <span class="text-xs bg-green-950 text-green-600 border border-green-900 px-3 py-1 rounded-full mono">
          ✓ CONNEXION SECURISEE
        </span>
      <?php endif; ?>
      <span class="text-xs <?= roleColor($user['role']) ?> px-3 py-1 rounded-full mono">
        <?= $user['role'] ?>
      </span>
    </div>
  </header>

  <!-- Page content -->
  <div class="flex-1 overflow-y-auto p-8">
