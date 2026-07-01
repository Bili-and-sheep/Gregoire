<?php
$pageName = 'Localisations — Polyinstanciation';
require_once __DIR__ . '/layout.php';

$profile = getCurrentProfile();
$conn    = getDbConnection($profile);
$locs    = [];
$niveau  = 'INCONNU';

// Mapping profil → niveau d'habilitation reçu
$niveauMap = [
    'directeur'    => 'TOP_SECRET',
    'coordinateur' => 'SECRET',
    'analyste'     => 'CONFIDENTIEL',
    'suspect'      => 'LEURRE',
    'admin'        => 'AUCUN',
];
$niveau = $niveauMap[$profile] ?? 'INCONNU';

if ($conn && $user['role'] !== 'ADMIN') {
    $locs = queryAll($conn,
        "SELECT id_temoin, num_dossier, type_lieu, ville, pays, adresse, niveau_acces, est_leurre
         FROM blackvault.vw_localisation_poly
         ORDER BY id_temoin");
    oci_close($conn);
}

// Démonstration comparative (vue BLACKVAULT = admin)
$conn2 = getDbConnection('directeur');
$allVersions = [];
if ($conn2) {
    $allVersions = queryAll($conn2,
        "SELECT lp.id_temoin, t.num_dossier, lp.niveau_habilitation,
                lp.type_lieu, lp.ville, lp.pays, lp.adresse, lp.est_leurre
         FROM blackvault.localisations_poly lp
         JOIN blackvault.temoins t ON t.id_temoin = lp.id_temoin
         ORDER BY lp.id_temoin, DECODE(lp.niveau_habilitation,'TOP_SECRET',1,'SECRET',2,'CONFIDENTIEL',3,'LEURRE',4)");
    oci_close($conn2);
}

// Regrouper par temoin
$byTemoin = [];
foreach ($allVersions as $v) {
    $byTemoin[$v['ID_TEMOIN']][$v['NIVEAU_HABILITATION']] = $v;
}
?>

<!-- Explication Polyinstanciation -->
<div class="mb-6 p-5 bg-gray-900 border border-purple-800 rounded-lg">
  <h2 class="text-purple-400 font-semibold mb-2">🎭 Polyinstanciation — Même identifiant, données différentes</h2>
  <p class="text-gray-400 text-sm">
    Le même <span class="mono text-purple-300">id_temoin</span> existe en 4 versions dans
    <span class="mono text-purple-300">LOCALISATIONS_POLY</span>.
    La vue <span class="mono text-purple-300">VW_LOCALISATION_POLY</span> filtre dynamiquement via
    <span class="mono text-purple-300">SYS_CONTEXT('USERENV','SESSION_USER')</span>.
    Un utilisateur suspect reçoit automatiquement une fausse localisation.
  </p>
</div>

<!-- Vue actuelle de l'utilisateur connecté -->
<div class="mb-6">
  <div class="flex items-center gap-3 mb-4">
    <h2 class="font-semibold text-gray-200">Ce que vous voyez (<?= htmlspecialchars($user['role']) ?>)</h2>
    <span class="text-xs px-2 py-1 rounded mono <?= match($niveau) {
      'TOP_SECRET'   => 'bg-red-900 text-red-400',
      'SECRET'       => 'bg-orange-900 text-orange-400',
      'CONFIDENTIEL' => 'bg-yellow-900 text-yellow-400',
      'LEURRE'       => 'bg-gray-800 text-gray-500 border border-red-800',
      default        => 'bg-gray-800 text-gray-500',
    } ?>"><?= $niveau ?></span>
    <?php if ($niveau === 'LEURRE'): ?>
      <span class="text-xs text-red-500 mono animate-pulse">⚠ Données leurre — vous avez été piégé</span>
    <?php endif; ?>
  </div>

  <?php if ($user['role'] === 'ADMIN'): ?>
    <div class="p-4 bg-gray-800 rounded-lg text-gray-500 text-sm mono">
      L'admin système n'a pas accès aux localisations (hors scope — voir matrice d'accès).
    </div>
  <?php elseif (empty($locs)): ?>
    <div class="p-4 bg-gray-800 rounded-lg text-gray-600 text-sm mono">Aucune localisation accessible.</div>
  <?php else: ?>
    <div class="bg-gray-900 border border-gray-800 rounded-lg overflow-hidden">
      <table class="w-full text-sm">
        <thead class="bg-gray-800 text-gray-400 text-xs mono">
          <tr>
            <th class="px-4 py-3 text-left">Dossier</th>
            <th class="px-4 py-3 text-left">Type lieu</th>
            <th class="px-4 py-3 text-left">Ville</th>
            <th class="px-4 py-3 text-left">Pays</th>
            <th class="px-4 py-3 text-left">Adresse</th>
            <th class="px-4 py-3 text-left">Niveau</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-800">
          <?php foreach ($locs as $l): ?>
          <tr class="hover:bg-gray-800/50 <?= $l['EST_LEURRE'] ? 'opacity-70' : '' ?>">
            <td class="px-4 py-3 mono text-sm text-gray-300"><?= htmlspecialchars($l['NUM_DOSSIER']) ?></td>
            <td class="px-4 py-3 text-xs text-gray-400 mono"><?= htmlspecialchars($l['TYPE_LIEU'] ?? '—') ?></td>
            <td class="px-4 py-3 text-gray-300"><?= htmlspecialchars($l['VILLE'] ?? '—') ?></td>
            <td class="px-4 py-3 text-gray-400 text-xs"><?= htmlspecialchars($l['PAYS'] ?? '—') ?></td>
            <td class="px-4 py-3 text-gray-400 text-xs"><?= htmlspecialchars($l['ADRESSE'] ?? '—') ?></td>
            <td class="px-4 py-3">
              <span class="text-xs mono px-2 py-0.5 rounded <?= match($l['NIVEAU_ACCES'] ?? '') {
                'TOP_SECRET'   => 'bg-red-900 text-red-400',
                'SECRET'       => 'bg-orange-900 text-orange-400',
                'CONFIDENTIEL' => 'bg-yellow-900 text-yellow-400',
                'LEURRE'       => 'bg-gray-800 text-red-500 border border-red-900',
                default        => 'bg-gray-700 text-gray-400',
              } ?>"><?= htmlspecialchars($l['NIVEAU_ACCES'] ?? '—') ?></span>
            </td>
          </tr>
          <?php endforeach; ?>
        </tbody>
      </table>
    </div>
  <?php endif; ?>
</div>

<!-- Tableau comparatif (admin/directeur seulement) -->
<?php if (in_array($user['role'], ['DIRECTEUR']) && !empty($byTemoin)): ?>
<div class="mt-8">
  <h2 class="font-semibold text-gray-200 mb-4">
    🔍 Vue comparative — 4 versions par témoin (accès DIRECTEUR)
  </h2>
  <?php foreach ($byTemoin as $idT => $versions): ?>
  <div class="mb-4 bg-gray-900 border border-gray-800 rounded-lg overflow-hidden">
    <div class="px-4 py-2 bg-gray-800 border-b border-gray-700">
      <span class="text-gray-300 mono text-sm font-semibold">
        Témoin #<?= $idT ?> — <?= htmlspecialchars($versions['TOP_SECRET']['NUM_DOSSIER'] ?? '—') ?>
      </span>
    </div>
    <div class="grid grid-cols-4 divide-x divide-gray-800">
      <?php foreach (['TOP_SECRET','SECRET','CONFIDENTIEL','LEURRE'] as $niv):
        $v = $versions[$niv] ?? null;
        $label = match($niv) {
          'TOP_SECRET'   => ['bg-red-950','text-red-400','DIRECTEUR'],
          'SECRET'       => ['bg-orange-950','text-orange-400','COORDINATEUR'],
          'CONFIDENTIEL' => ['bg-yellow-950','text-yellow-600','ANALYSTE'],
          'LEURRE'       => ['bg-gray-900','text-gray-500','SUSPECT'],
        };
      ?>
        <div class="p-3 <?= $label[0] ?>">
          <div class="text-xs mono <?= $label[1] ?> font-semibold mb-1"><?= $niv ?></div>
          <div class="text-xs text-gray-600 mono mb-2">Vu par: <?= $label[2] ?></div>
          <?php if ($v): ?>
            <div class="text-xs text-gray-300"><?= htmlspecialchars($v['VILLE'] ?? '?') ?></div>
            <div class="text-xs text-gray-400"><?= htmlspecialchars($v['PAYS'] ?? '?') ?></div>
            <div class="text-xs text-gray-500 mt-1 break-all"><?= htmlspecialchars($v['ADRESSE'] ?? '—') ?></div>
            <?php if ($v['EST_LEURRE']): ?>
              <span class="text-xs text-red-500 mono mt-1 inline-block">⚠ LEURRE</span>
            <?php endif; ?>
          <?php else: ?>
            <div class="text-xs text-gray-700 mono">Non défini</div>
          <?php endif; ?>
        </div>
      <?php endforeach; ?>
    </div>
  </div>
  <?php endforeach; ?>
</div>
<?php endif; ?>

<?php require_once __DIR__ . '/footer.php'; ?>
