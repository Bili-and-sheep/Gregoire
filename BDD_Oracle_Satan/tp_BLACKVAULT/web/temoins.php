<?php
$pageName = 'Témoins';
require_once __DIR__ . '/layout.php';

$profile = getCurrentProfile();
$conn    = getDbConnection($profile);
$temoins = [];
$mode    = 'reel';

if ($conn) {
    if ($user['role'] === 'ANALYSTE') {
        // L'analyste voit la vue masquée (via VW_TEMOINS_ANALYSTE)
        $temoins = queryAll($conn,
            "SELECT num_dossier, TO_CHAR(date_entree,'DD/MM/YYYY') AS date_entree,
                    niveau_risque, statut, id_programme
             FROM blackvault.vw_temoins_analyste ORDER BY statut, niveau_risque");
        $mode = 'masque';
    } elseif ($user['role'] === 'SUSPECT') {
        // Le suspect voit WITNESS_LIST (synonyme public → vue aiguillée → données floues ou leurre)
        $temoins = queryAll($conn,
            "SELECT num_dossier, niveau_risque, statut, id_programme
             FROM witness_list ORDER BY statut");
        $mode = 'leurre';
    } else {
        // Coordinateur/Directeur/Admin voient les vrais témoins
        $temoins = queryAll($conn,
            "SELECT t.num_dossier, TO_CHAR(t.date_entree,'DD/MM/YYYY') AS date_entree,
                    t.niveau_risque, t.statut, p.nom AS programme,
                    fn_calcul_score_risque(t.id_temoin) AS score_risque
             FROM blackvault.temoins t
             JOIN blackvault.programmes_protection p ON p.id_programme = t.id_programme
             WHERE t.is_honeytoken = 0
             ORDER BY score_risque DESC, t.num_dossier");
        $mode = 'reel';
    }
    oci_close($conn);
}
?>

<!-- Bannière mode d'accès -->
<div class="mb-6 p-4 rounded-lg border flex items-start gap-3 <?= match($mode) {
    'reel'   => 'bg-green-950/30 border-green-800',
    'masque' => 'bg-blue-950/30 border-blue-800',
    'leurre' => 'bg-red-950/30 border-red-800 animate-pulse',
} ?>">
  <span class="text-xl mt-0.5"><?= match($mode) { 'reel' => '✓', 'masque' => '⚠', 'leurre' => '🎭' } ?></span>
  <div>
    <div class="font-semibold text-sm <?= match($mode) { 'reel' => 'text-green-400', 'masque' => 'text-blue-400', 'leurre' => 'text-red-400' } ?>">
      <?= match($mode) {
        'reel'   => 'Vue complète — Données réelles (niveau ' . $user['hab'] . ')',
        'masque' => 'Vue restreinte — Numéros de dossier partiellement masqués (Bell-LaPadula: No Read Up)',
        'leurre' => 'ATTENTION : Vue de déception active — Données leurre ou masquées pour ce profil',
      } ?>
    </div>
    <div class="text-xs text-gray-500 mono mt-1">
      Source Oracle : <?= match($mode) {
        'reel'   => 'TABLE BLACKVAULT.TEMOINS (accès direct)',
        'masque' => 'VIEW BLACKVAULT.VW_TEMOINS_ANALYSTE (masquage numéros)',
        'leurre' => 'PUBLIC SYNONYM WITNESS_LIST → VW_TEMOINS_MASTER (données altérées)',
      } ?>
    </div>
  </div>
</div>

<!-- Stats rapides -->
<div class="grid grid-cols-4 gap-3 mb-6">
  <?php
  $stats_statut = ['ACTIF' => 0, 'RELOCALISE' => 0, 'SORTI' => 0, 'DECEDE' => 0];
  foreach ($temoins as $t) {
    $s = $t['STATUT'] ?? '';
    if (isset($stats_statut[$s])) $stats_statut[$s]++;
  }
  $colors = ['ACTIF' => 'green', 'RELOCALISE' => 'orange', 'SORTI' => 'blue', 'DECEDE' => 'gray'];
  foreach ($stats_statut as $s => $nb): ?>
    <div class="bg-gray-900 border border-gray-800 rounded-lg px-4 py-3 text-center">
      <div class="text-2xl font-bold mono text-<?= $colors[$s] ?>-400"><?= $nb ?></div>
      <div class="text-xs text-gray-600 mono"><?= $s ?></div>
    </div>
  <?php endforeach; ?>
</div>

<!-- Table des témoins -->
<div class="bg-gray-900 border border-gray-800 rounded-lg overflow-hidden">
  <div class="px-5 py-4 border-b border-gray-800 flex items-center justify-between">
    <h2 class="font-semibold text-gray-200">
      Liste des témoins
      <span class="text-xs text-gray-500 ml-2 mono">(<?= count($temoins) ?> entrées)</span>
    </h2>
    <?php if ($mode === 'reel'): ?>
      <span class="text-xs text-gray-500 mono">Score = FN_CALCUL_SCORE_RISQUE()</span>
    <?php endif; ?>
  </div>

  <div class="overflow-x-auto">
    <table class="w-full text-sm">
      <thead class="bg-gray-800 text-gray-400 text-xs mono">
        <tr>
          <th class="px-4 py-3 text-left">N° Dossier</th>
          <?php if ($mode !== 'leurre'): ?>
          <th class="px-4 py-3 text-left">Date entrée</th>
          <?php endif; ?>
          <th class="px-4 py-3 text-left">Niveau risque</th>
          <th class="px-4 py-3 text-left">Statut</th>
          <?php if ($mode === 'reel'): ?>
          <th class="px-4 py-3 text-left">Programme</th>
          <th class="px-4 py-3 text-left">Score</th>
          <?php endif; ?>
        </tr>
      </thead>
      <tbody class="divide-y divide-gray-800">
        <?php if (empty($temoins)): ?>
          <tr><td colspan="6" class="px-4 py-8 text-center text-gray-600 mono">Aucun témoin accessible</td></tr>
        <?php else: ?>
          <?php foreach ($temoins as $t):
            $risque  = $t['NIVEAU_RISQUE'] ?? 'INCONNU';
            $statut  = $t['STATUT'] ?? '—';
            $score   = isset($t['SCORE_RISQUE']) ? (int)$t['SCORE_RISQUE'] : null;
            $scoreColor = match(true) {
              $score === null   => '',
              $score >= 80      => 'text-red-400',
              $score >= 60      => 'text-orange-400',
              $score >= 40      => 'text-yellow-400',
              default           => 'text-green-400',
            };
          ?>
          <tr class="hover:bg-gray-800/50 transition-colors">
            <td class="px-4 py-3 mono text-gray-300 font-medium">
              <?= htmlspecialchars($t['NUM_DOSSIER'] ?? '—') ?>
              <?php if ($mode === 'masque'): ?>
                <span class="text-xs text-blue-600 ml-1">[masqué]</span>
              <?php elseif ($mode === 'leurre'): ?>
                <span class="text-xs text-red-600 ml-1">[leurre]</span>
              <?php endif; ?>
            </td>
            <?php if ($mode !== 'leurre'): ?>
            <td class="px-4 py-3 text-gray-400 mono text-xs"><?= htmlspecialchars($t['DATE_ENTREE'] ?? '—') ?></td>
            <?php endif; ?>
            <td class="px-4 py-3">
              <span class="text-xs px-2 py-0.5 rounded mono <?= risqueColor($risque) ?>">
                <?= htmlspecialchars($risque) ?>
              </span>
            </td>
            <td class="px-4 py-3">
              <span class="text-xs px-2 py-0.5 rounded mono <?= match($statut) {
                'ACTIF'      => 'bg-green-900 text-green-400',
                'RELOCALISE' => 'bg-orange-900 text-orange-400',
                'SORTI'      => 'bg-blue-900 text-blue-400',
                'DECEDE'     => 'bg-gray-800 text-gray-500',
                default      => 'bg-gray-800 text-gray-500',
              } ?>">
                <?= htmlspecialchars($statut) ?>
              </span>
            </td>
            <?php if ($mode === 'reel'): ?>
            <td class="px-4 py-3 text-gray-400 text-xs"><?= htmlspecialchars($t['PROGRAMME'] ?? '—') ?></td>
            <td class="px-4 py-3 mono font-bold <?= $scoreColor ?>">
              <?= $score !== null ? $score . '/100' : '—' ?>
              <?php if ($score !== null): ?>
                <div class="w-16 h-1 bg-gray-700 rounded mt-1">
                  <div class="h-1 rounded <?= $score >= 80 ? 'bg-red-500' : ($score >= 60 ? 'bg-orange-500' : ($score >= 40 ? 'bg-yellow-500' : 'bg-green-500')) ?>"
                       style="width:<?= $score ?>%"></div>
                </div>
              <?php endif; ?>
            </td>
            <?php endif; ?>
          </tr>
          <?php endforeach; ?>
        <?php endif; ?>
      </tbody>
    </table>
  </div>
</div>

<?php require_once __DIR__ . '/footer.php'; ?>
