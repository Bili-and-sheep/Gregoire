# Document d'Architecture — SL1PCONNECT Infrastructure Cible
> Module Virtualisation & Conteneurisation | Soutenance 7 juillet

---

## 1. Résumé exécutif

SL1PCONNECT opère une plateforme IoT de santé connectée. L'infrastructure existante présente
des vulnérabilités critiques (SQL injection exploitée, conteneurs root, secrets en clair, 
docker.sock exposé) incompatibles avec les exigences HDS et RGPD Art.9.

Ce document présente l'architecture cible sécurisée, les corrections apportées, et le plan
de migration vers cette cible dans un budget de 100 k€.

---

## 2. Audit de l'existant — Vulnérabilités identifiées

### 2.1 Vulnérabilités critiques

| ID | Composant | Vulnérabilité | Sévérité | Preuve |
|---|---|---|---|---|
| V-01 | tailor-panel (PHP) | **SQL Injection** — concaténation directe `$_GET['q']` dans `LIKE '%$q%'` | CRITICAL | Déjà exploitée selon FAQ |
| V-02 | fabric-watch | **docker.sock monté** — escalade de privilèges, container escape | CRITICAL | `docker-compose.yml` ligne `volumes:` |
| V-03 | Tous services | **Conteneurs root** — aucun `USER` défini dans les Dockerfiles | HIGH | `docker inspect` → UID 0 |
| V-04 | thread-api | **Flask debug=True en prod** — console Werkzeug interactive exposée | HIGH | `app.py` ligne finale |
| V-05 | thread-api | **JWT non signé** — token trivial `user_id.secret` forgeable | HIGH | `app.py` fonction `login()` |
| V-06 | docker-compose | **Secrets en clair** — DB_PASSWORD, JWT_SECRET, admin/admin | HIGH | `docker-compose.yml` env section |
| V-07 | db-velvet | **Port 5432 exposé** — PostgreSQL accessible depuis l'extérieur | HIGH | `docker-compose.yml` ports section |
| V-08 | Tous services | **Images obsolètes** — Python 3.8, PHP 7.4, Node 14, Grafana 8.3, postgres 12 (tous EOL) | MEDIUM | Dockerfiles |
| V-09 | Tous services | **Aucun healthcheck** — redémarrage automatique impossible | MEDIUM | Dockerfiles |
| V-10 | db-velvet | **Mots de passe en clair en BDD** — `password TEXT` sans hachage | HIGH | `init.sql` |

### 2.2 Matrice STRIDE

| Composant | Spoofing | Tampering | Repudiation | Info Disclosure | DoS | Elevation |
|---|---|---|---|---|---|---|
| thread-api (Flask) | V-05 (JWT forgeable) | | | V-04 (debug) | | V-03 (root) |
| tailor-panel (PHP) | | V-01 (SQLi) | | V-01 (dump DB) | | V-03 (root) |
| fabric-watch | | | | | | V-02 (docker.sock) |
| db-velvet | | | | V-10 (mdp clair) | V-07 (port exposé) | |

---

## 3. Architecture cible

### 3.1 Principe d'isolation réseau

```
INTERNET
    │
    ├── [Reverse Proxy / Firewall]
    │
    ├── réseau "frontend" (bridge Docker)
    │       ├── thread-api     :8080
    │       ├── tailor-panel   :8081
    │       └── fabric-watch   :9090
    │
    └── réseau "backend" (internal:true — coupé de l'extérieur)
            ├── stitch-processor :8082
            └── db-velvet        :5432 (non exposé)
```

`internal: true` sur le réseau backend signifie qu'aucun conteneur de ce réseau
ne peut initier de connexion vers l'extérieur, et l'extérieur ne peut pas y accéder.

### 3.2 Choix technologiques

| Composant | Choix | Justification |
|---|---|---|
| Orchestration maquette | **Docker Compose v2** | Simple, suffisant pour la maquette 1 VM |
| Orchestration prod cible | **k3s** | Kubernetes léger, HA natif, adapté scale |
| Gestion des secrets | **Docker secrets** (maquette) → **HashiCorp Vault** (prod) | Standard industrie, audit logs |
| Scan vulnérabilités | **Trivy** | Open-source, intégrable CI/CD |
| Lint Dockerfiles | **Hadolint** | Analyse statique, règles CIS |
| Validation inputs | **Pydantic** (Python) + **PDO prepare** (PHP) | Prévient SQLi et injections |
| Hyperviseur | **Proxmox VE 8** | Open-source, HA, ZFS, budget ok |

### 3.3 Service principal de la maquette — thread-api

Choisi car :
- Contient le plus de vulnérabilités à démontrer (JWT, debug, root, inputs)
- Représentatif des enjeux HDS (accès aux données de santé via `/api/sensors`)
- Démonstration Pydantic + JWT visuelle en live

---

## 4. Corrections apportées (résumé)

### 4.1 SQL Injection — tailor-panel

**Avant :** `$sql = "SELECT ... WHERE email LIKE '%$q%'";`

**Après :** `$stmt = $pdo->prepare("SELECT ... WHERE email LIKE ?"); $stmt->execute([$q]);`

### 4.2 Sécurisation des Dockerfiles (pattern appliqué ×4)

```dockerfile
# Multi-stage : l'image finale ne contient pas les outils de build
FROM python:3.12-slim AS builder
RUN pip install --no-cache-dir -r requirements.txt

FROM python:3.12-slim
RUN useradd -u 1001 -m appuser   # non-root obligatoire
COPY --from=builder --chown=appuser ...
USER 1001
HEALTHCHECK --interval=30s CMD ...   # redémarrage automatique si crash
CMD ["gunicorn", ...]                # serveur WSGI de prod (remplace flask debug)
```

### 4.3 Suppression docker.sock

Le montage `/var/run/docker.sock` permettait à tout conteneur compromis de créer un
nouveau conteneur avec l'option `--privileged` et de monter `/` de l'hôte.

```bash
# Preuve de l'exploit original (ne pas reproduire en prod)
docker run -v /var/run/docker.sock:/var/run/docker.sock ... \
  docker run --privileged -v /:/host alpine chroot /host
```

Supprimé du `docker-compose.yml`. Grafana reçoit ses métriques via Prometheus.

### 4.4 Secrets Docker

```yaml
# Plus de secrets en clair — injectés au runtime via /run/secrets/
secrets:
  db_password:
    file: ./secrets/db_password.txt

services:
  thread-api:
    secrets: [db_password]
    environment:
      DB_PASSWORD_FILE: /run/secrets/db_password
```

---

## 5. Politique de sauvegarde (3-2-1)

| Copie | Emplacement | Fréquence |
|---|---|---|
| 1 — Locale | Volume Proxmox / NVMe | Toutes les 4h |
| 2 — Site distant | Marseille TissuCloud | Quotidienne |
| 3 — Cloud chiffré | OVH Object Storage AES-256 | Quotidienne |

RTO cible : 2h | RPO cible : 1h (données de santé)

---

## 6. Conformité RGPD / HDS

| Exigence | Mesure |
|---|---|
| Chiffrement en transit | TLS 1.3 obligatoire (reverse proxy) |
| Chiffrement au repos | LUKS sur volumes BDD (prod) |
| Séparation des environnements | Réseau backend `internal:true`, namespaces k3s |
| Aucune donnée réelle en recette | Données synthétiques uniquement (génération LLM) |
| Audit logs accès données de santé | Loki (logs centralisés, rétention 1 an) |
| Notification CNIL 72h | Procédure documentée dans la PSSI |

---

## 7. Plan de migration

| Étape | Action | Coupure |
|---|---|---|
| 1 | Déploiement Proxmox + configuration réseau | Aucune |
| 2 | Build des nouvelles images (hardened) + scan Trivy | Aucune |
| 3 | Réduction TTL DNS à 60s | Aucune |
| 4 | Bascule blue/green : ancienne stack → nouvelle stack | < 5 min |
| 5 | Révocation accès ex-stagiaire + rotation secrets | Immédiat |
| 6 | Activation monitoring Grafana + alertes | Aucune |

---

## 8. Budget estimatif (100 k€)

| Poste | Coût |
|---|---|
| Proxmox VE (open-source) | 0 € |
| k3s (open-source) | 0 € |
| Harbor registre (open-source) | 0 € |
| HashiCorp Vault Community | 0 € |
| OVH HDS (contrat maintenu) | ~10 k€/an |
| Hardware serveurs Nice (si upgrade) | ~35 k€ |
| Formation équipe (MFA, DevSecOps) | ~3 k€ |
| **Total estimatif** | **~48 k€** |
| Marge imprévus | **52 k€** |
