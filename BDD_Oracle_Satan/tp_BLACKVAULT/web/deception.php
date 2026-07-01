<?php
$pageName = 'Data Deception';
require_once __DIR__ . '/layout.php';

$profile = getCurrentProfile();
$conn    = getDbConnection($profile);
?>

<!-- En-tête -->
<div class="mb-6 p-5 bg-gray-900 border border-red-900 rounded-lg">
  <h2 class="text-red-400 font-semibold text-lg mb-1">🎭 Opération BLACKVAULT — Mécanismes de Data Deception</h2>
  <p class="text-gray-500 text-sm">Documentation technique des 4 techniques de déception implémentées sur Oracle 26ai.</p>
</div>

<!-- Grille 4 mécanismes -->
<div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">

  <!-- 1. HoneyToken -->
  <div class="bg-gray-900 border border-red-900 rounded-lg overflow-hidden">
    <div class="bg-red-950 px-5 py-3 border-b border-red-900 flex items-center gap-2">
      <span class="text-xl">🍯</span>
      <div>
        <div class="text-red-400 font-semibold text-sm">1. HoneyToken avec FGA</div>
        <div class="text-red-700 text-xs mono">DBMS_FGA.ADD_POLICY</div>
      </div>
    </div>
    <div class="p-5 space-y-3">
      <div>
        <div class="text-xs text-gray-500 mono mb-1">Principe :</div>
        <div class="text-gray-300 text-sm">Un enregistrement fictif très attractif (<span class="mono text-red-400">AEGIS-OMEGA</span>) est inséré dans TEMOINS avec <span class="mono">IS_HONEYTOKEN=1</span>. Tout SELECT déclenche automatiquement une alerte via le handler FGA.</div>
      </div>
      <div class="bg-black rounded p-3 mono text-xs space-y-0.5">
        <div class="text-gray-600">-- Configuration Oracle</div>
        <div class="text-green-400">DBMS_FGA.ADD_POLICY(</div>
        <div class="text-blue-400 ml-4">object_name    => 'TEMOINS',</div>
        <div class="text-blue-400 ml-4">policy_name    => 'POL_HONEYTOKEN_AEGIS',</div>
        <div class="text-blue-400 ml-4">audit_condition=> 'IS_HONEYTOKEN = 1',</div>
        <div class="text-blue-400 ml-4">handler_module => 'SP_ALERTE_HONEYTOKEN'</div>
        <div class="text-green-400">);</div>
      </div>
      <div class="flex items-center gap-2 text-xs">
        <span class="w-2 h-2 bg-green-500 rounded-full"></span>
        <span class="text-gray-400">Handler autonome → INSERT dans ALERTES_SECURITE</span>
      </div>
      <div class="flex items-center gap-2 text-xs">
        <span class="w-2 h-2 bg-green-500 rounded-full"></span>
        <span class="text-gray-400">Trace : user Oracle, IP, sessionid, OS_USER</span>
      </div>
      <?php
      if ($conn && in_array($user['role'], ['DIRECTEUR','ADMIN'])) {
          $nb = queryOne($conn, "SELECT COUNT(*) AS nb FROM blackvault.alertes_securite WHERE type_alerte='HONEYTOKEN_ACCESS'");
          echo '<div class="mt-2 p-2 bg-red-950/50 rounded border border-red-900 text-xs mono text-red-400">'
               . '⚡ ' . ($nb['NB'] ?? 0) . ' alerte(s) HoneyToken enregistrée(s)</div>';
      }
      ?>
    </div>
  </div>

  <!-- 2. Polyinstanciation -->
  <div class="bg-gray-900 border border-orange-900 rounded-lg overflow-hidden">
    <div class="bg-orange-950 px-5 py-3 border-b border-orange-900 flex items-center gap-2">
      <span class="text-xl">📊</span>
      <div>
        <div class="text-orange-400 font-semibold text-sm">2. Polyinstanciation</div>
        <div class="text-orange-700 text-xs mono">SYS_CONTEXT + VPD simulé</div>
      </div>
    </div>
    <div class="p-5 space-y-3">
      <div>
        <div class="text-xs text-gray-500 mono mb-1">Principe :</div>
        <div class="text-gray-300 text-sm">La table <span class="mono text-orange-400">LOCALISATIONS_POLY</span> stocke 4 versions de la même localisation. La vue <span class="mono">VW_LOCALISATION_POLY</span> filtre selon <span class="mono">SESSION_USER</span>.</div>
      </div>
      <div class="bg-black rounded p-3 mono text-xs space-y-0.5">
        <div class="text-green-400">WHERE niveau_habilitation = (</div>
        <div class="text-blue-400 ml-4">CASE SYS_CONTEXT('USERENV','SESSION_USER')</div>
        <div class="text-yellow-400 ml-6">WHEN 'BV_DIRECTEUR'    THEN 'TOP_SECRET'</div>
        <div class="text-orange-400 ml-6">WHEN 'BV_COORDINATEUR' THEN 'SECRET'</div>
        <div class="text-cyan-400 ml-6">WHEN 'BV_ANALYSTE'     THEN 'CONFIDENTIEL'</div>
        <div class="text-red-400 ml-6">ELSE                        'LEURRE'</div>
        <div class="text-green-400">)</div>
      </div>
      <div class="grid grid-cols-2 gap-2 text-xs mono">
        <div class="p-2 bg-red-950/30 rounded border border-red-900 text-red-400">DIRECTEUR → vraie adresse</div>
        <div class="p-2 bg-orange-950/30 rounded border border-orange-900 text-orange-400">COORD → ville/région</div>
        <div class="p-2 bg-blue-950/30 rounded border border-blue-900 text-blue-400">ANALYSTE → banalisé</div>
        <div class="p-2 bg-gray-800 rounded border border-red-900 text-red-500">SUSPECT → faux hôtel ⚠</div>
      </div>
    </div>
  </div>

  <!-- 3. Leurres + Synonymes -->
  <div class="bg-gray-900 border border-yellow-900 rounded-lg overflow-hidden">
    <div class="bg-yellow-950 px-5 py-3 border-b border-yellow-900 flex items-center gap-2">
      <span class="text-xl">🎯</span>
      <div>
        <div class="text-yellow-500 font-semibold text-sm">3. Vues + Public Synonyms</div>
        <div class="text-yellow-800 text-xs mono">CREATE PUBLIC SYNONYM + Tables leurre</div>
      </div>
    </div>
    <div class="p-5 space-y-3">
      <div>
        <div class="text-xs text-gray-500 mono mb-1">Principe :</div>
        <div class="text-gray-300 text-sm">Des synonymes publics aux noms attractifs pointent vers des vues qui aiguillent selon l'utilisateur. Tout accès suspect est immédiatement loggé via FGA.</div>
      </div>
      <div class="bg-black rounded p-3 mono text-xs space-y-0.5">
        <div class="text-yellow-500">CREATE PUBLIC SYNONYM witness_list</div>
        <div class="text-yellow-500 ml-4">FOR blackvault.vw_temoins_master;</div>
        <div class="text-gray-600 mt-1">-- Aussi disponibles :</div>
        <div class="text-gray-400">admin_credentials → leurre_admin_credentials</div>
        <div class="text-gray-400">master_identities → leurre_witness_master_list</div>
        <div class="text-gray-400">backup_enc_keys   → leurre_backup_encryption_keys</div>
      </div>
      <div class="space-y-1 text-xs">
        <div class="flex items-center gap-2 text-gray-400"><span class="text-green-500">●</span> User légitime → données réelles filtrées</div>
        <div class="flex items-center gap-2 text-gray-400"><span class="text-red-500">●</span> Suspect → données leurre + ALERTE automatique</div>
      </div>
      <?php
      if ($conn && in_array($user['role'], ['DIRECTEUR','ADMIN'])) {
          $nb = queryOne($conn, "SELECT COUNT(*) AS nb FROM blackvault.alertes_securite WHERE type_alerte LIKE 'LEURRE%'");
          echo '<div class="mt-2 p-2 bg-yellow-950/50 rounded border border-yellow-900 text-xs mono text-yellow-500">'
               . '⚡ ' . ($nb['NB'] ?? 0) . ' accès leurre enregistré(s)</div>';
      }
      ?>
    </div>
  </div>

  <!-- 4. Watermarking -->
  <div class="bg-gray-900 border border-purple-900 rounded-lg overflow-hidden">
    <div class="bg-purple-950 px-5 py-3 border-b border-purple-900 flex items-center gap-2">
      <span class="text-xl">🔏</span>
      <div>
        <div class="text-purple-400 font-semibold text-sm">4. Watermarking</div>
        <div class="text-purple-800 text-xs mono">FN_GENERATE_WATERMARK + REGISTRE_WATERMARKS</div>
      </div>
    </div>
    <div class="p-5 space-y-3">
      <div>
        <div class="text-xs text-gray-500 mono mb-1">Principe :</div>
        <div class="text-gray-300 text-sm">Chaque export via <span class="mono text-purple-400">VW_EXPORT_TEMOINS</span> génère une signature unique (username + id_temoin + sel + date). En cas de fuite, la signature révèle l'utilisateur source.</div>
      </div>
      <div class="bg-black rounded p-3 mono text-xs space-y-0.5">
        <div class="text-green-400">FN_GENERATE_WATERMARK(username, id)</div>
        <div class="text-blue-400 ml-4">→ RAWTOHEX(username|id|BLACKVAULT2025|date)</div>
        <div class="text-blue-400 ml-4">→ INSERT INTO registre_watermarks</div>
        <div class="text-gray-600 mt-1">-- Injection discrète dans le champ :</div>
        <div class="text-purple-400">num_dossier || CHR(8203)  -- Zero-width space</div>
        <div class="text-gray-600">-- Invisible à l'œil, mais identifiable en analyse</div>
      </div>
      <div class="flex items-center gap-2 text-xs">
        <span class="text-purple-400 mono">SP_IDENTIFIER_FUITE(sig)</span>
        <span class="text-gray-500">→ retrouve user + date + dossier</span>
      </div>
      <?php
      if ($conn && in_array($user['role'], ['DIRECTEUR','ADMIN'])) {
          $nb = queryOne($conn, "SELECT COUNT(*) AS nb FROM blackvault.registre_watermarks");
          echo '<div class="mt-2 p-2 bg-purple-950/50 rounded border border-purple-900 text-xs mono text-purple-400">'
               . '🔏 ' . ($nb['NB'] ?? 0) . ' watermark(s) enregistrée(s)</div>';
      }
      ?>
    </div>
  </div>
</div>

<!-- Classification -->
<div class="bg-gray-900 border border-gray-800 rounded-lg p-5">
  <h3 class="font-semibold text-gray-200 mb-4">📋 Classification Bell-LaPadula / Biba des tables</h3>
  <div class="overflow-x-auto">
    <table class="w-full text-xs mono">
      <thead class="text-gray-500 border-b border-gray-700">
        <tr>
          <th class="py-2 text-left">Table</th>
          <th class="py-2 text-left">Bell-LaPadula</th>
          <th class="py-2 text-left">Biba</th>
          <th class="py-2 text-left">Justification</th>
        </tr>
      </thead>
      <tbody class="divide-y divide-gray-800">
        <?php
        $tables = [
          ['IDENTITES_REELLES',     'Top Secret',  'Haute', 'Fuite = danger vital'],
          ['LOCALISATIONS',         'Top Secret',  'Haute', 'Localisation physique critique'],
          ['CONTACTS_AUTORISES',    'Top Secret',  'Haute', 'Peut révéler identité réelle'],
          ['TRANSFERTS',            'Top Secret',  'Haute', 'Déplacements critiques'],
          ['TEMOINS',               'Secret',      'Haute', 'Données sensibles de dossier'],
          ['NOUVELLES_IDENTITES',   'Secret',      'Haute', 'Identité de couverture'],
          ['MENACES',               'Secret',      'Haute', 'Données opérationnelles'],
          ['ASSIGNATIONS',          'Secret',      'Haute', 'Lie agent à témoin'],
          ['DOCUMENTS_IDENTITE',    'Secret',      'Haute', 'Documents de couverture'],
          ['COMMUNICATIONS',        'Secret',      'Basse', 'Traces fréquentes'],
          ['AFFAIRES',              'Confidentiel','Haute', 'Données judiciaires'],
          ['TEMOINS_AFFAIRES',      'Confidentiel','Haute', 'Liaison témoin-affaire'],
          ['AGENTS_PROTECTION',     'Confidentiel','Haute', 'Personnel interne'],
          ['EVALUATIONS_RISQUE',    'Confidentiel','Haute', 'Analyse interne'],
          ['UTILISATEURS',          'Confidentiel','Haute', 'Comptes applicatifs'],
          ['PROGRAMMES_PROTECTION', 'Public',      'Haute', 'Informations générales'],
          ['LOG_CONNEXIONS',        'Public',      'Basse', 'Logs techniques'],
        ];
        $blpColors = ['Top Secret' => 'text-red-400', 'Secret' => 'text-orange-400', 'Confidentiel' => 'text-yellow-500', 'Public' => 'text-green-500'];
        foreach ($tables as [$t, $blp, $biba, $just]):
        ?>
          <tr class="hover:bg-gray-800/30">
            <td class="py-1.5 text-gray-300"><?= $t ?></td>
            <td class="py-1.5 <?= $blpColors[$blp] ?? 'text-gray-400' ?>"><?= $blp ?></td>
            <td class="py-1.5 <?= $biba === 'Haute' ? 'text-green-600' : 'text-gray-600' ?>"><?= $biba ?></td>
            <td class="py-1.5 text-gray-600"><?= $just ?></td>
          </tr>
        <?php endforeach; ?>
      </tbody>
    </table>
  </div>
</div>

<?php
if ($conn) oci_close($conn);
require_once __DIR__ . '/footer.php';
?>
