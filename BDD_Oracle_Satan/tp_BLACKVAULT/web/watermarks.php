<?php
$pageName = 'Watermarks — Traçabilité des fuites';
require_once __DIR__ . '/layout.php';

if (!in_array($user['role'], ['DIRECTEUR','ADMIN'])) {
    echo '<div class="p-8 text-center bg-gray-900 border border-gray-800 rounded-lg">
        <div class="text-4xl mb-4">🔒</div>
        <div class="text-red-400 font-semibold mono">ACCÈS REFUSÉ</div>
        <div class="text-gray-600 text-sm mt-2">Le registre des watermarks est réservé au DIRECTEUR et ADMIN.</div>
    </div>';
    require_once __DIR__ . '/footer.php';
    exit;
}

$profile = getCurrentProfile();
$conn    = getDbConnection($profile);
$wmarks  = [];
$byUser  = [];

if ($conn) {
    $wmarks = queryAll($conn,
        "SELECT rw.id_watermark, rw.username, t.num_dossier,
                rw.signature, TO_CHAR(rw.date_generation,'DD/MM/YYYY HH24:MI:SS') AS gen,
                rw.contexte
         FROM blackvault.registre_watermarks rw
         LEFT JOIN blackvault.temoins t ON t.id_temoin = rw.id_temoin
         ORDER BY rw.date_generation DESC");

    $byUser = queryAll($conn,
        "SELECT username, COUNT(*) AS nb_exports, MIN(TO_CHAR(date_generation,'DD/MM HH24:MI')) AS premier,
                MAX(TO_CHAR(date_generation,'DD/MM HH24:MI')) AS dernier
         FROM blackvault.registre_watermarks
         GROUP BY username ORDER BY nb_exports DESC");

    oci_close($conn);
}
?>

<!-- Explication -->
<div class="mb-6 p-5 bg-gray-900 border border-blue-800 rounded-lg">
  <h2 class="text-blue-400 font-semibold mb-2">🔏 Watermarking — Identification des fuites de données</h2>
  <p class="text-gray-400 text-sm mb-3">
    Chaque accès à <span class="mono text-blue-300">VW_EXPORT_TEMOINS</span> génère une signature unique
    via <span class="mono text-blue-300">FN_GENERATE_WATERMARK(username, id_temoin)</span>.
    Cette signature est enregistrée silencieusement. Si des données fuient, la signature permet de retrouver
    l'utilisateur source.
  </p>
  <div class="grid grid-cols-3 gap-3 text-xs mono">
    <div class="bg-gray-800 rounded p-3">
      <div class="text-gray-500 mb-1">1. Accès vue</div>
      <div class="text-blue-400">SELECT * FROM vw_export_temoins</div>
    </div>
    <div class="bg-gray-800 rounded p-3">
      <div class="text-gray-500 mb-1">2. Signature générée</div>
      <div class="text-purple-400">FN_GENERATE_WATERMARK() → DEADBEEF...</div>
    </div>
    <div class="bg-gray-800 rounded p-3">
      <div class="text-gray-500 mb-1">3. Traçage fuite</div>
      <div class="text-green-400">SP_IDENTIFIER_FUITE(signature) → user</div>
    </div>
  </div>
</div>

<!-- Stats par utilisateur -->
<div class="mb-6">
  <h2 class="font-semibold text-gray-200 mb-3">Exports par utilisateur</h2>
  <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
    <?php if (empty($byUser)): ?>
      <div class="col-span-3 p-6 bg-gray-900 border border-gray-800 rounded-lg text-center text-gray-600 mono">
        Aucun export enregistré — aucune vue watermarkée consultée
      </div>
    <?php else: ?>
      <?php foreach ($byUser as $u2): ?>
        <div class="bg-gray-900 border border-gray-800 rounded-lg p-4">
          <div class="flex items-center justify-between mb-2">
            <span class="mono text-gray-300 font-semibold text-sm"><?= htmlspecialchars($u2['USERNAME']) ?></span>
            <span class="text-2xl font-bold mono text-blue-400"><?= $u2['NB_EXPORTS'] ?></span>
          </div>
          <div class="text-xs text-gray-600 mono">
            Premier export: <?= $u2['PREMIER'] ?><br>
            Dernier export: <?= $u2['DERNIER'] ?>
          </div>
          <div class="mt-2 w-full bg-gray-700 rounded h-1">
            <div class="bg-blue-600 h-1 rounded" style="width: <?= min(100, $u2['NB_EXPORTS'] * 10) ?>%"></div>
          </div>
        </div>
      <?php endforeach; ?>
    <?php endif; ?>
  </div>
</div>

<!-- Registre complet -->
<div class="bg-gray-900 border border-gray-800 rounded-lg overflow-hidden">
  <div class="px-5 py-4 border-b border-gray-800 flex items-center justify-between">
    <h2 class="font-semibold text-gray-200">Registre REGISTRE_WATERMARKS
      <span class="text-xs text-gray-500 ml-2 mono">(<?= count($wmarks) ?> entrées)</span>
    </h2>
  </div>

  <?php if (empty($wmarks)): ?>
    <div class="px-5 py-10 text-center text-gray-600 mono text-sm">
      Aucune watermark enregistrée.<br>
      <span class="text-xs">Consultez VW_EXPORT_TEMOINS ou VW_TEMOINS_WATERMARKED pour générer des entrées.</span>
    </div>
  <?php else: ?>
    <div class="overflow-x-auto">
      <table class="w-full text-xs">
        <thead class="bg-gray-800 text-gray-400 mono">
          <tr>
            <th class="px-4 py-3 text-left">ID</th>
            <th class="px-4 py-3 text-left">Utilisateur</th>
            <th class="px-4 py-3 text-left">Dossier</th>
            <th class="px-4 py-3 text-left">Signature (tronquée)</th>
            <th class="px-4 py-3 text-left">Date génération</th>
            <th class="px-4 py-3 text-left">Contexte</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-800">
          <?php foreach ($wmarks as $w): ?>
          <tr class="hover:bg-gray-800/50">
            <td class="px-4 py-2 mono text-gray-600">#<?= $w['ID_WATERMARK'] ?></td>
            <td class="px-4 py-2 mono text-blue-400"><?= htmlspecialchars($w['USERNAME'] ?? '—') ?></td>
            <td class="px-4 py-2 mono text-gray-300"><?= htmlspecialchars($w['NUM_DOSSIER'] ?? 'N/A') ?></td>
            <td class="px-4 py-2 mono text-green-600">
              <?= htmlspecialchars(substr($w['SIGNATURE'] ?? '', 0, 20)) ?>...
              <span title="<?= htmlspecialchars($w['SIGNATURE'] ?? '') ?>" class="text-gray-700 cursor-help">[?]</span>
            </td>
            <td class="px-4 py-2 mono text-gray-500"><?= $w['GEN'] ?></td>
            <td class="px-4 py-2 text-gray-500"><?= htmlspecialchars($w['CONTEXTE'] ?? '—') ?></td>
          </tr>
          <?php endforeach; ?>
        </tbody>
      </table>
    </div>
  <?php endif; ?>
</div>

<!-- Simulation analyse de fuite -->
<div class="mt-6 p-5 bg-gray-900 border border-green-900 rounded-lg">
  <h3 class="text-green-400 font-semibold mb-2">🔍 Simulation analyse de fuite</h3>
  <div class="text-gray-400 text-sm mb-3">
    Si des données watermarkées sont retrouvées lors d'une fuite, la procédure
    <span class="mono text-green-300">SP_IDENTIFIER_FUITE(signature)</span> permet de retrouver l'utilisateur source.
  </div>
  <?php if (!empty($wmarks)): ?>
    <div class="bg-black rounded p-4 mono text-xs space-y-1">
      <div class="text-gray-600">-- Exemple SQL Oracle :</div>
      <div class="text-green-400">SET SERVEROUTPUT ON;</div>
      <div class="text-green-400">BEGIN</div>
      <div class="text-green-400 ml-4">sp_identifier_fuite('<?= htmlspecialchars(substr($wmarks[0]['SIGNATURE'] ?? '', 0, 30)) ?>...');</div>
      <div class="text-green-400">END;</div>
      <div class="text-green-400">/</div>
      <div class="text-gray-600 mt-2">-- Output :</div>
      <div class="text-yellow-400">Signature trouvee : <?= htmlspecialchars(substr($wmarks[0]['SIGNATURE'] ?? '', 0, 30)) ?>...</div>
      <div class="text-yellow-400">Utilisateur source: <?= htmlspecialchars($wmarks[0]['USERNAME'] ?? '—') ?></div>
      <div class="text-yellow-400">Date acces       : <?= $wmarks[0]['GEN'] ?></div>
      <div class="text-yellow-400">Dossier consulte : <?= htmlspecialchars($wmarks[0]['NUM_DOSSIER'] ?? '—') ?></div>
    </div>
  <?php else: ?>
    <div class="bg-black rounded p-4 mono text-xs text-gray-600">
      Aucune signature disponible. Consultez d'abord VW_EXPORT_TEMOINS.
    </div>
  <?php endif; ?>
</div>

<?php require_once __DIR__ . '/footer.php'; ?>
