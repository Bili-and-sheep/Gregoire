<?php
$pageName = 'Tableau de bord';
require_once __DIR__ . '/layout.php';

$profile = getCurrentProfile();
$conn    = getDbConnection($profile);

// Stats selon rôle
$stats = [];
if ($conn) {
    if (in_array($user['role'], ['DIRECTEUR','COORDINATEUR','ANALYSTE'])) {
        $r = queryOne($conn, "SELECT COUNT(*) AS nb FROM blackvault.temoins WHERE is_honeytoken=0");
        $stats['temoins'] = $r['NB'] ?? '—';

        $r = queryOne($conn, "SELECT COUNT(*) AS nb FROM blackvault.menaces WHERE statut='ACTIF'");
        $stats['menaces'] = $r['NB'] ?? '—';
    }
    if ($user['role'] === 'DIRECTEUR') {
        $r = queryOne($conn, "SELECT COUNT(*) AS nb FROM blackvault.alertes_securite WHERE statut='NOUVEAU'");
        $stats['alertes'] = $r['NB'] ?? '—';

        $r = queryOne($conn, "SELECT COUNT(*) AS nb FROM blackvault.registre_watermarks");
        $stats['watermarks'] = $r['NB'] ?? '—';
    }
    if ($user['role'] === 'ADMIN') {
        $r = queryOne($conn, "SELECT COUNT(*) AS nb FROM blackvault.alertes_securite");
        $stats['alertes'] = $r['NB'] ?? '—';
        $r = queryOne($conn, "SELECT COUNT(*) AS nb FROM blackvault.utilisateurs WHERE statut_actif=1");
        $stats['users'] = $r['NB'] ?? '—';
    }

    // Dernières alertes (tous rôles habilités)
    $alertes = [];
    if (in_array($user['role'], ['DIRECTEUR','ADMIN'])) {
        $alertes = queryAll($conn,
            "SELECT type_alerte, username, TO_CHAR(date_alerte,'DD/MM HH24:MI') AS ts, SUBSTR(details,1,80) AS det, statut
             FROM blackvault.alertes_securite ORDER BY date_alerte DESC FETCH FIRST 5 ROWS ONLY");
    }
    oci_close($conn);
}
?>

<!-- Bannière suspect -->
<?php if ($user['role'] === 'SUSPECT'): ?>
<div class="mb-6 p-4 bg-yellow-950 border border-yellow-700 rounded-lg">
  <div class="text-yellow-400 font-semibold text-sm mb-1">⚠ Accès restreint — Profil non habilité</div>
  <div class="text-yellow-700 text-xs mono">Vous accédez au système avec un compte à privilèges limités. Vos actions sont tracées.</div>
</div>
<?php endif; ?>

<!-- Stats cards -->
<div class="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
  <?php
  $cards = [
    ['label' => 'Témoins actifs',    'value' => $stats['temoins']   ?? '—', 'icon' => '👤', 'color' => 'border-blue-800'],
    ['label' => 'Menaces actives',   'value' => $stats['menaces']   ?? '—', 'icon' => '⚡', 'color' => 'border-red-800'],
    ['label' => 'Alertes nouvelles', 'value' => $stats['alertes']   ?? '—', 'icon' => '🚨', 'color' => 'border-orange-800'],
    ['label' => 'Watermarks',        'value' => $stats['watermarks'] ?? ($stats['users'] ?? '—'), 'icon' => '🔏', 'color' => 'border-purple-800'],
  ];
  foreach ($cards as $c): ?>
    <div class="bg-gray-900 border <?= $c['color'] ?> rounded-lg p-5">
      <div class="text-2xl mb-2"><?= $c['icon'] ?></div>
      <div class="text-3xl font-bold text-gray-100 mono"><?= $c['value'] ?></div>
      <div class="text-xs text-gray-500 mt-1"><?= $c['label'] ?></div>
    </div>
  <?php endforeach; ?>
</div>

<!-- Grille principale -->
<div class="grid grid-cols-1 lg:grid-cols-2 gap-6">

  <!-- Dernières alertes -->
  <div class="bg-gray-900 border border-gray-800 rounded-lg">
    <div class="px-5 py-4 border-b border-gray-800 flex items-center justify-between">
      <h2 class="font-semibold text-gray-200">🚨 Dernières alertes</h2>
      <a href="alerts.php" class="text-xs text-gray-500 hover:text-gray-300">Voir tout →</a>
    </div>
    <div class="divide-y divide-gray-800">
      <?php if (empty($alertes)): ?>
        <div class="px-5 py-8 text-center text-gray-600 text-sm mono">
          <?= in_array($user['role'], ['DIRECTEUR','ADMIN']) ? 'Aucune alerte' : 'Accès non autorisé à cette section' ?>
        </div>
      <?php else: ?>
        <?php foreach ($alertes as $a): ?>
          <div class="px-5 py-3 hover:bg-gray-800/50">
            <div class="flex items-center justify-between mb-1">
              <span class="text-xs font-semibold <?= $a['TYPE_ALERTE'] === 'HONEYTOKEN_ACCESS' ? 'text-red-400' : 'text-orange-400' ?> mono">
                <?= htmlspecialchars($a['TYPE_ALERTE']) ?>
              </span>
              <span class="text-xs text-gray-600 mono"><?= $a['TS'] ?></span>
            </div>
            <div class="text-xs text-gray-400"><?= htmlspecialchars($a['DET']) ?></div>
            <div class="text-xs text-gray-600 mt-0.5 mono">User: <?= htmlspecialchars($a['USERNAME']) ?></div>
          </div>
        <?php endforeach; ?>
      <?php endif; ?>
    </div>
  </div>

  <!-- Info mécanismes Data Deception -->
  <div class="bg-gray-900 border border-gray-800 rounded-lg">
    <div class="px-5 py-4 border-b border-gray-800">
      <h2 class="font-semibold text-gray-200">🎭 Mécanismes actifs</h2>
    </div>
    <div class="p-5 space-y-3">
      <?php
      $mecanismes = [
        ['nom' => 'HoneyToken FGA', 'desc' => 'Dossier AEGIS-OMEGA piégé — alerte instantanée', 'actif' => true, 'color' => 'text-red-400'],
        ['nom' => 'Polyinstanciation', 'desc' => '4 versions par localisation selon habilitation', 'actif' => true, 'color' => 'text-orange-400'],
        ['nom' => 'Leurres + Synonymes', 'desc' => 'WITNESS_LIST, ADMIN_CREDENTIALS, BACKUP_KEYS', 'actif' => true, 'color' => 'text-yellow-400'],
        ['nom' => 'Watermarking', 'desc' => 'Signature unique par utilisateur — trace les fuites', 'actif' => true, 'color' => 'text-blue-400'],
      ];
      foreach ($mecanismes as $m): ?>
        <div class="flex items-start gap-3 p-3 bg-gray-800/50 rounded-lg">
          <span class="text-green-500 mt-0.5">●</span>
          <div>
            <div class="text-sm font-semibold <?= $m['color'] ?>"><?= $m['nom'] ?></div>
            <div class="text-xs text-gray-500"><?= $m['desc'] ?></div>
          </div>
        </div>
      <?php endforeach; ?>
    </div>
  </div>

  <!-- Classification Bell-LaPadula -->
  <div class="bg-gray-900 border border-gray-800 rounded-lg lg:col-span-2">
    <div class="px-5 py-4 border-b border-gray-800">
      <h2 class="font-semibold text-gray-200">🔒 Niveau d'accès courant — Bell-LaPadula</h2>
    </div>
    <div class="p-5">
      <div class="flex items-center gap-4 mb-4">
        <div class="text-4xl"><?= match($user['role']) {
          'DIRECTEUR' => '🔴', 'COORDINATEUR' => '🟠', 'ANALYSTE' => '🔵',
          'ADMIN' => '🟣', default => '⚫'
        } ?></div>
        <div>
          <div class="text-lg font-bold <?= match($user['role']) {
            'DIRECTEUR' => 'text-red-400', 'COORDINATEUR' => 'text-orange-400',
            'ANALYSTE' => 'text-blue-400', 'ADMIN' => 'text-purple-400', default => 'text-gray-500'
          } ?>"><?= $user['role'] ?></div>
          <div class="text-sm text-gray-500">Habilitation : <span class="mono font-bold text-gray-300"><?= $user['hab'] ?></span></div>
        </div>
      </div>
      <div class="grid grid-cols-4 gap-2 text-xs mono">
        <?php
        $niveaux = ['PUBLIC' => 1, 'CONFIDENTIEL' => 2, 'SECRET' => 3, 'TOP_SECRET' => 4];
        $mon = $niveaux[$user['hab']] ?? 0;
        foreach ($niveaux as $niv => $lvl): ?>
          <div class="p-2 rounded text-center <?= $lvl <= $mon ? 'bg-green-900/40 text-green-400 border border-green-800' : 'bg-gray-800 text-gray-600 border border-gray-700' ?>">
            <?= $niv ?><br><span class="text-lg"><?= $lvl <= $mon ? '✓' : '✗' ?></span>
          </div>
        <?php endforeach; ?>
      </div>
      <div class="text-xs text-gray-600 mono mt-3">
        Bell-LaPadula : No Read Up | Biba : No Write Up — règles enforced via vues Oracle
      </div>
    </div>
  </div>

</div>

<?php require_once __DIR__ . '/footer.php'; ?>
