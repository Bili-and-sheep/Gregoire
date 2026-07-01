# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

**BLACKVAULT** is a PHP web application built as a school project (B3 DB Security) demonstrating Oracle database security concepts. It simulates a classified witness protection system ("Bureau National de Protection des Témoins") and showcases four data deception techniques:

1. **HoneyToken + FGA** — a decoy record (`AEGIS-OMEGA`) triggers an Oracle `DBMS_FGA` policy that calls `SP_ALERTE_HONEYTOKEN` on any SELECT.
2. **Polyinstantiation** — `LOCALISATIONS_POLY` stores 4 versions of each location; `VW_LOCALISATION_POLY` filters via `SYS_CONTEXT('USERENV','SESSION_USER')`.
3. **Decoy tables + Public Synonyms** — attractively-named public synonyms (`witness_list`, `admin_credentials`, `backup_enc_keys`) route legitimate users to real filtered data and suspects to decoy data + automatic FGA alert.
4. **Watermarking** — `VW_EXPORT_TEMOINS` calls `FN_GENERATE_WATERMARK(username, id_temoin)` on each read, storing a hex signature in `REGISTRE_WATERMARKS`; `SP_IDENTIFIER_FUITE(sig)` identifies the source user from a leaked signature.

Security model: Bell-LaPadula (No Read Up) + Biba (No Write Up), enforced via Oracle views and VPD simulation.

## Running the app

No build step. Serve the `web/` directory with a PHP-capable web server that has the `php-oci8` extension installed:

```bash
# Apache/Nginx: point document root at web/
# Or quick local server:
php -S localhost:8080 -t web/
```

Oracle DB must be running at `localhost:1521` SID `FREEPDB1` (configured in `config.php`). Initialize with the SQL scripts in order:

```bash
# Run as DBA in Oracle:
@sql/01_create_schema.sql
@sql/02_insert_data.sql
@sql/03_plsql.sql
@sql/04_deception.sql
@sql/05_demo.sql   # optional: demo/test queries
```

## Architecture

### Page pattern

Every page except `index.php` follows this exact structure:

```php
<?php
$pageName = 'Page Title';   // sets <title> and topbar heading
require_once __DIR__ . '/layout.php';  // auth guard + sidebar + open <main>

// page logic: DB queries, role checks
// role-gate pattern for restricted pages:
if (!in_array($user['role'], ['DIRECTEUR','ADMIN'])) { ... exit; }

// HTML output
?>
...
<?php require_once __DIR__ . '/footer.php'; ?>  // closes </main></body></html>
```

### Key files

| File | Purpose |
|---|---|
| `config.php` | Oracle connection (`getDbConnection`), user/role definitions, `queryAll`/`queryOne` helpers, color helpers |
| `layout.php` | Session auth guard, exposes `$user` and `$profile`, renders sidebar + topbar, opens `<main>` |
| `footer.php` | Closes `</main></body></html>` |
| `index.php` | Login: selects a profile (no real password), sets `$_SESSION['profile']` |
| `dashboard.php` | Stats cards, recent alerts, active mechanisms, Bell-LaPadula visualization |
| `temoins.php` | Witness list — queries differ by role: real table for DIRECTEUR/COORD/ADMIN, `VW_TEMOINS_ANALYSTE` for ANALYSTE, `witness_list` synonym for SUSPECT |
| `localisations.php` | Polyinstantiated locations |
| `alerts.php` | Security alerts + `LOG_ACCES_SENSIBLES` table (DIRECTEUR/ADMIN only) |
| `watermarks.php` | `REGISTRE_WATERMARKS` registry + leak simulation (DIRECTEUR/ADMIN only) |
| `deception.php` | Technical documentation of the 4 deception mechanisms with live alert counts |

### Roles and habilitation levels

| Profile key | Oracle user | Role | Habilitation |
|---|---|---|---|
| `directeur` | `bv_directeur` | DIRECTEUR | TOP_SECRET |
| `coordinateur` | `bv_coordinateur` | COORDINATEUR | SECRET |
| `analyste` | `bv_analyste` | ANALYSTE | CONFIDENTIEL |
| `admin` | `bv_admin` | ADMIN | CONFIDENTIEL |
| `suspect` | `bv_suspect` | SUSPECT | AUCUNE |

Each profile connects to Oracle with its own dedicated user — access control is enforced at the DB layer via views and FGA policies, not just in PHP.

### Frontend

- Tailwind CSS loaded from CDN (`https://cdn.tailwindcss.com`) — no build step
- Fonts: `Share Tech Mono` (`.mono` class) + `Inter` from Google Fonts
- Dark theme (`bg-gray-950` body), role colors defined in `roleColor()` and `habColor()` in `config.php`
