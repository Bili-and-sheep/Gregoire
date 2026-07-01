<?php
$pageName = 'Alertes Sécurité';
require_once __DIR__ . '/layout.php';

if (!in_array($user['role'], ['DIRECTEUR','ADMIN'])) {
    echo '<div class="p-8 text-center bg-gray-900 border border-gray-800 rounded-lg">
        <div class="text-4xl mb-4">🔒</div>
        <div class="text-red-400 font-semibold mono">ACCÈS REFUSÉ</div>
        <div class="text-gray-600 text-sm mt-2">Habilitation insuffisante pour accéder aux alertes de sécurité.</div>
        <div class="text-gray-700 text-xs mono mt-1">Bell-LaPadula: No Read Up — Niveau requis: CONFIDENTIEL</div>
    </div>';
    require_once __DIR__ . '/footer.php';
    exit;
}

$profile = getCurrentProfile();
$conn    = getDbConnection($profile);
$alertes = [];
$logs    = [];
$stats   = [];

if ($conn) {
    $alertes = queryAll($conn,
        "SELECT id_alerte, type_alerte, username,
                TO_CHAR(date_alerte,'DD/MM/YYYY HH24:MI:SS') AS date_alerte,
                details, statut
         FROM blackvault.alertes_securite
         ORDER BY date_alerte DESC");

    $logs = queryAll($conn,
        "SELECT username, table_accedee, action,
                TO_CHAR(date_acces,'DD/MM/YYYY HH24:MI:SS') AS date_acces,
                SUBSTR(details, 1, 100) AS details
         FROM blackvault.log_acces_sensibles
         ORDER BY date_acces DESC
         FETCH FIRST 20 ROWS ONLY");

    $stats = queryAll($conn,
        "SELECT type_alerte, COUNT(*) AS nb
         FROM blackvault.alertes_securite
         GROUP BY type_alerte ORDER BY nb DESC");

    oci_close($conn);
}

$typeColors = [
    'HONEYTOKEN_ACCESS' => ['bg-red-950 border-red-800 text-red-400', '🍯'],
    'LEURRE_ACCESS'     => ['bg-orange-950 border-orange-800 text-orange-400', '🎭'],
    'LEURRE_FGA_ACCESS' => ['bg-yellow-950 border-yellow-800 text-yellow-500', '🎯'],
    'FGA_IDENTITE'      => ['bg-purple-950 border-purple-800 text-purple-400', '👁'],
];
?>

<!-- Stats par type -->
<div class="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
  <?php
  $types = array_column($stats, 'NB', 'TYPE_ALERTE');
  $allTypes = ['HONEYTOKEN_ACCESS', 'LEURRE_ACCESS', 'LEURRE_FGA_ACCESS', 'FGA_IDENTITE'];
  $labels = ['HoneyToken', 'Leurre accès', 'Leurre FGA', 'Identité FGA'];
  $icons  = ['🍯', '🎭', '🎯', '👁'];
  foreach ($allTypes as $i => $t): ?>
    <div class="bg-gray-900 border border-gray-800 rounded-lg p-4">
      <div class="text-2xl mb-2"><?= $icons[$i] ?></div>
      <div class="text-3xl font-bold mono text-gray-100"><?= $types[$t] ?? 0 ?></div>
      <div class="text-xs text-gray-500 mono"><?= $labels[$i] ?></div>
    </div>
  <?php endforeach; ?>
</div>

<!-- Alertes -->
<div class="bg-gray-900 border border-gray-800 rounded-lg mb-6">
  <div class="px-5 py-4 border-b border-gray-800 flex items-center justify-between">
    <h2 class="font-semibold text-gray-200">🚨 Alertes de sécurité
      <span class="text-xs text-gray-500 ml-2 mono">(<?= count($alertes) ?> total)</span>
    </h2>
    <span class="text-xs text-gray-500 mono">TABLE: ALERTES_SECURITE + FGA</span>
  </div>

  <div class="divide-y divide-gray-800">
    <?php if (empty($alertes)): ?>
      <div class="px-5 py-10 text-center text-gray-600 mono text-sm">
        Aucune alerte enregistrée — système nominal
      </div>
    <?php else: ?>
      <?php foreach ($alertes as $a):
        $style = $typeColors[$a['TYPE_ALERTE']] ?? ['bg-gray-900 border-gray-800 text-gray-400', '⚠'];
      ?>
        <div class="px-5 py-4 hover:bg-gray-800/50 transition-colors">
          <div class="flex items-start justify-between gap-4">
            <div class="flex items-start gap-3">
              <span class="text-xl mt-0.5"><?= $style[1] ?></span>
              <div>
                <div class="flex items-center gap-2 mb-1">
                  <span class="text-xs font-bold mono <?= explode(' ', $style[0])[2] ?>">
                    <?= htmlspecialchars($a['TYPE_ALERTE']) ?>
                  </span>
                  <span class="text-xs px-1.5 py-0.5 rounded mono <?= $a['STATUT'] === 'NOUVEAU' ? 'bg-red-900 text-red-400' : 'bg-gray-700 text-gray-500' ?>">
                    <?= $a['STATUT'] ?>
                  </span>
                </div>
                <div class="text-xs text-gray-400 mb-1">
                  <?= htmlspecialchars(substr($a['DETAILS'], 0, 150)) ?>
                  <?= strlen($a['DETAILS']) > 150 ? '...' : '' ?>
                </div>
                <div class="text-xs text-gray-600 mono">
                  User: <span class="text-gray-400"><?= htmlspecialchars($a['USERNAME']) ?></span>
                  | ID: <?= $a['ID_ALERTE'] ?>
                </div>
              </div>
            </div>
            <div class="text-xs text-gray-600 mono whitespace-nowrap"><?= $a['DATE_ALERTE'] ?></div>
          </div>
        </div>
      <?php endforeach; ?>
    <?php endif; ?>
  </div>
</div>

<!-- Log accès sensibles -->
<div class="bg-gray-900 border border-gray-800 rounded-lg">
  <div class="px-5 py-4 border-b border-gray-800">
    <h2 class="font-semibold text-gray-200">📋 Log des accès sensibles
      <span class="text-xs text-gray-500 ml-2 mono">(20 derniers)</span>
    </h2>
  </div>
  <div class="overflow-x-auto">
    <table class="w-full text-xs">
      <thead class="bg-gray-800 text-gray-400 mono">
        <tr>
          <th class="px-4 py-2 text-left">Utilisateur</th>
          <th class="px-4 py-2 text-left">Table</th>
          <th class="px-4 py-2 text-left">Action</th>
          <th class="px-4 py-2 text-left">Date</th>
          <th class="px-4 py-2 text-left">Détails</th>
        </tr>
      </thead>
      <tbody class="divide-y divide-gray-800">
        <?php foreach ($logs as $l): ?>
        <tr class="hover:bg-gray-800/50">
          <td class="px-4 py-2 mono text-gray-300"><?= htmlspecialchars($l['USERNAME'] ?? '—') ?></td>
          <td class="px-4 py-2 mono text-blue-400"><?= htmlspecialchars($l['TABLE_ACCEDEE'] ?? '—') ?></td>
          <td class="px-4 py-2">
            <span class="px-1.5 py-0.5 rounded mono <?= match($l['ACTION'] ?? '') {
              'SELECT' => 'bg-blue-900 text-blue-400',
              'UPDATE' => 'bg-orange-900 text-orange-400',
              'INSERT' => 'bg-green-900 text-green-400',
              'DELETE' => 'bg-red-900 text-red-400',
              default  => 'bg-gray-700 text-gray-400',
            } ?>"><?= htmlspecialchars($l['ACTION'] ?? '—') ?></span>
          </td>
          <td class="px-4 py-2 mono text-gray-500"><?= $l['DATE_ACCES'] ?></td>
          <td class="px-4 py-2 text-gray-500"><?= htmlspecialchars($l['DETAILS'] ?? '—') ?></td>
        </tr>
        <?php endforeach; ?>
      </tbody>
    </table>
  </div>
</div>

<?php require_once __DIR__ . '/footer.php'; ?>
