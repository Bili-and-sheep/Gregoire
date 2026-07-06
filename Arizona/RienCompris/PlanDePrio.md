# Plan de Priorités — SL1PCONNECT TP Virtu/Conteneurisation
> Soutenance : 7 juillet | Rendus : soutenance orale 30 min + document d'architecture

---

## Exigences minimum confirmées

| Exigence | Statut |
|---|---|
| 1 VM avec 1 service conteneurisé (thread-api choisi) | A faire en soutenance |
| Docker sécurisé (non-root, healthcheck, multi-stage) | Fait |
| Trivy — scan de vulnérabilités des images | A lancer |
| Hadolint — lint des Dockerfiles | A lancer |
| Montrer la sécurité (demo live) | Préparer slides + démo |

---

## JOUR 1 — Code (FAIT)

### Corrections effectuées

**thread-api (Flask/Python) — service principal de la maquette**
- [x] Dockerfile : multi-stage, `USER 1001`, Python 3.12, `HEALTHCHECK`, gunicorn
- [x] `app.py` : pydantic pour validation des inputs (EmailStr + field_validator)
- [x] `app.py` : JWT signé avec PyJWT (remplace le token trivial `user_id.secret`)
- [x] `app.py` : `debug=False` + gunicorn (plus de serveur de dev en prod)
- [x] `requirements.txt` : Flask 3.0, pydantic 2.x, gunicorn, PyJWT

**tailor-panel (PHP) — SQL injection corrigée**
- [x] `index.php` : requêtes préparées PDO (`$pdo->prepare()` + `execute([...])`)
- [x] `index.php` : endpoint `/health` ajouté
- [x] `index.php` : vérification `DB_PASSWORD` manquant
- [x] Dockerfile : PHP 8.3, `USER 1001`, `HEALTHCHECK`

**stitch-processor (Node.js)**
- [x] Dockerfile : Node 22 alpine, multi-stage, `USER 1001`, `HEALTHCHECK`

**fabric-watch (Grafana)**
- [x] Dockerfile : Grafana 11.1.0 (depuis 8.3.0)
- [x] `docker.sock` SUPPRIMÉ du docker-compose (escalade de privilèges critique)

**docker-compose.yml**
- [x] Secrets via fichiers (`secrets:` + `/run/secrets/`) — plus de mots de passe en clair
- [x] Port 5432 PostgreSQL non exposé publiquement
- [x] Réseaux isolés : `frontend` (exposé) et `backend` (internal:true)
- [x] `healthcheck` sur db-velvet avec `condition: service_healthy`
- [x] Volume persistant pour PostgreSQL

---

## JOUR 2 — Livrables (A FAIRE)

### Matinée
- [ ] Lancer `trivy image` sur chaque image buildée → capturer rapport
- [ ] Lancer `hadolint` sur chaque Dockerfile → capturer rapport
- [ ] Compléter le schéma `J2/infra-cible.drawio`
- [ ] Rédiger `J2/document-architecture.md`

### Après-midi
- [ ] Préparer les slides (voir structure dans J2/)
- [ ] Répéter la démo live (docker compose up → montrer healthchecks → montrer scan trivy propre)
- [ ] Préparer les réponses aux questions probable du prof

---

## Commandes à lancer pour la soutenance

```bash
# Build de la stack
cd sl1pconnect-iot-stack
docker compose up --build -d

# Scan Trivy sur thread-api (le service de la maquette)
trivy image sl1pconnect-iot-stack-thread-api

# Hadolint sur tous les Dockerfiles
hadolint thread-api/Dockerfile
hadolint tailor-panel/Dockerfile
hadolint stitch-processor/Dockerfile
hadolint fabric-watch/Dockerfile

# Vérifier que les conteneurs tournent non-root
docker compose exec thread-api whoami   # doit retourner appuser (uid 1001)
docker compose exec tailor-panel whoami # doit retourner appuser (uid 1001)

# Vérifier les healthchecks
docker compose ps  # STATUS doit être "healthy"

# Test de la SQL injection corrigée (doit retourner des résultats normaux, pas d'injection)
curl -X POST http://localhost:8080/api/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"jean.dupont@example.com","password":"password123"}'
```

---

## Questions probables du prof — réponses préparées

| Question | Réponse courte |
|---|---|
| Pourquoi tu as retiré docker.sock ? | Monter docker.sock dans un conteneur = accès complet au daemon Docker = container escape trivial |
| C'est quoi la SQL injection corrigée ? | index.php construisait la requête par concaténation directe, un attaquant pouvait injecter du SQL. Corrigé avec `$pdo->prepare()` et `execute([...])` |
| Pourquoi USER 1001 ? | Principe du moindre privilège — un processus root dans un conteneur peut exploiter des failles kernel pour sortir du conteneur |
| Pourquoi multi-stage build ? | Sépare l'environnement de compilation de l'image finale — l'image de prod ne contient pas les outils de build (surface d'attaque réduite) |
| Qu'est-ce que Trivy détecte ? | Vulnérabilités CVE dans les paquets de l'image de base et les dépendances applicatives |
| Pourquoi OpenBSD reste ? | Exigence explicite du client dans le cahier des charges |
| Pourquoi Windows XP ne migre pas ? | Contrainte explicite du cas d'étude — on l'isole en VLAN dédié sans accès réseau |
| Données de test réelles ? | Non — RGPD Art.9, données de santé. Jeu de données synthétique généré, aucune donnée patient réelle |
