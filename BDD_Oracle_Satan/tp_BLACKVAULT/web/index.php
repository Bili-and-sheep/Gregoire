<?php
session_start();
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['profile'])) {
    $_SESSION['profile'] = $_POST['profile'];
    header('Location: dashboard.php');
    exit;
}
if (isset($_GET['logout'])) {
    session_destroy();
}
?>
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>BLACKVAULT — Connexion</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Share+Tech+Mono&family=Inter:wght@400;600;700&display=swap');
    body { font-family: 'Inter', sans-serif; }
    .mono { font-family: 'Share Tech Mono', monospace; }
    .scanline {
      background: repeating-linear-gradient(0deg, transparent, transparent 2px, rgba(0,255,0,0.015) 2px, rgba(0,255,0,0.015) 4px);
      pointer-events: none;
    }
  </style>
</head>
<body class="bg-black min-h-screen flex items-center justify-center relative overflow-hidden">

  <!-- Fond scanline -->
  <div class="scanline fixed inset-0 z-0"></div>

  <!-- Effet grille -->
  <div class="fixed inset-0 z-0 opacity-5"
       style="background-image: linear-gradient(#00ff00 1px, transparent 1px), linear-gradient(90deg, #00ff00 1px, transparent 1px); background-size: 40px 40px;"></div>

  <div class="relative z-10 w-full max-w-md px-6">

    <!-- Header -->
    <div class="text-center mb-10">
      <div class="mono text-green-400 text-xs tracking-widest mb-2 animate-pulse">
        ███ SYSTEME CLASSIFIE ███
      </div>
      <div class="text-red-500 font-bold text-4xl tracking-widest mb-1">BLACKVAULT</div>
      <div class="text-gray-500 text-xs mono tracking-widest">BUREAU NATIONAL DE PROTECTION DES TÉMOINS</div>
      <div class="text-gray-600 text-xs mono mt-1">v2.6.1-SECURE | ORACLE 26ai</div>
    </div>

    <!-- Card -->
    <div class="bg-gray-950 border border-gray-800 rounded-lg p-8 shadow-2xl shadow-green-900/20">

      <div class="text-gray-400 text-sm mb-6 mono text-center">
        SÉLECTION DU PROFIL D'ACCÈS
      </div>

      <form method="POST" action="">
        <div class="space-y-3 mb-8">

          <!-- Directeur -->
          <label class="flex items-center gap-4 p-4 rounded border border-gray-800 hover:border-red-800 hover:bg-red-950/30 cursor-pointer transition-all group">
            <input type="radio" name="profile" value="directeur" class="accent-red-500">
            <div class="flex-1">
              <div class="text-red-400 font-semibold group-hover:text-red-300">DIRECTEUR</div>
              <div class="text-gray-600 text-xs mono">Habilitation: TOP_SECRET • Accès total</div>
            </div>
            <span class="text-xs bg-red-900 text-red-300 px-2 py-1 rounded mono">TS</span>
          </label>

          <!-- Coordinateur -->
          <label class="flex items-center gap-4 p-4 rounded border border-gray-800 hover:border-orange-700 hover:bg-orange-950/30 cursor-pointer transition-all group">
            <input type="radio" name="profile" value="coordinateur" class="accent-orange-500">
            <div class="flex-1">
              <div class="text-orange-400 font-semibold group-hover:text-orange-300">COORDINATEUR</div>
              <div class="text-gray-600 text-xs mono">Habilitation: SECRET • Accès opérationnel</div>
            </div>
            <span class="text-xs bg-orange-900 text-orange-300 px-2 py-1 rounded mono">S</span>
          </label>

          <!-- Analyste -->
          <label class="flex items-center gap-4 p-4 rounded border border-gray-800 hover:border-blue-700 hover:bg-blue-950/30 cursor-pointer transition-all group">
            <input type="radio" name="profile" value="analyste" class="accent-blue-500">
            <div class="flex-1">
              <div class="text-blue-400 font-semibold group-hover:text-blue-300">ANALYSTE</div>
              <div class="text-gray-600 text-xs mono">Habilitation: CONFIDENTIEL • Accès limité</div>
            </div>
            <span class="text-xs bg-blue-900 text-blue-300 px-2 py-1 rounded mono">C</span>
          </label>

          <!-- Admin -->
          <label class="flex items-center gap-4 p-4 rounded border border-gray-800 hover:border-purple-700 hover:bg-purple-950/30 cursor-pointer transition-all group">
            <input type="radio" name="profile" value="admin" class="accent-purple-500">
            <div class="flex-1">
              <div class="text-purple-400 font-semibold group-hover:text-purple-300">ADMIN SYSTÈME</div>
              <div class="text-gray-600 text-xs mono">Habilitation: CONFIDENTIEL • Gestion users/logs</div>
            </div>
            <span class="text-xs bg-purple-900 text-purple-300 px-2 py-1 rounded mono">A</span>
          </label>

          <!-- Suspect (séparé visuellement) -->
          <div class="border-t border-gray-800 pt-3">
            <label class="flex items-center gap-4 p-4 rounded border border-gray-800 hover:border-gray-600 hover:bg-gray-900/50 cursor-pointer transition-all group opacity-70">
              <input type="radio" name="profile" value="suspect" class="accent-gray-500">
              <div class="flex-1">
                <div class="text-gray-500 font-semibold group-hover:text-gray-400 line-through">COMPTE COMPROMIS</div>
                <div class="text-gray-700 text-xs mono">Accès suspect — mécanismes de déception actifs</div>
              </div>
              <span class="text-xs bg-gray-900 text-gray-600 px-2 py-1 rounded mono border border-gray-700">⚠</span>
            </label>
          </div>
        </div>

        <button type="submit"
          class="w-full bg-green-900 hover:bg-green-800 border border-green-700 text-green-400 hover:text-green-300 font-semibold py-3 rounded mono tracking-widest transition-all text-sm">
          AUTHENTIFICATION →
        </button>
      </form>
    </div>

    <!-- Footer -->
    <div class="text-center mt-6 text-gray-700 text-xs mono space-y-1">
      <div>CLASSIFICATION: TOP SECRET / ALPHA</div>
      <div>Tout accès non autorisé est tracé et constitue une infraction pénale</div>
    </div>

  </div>
</body>
</html>
