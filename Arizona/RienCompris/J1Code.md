# J1 — Explications des corrections de code
> Service principal de la maquette : **thread-api** (Flask/Python)

---

## Vue d'ensemble

La stack fournie contenait 8 vulnérabilités volontaires réparties sur 5 fichiers.
Toutes ont été corrigées. Voici le détail de chaque correction avec le avant/après.

---

## 1. SQL Injection — `tailor-panel/index.php`

**La vulnérabilité originale (ligne la plus critique du TP)**

```php
// AVANT — injection directe de $_GET['q'] dans la requête
$q = $_GET['q'] ?? '';
$sql = "SELECT id, email, role FROM users WHERE email LIKE '%$q%'";
$rows = $pdo->query($sql);
```

Un attaquant pouvait entrer `%' OR '1'='1` dans le champ de recherche et récupérer **tous les utilisateurs**. SL1PCONNECT avait déjà subi cette attaque selon la FAQ.

**La correction**

```php
// APRÈS — requête préparée, $q ne touche jamais au SQL
$q = '%' . ($_GET['q'] ?? '') . '%';
$stmt = $pdo->prepare("SELECT id, email, role FROM users WHERE email LIKE ?");
$stmt->execute([$q]);
$rows = $stmt->fetchAll();
```

`$pdo->prepare()` envoie la structure SQL au serveur séparément des données. Même si `$q` contient du SQL malveillant, il sera traité comme une simple chaîne de caractères.

La même correction a été appliquée au login (remplace la vérification admin/admin codée en dur) :
```php
// AVANT — credentials hardcodés
if ($_POST['username'] === 'admin' && $_POST['password'] === 'admin')

// APRÈS — requête préparée contre la base
$stmt = $pdo->prepare("SELECT id FROM users WHERE email = ? AND password = ?");
$stmt->execute([$u, $p]);
```

---

## 2. Validation des inputs avec Pydantic — `thread-api/app.py`

**Le problème original**

```python
# AVANT — aucune validation, n'importe quoi pouvait entrer
data = request.get_json(force=True, silent=True) or {}
cur.execute(
    "SELECT id, role FROM users WHERE email=%s AND password=%s",
    (data.get("email", ""), data.get("password", "")),
)
```

Pas de vérification du format de l'email, pas de limite sur la taille des champs.

**La correction — Pydantic**

```python
# APRÈS — validation stricte avant d'atteindre la base
class LoginRequest(BaseModel):
    email: EmailStr          # vérifie que c'est un email valide
    password: str

    @field_validator("password")
    @classmethod
    def password_not_empty(cls, v: str) -> str:
        if not v or len(v) < 1:
            raise ValueError("password requis")
        return v

@app.route("/api/login", methods=["POST"])
def login():
    try:
        data = LoginRequest.model_validate(request.get_json(...) or {})
    except Exception as e:
        return jsonify(error="données invalides", detail=str(e)), 400
    # ici, data.email est garanti être un email valide
```

`EmailStr` de Pydantic rejette automatiquement `"'; DROP TABLE users; --"` comme email invalide, avant même d'atteindre la requête SQL.

---

## 3. JWT signé — `thread-api/app.py`

**Le problème original**

```python
# AVANT — "token" trivial, juste user_id + secret en clair
return jsonify(token="%s.%s" % (row[0], JWT_SECRET), ...)
```

N'importe qui connaissant le schéma pouvait forger un token pour n'importe quel user_id.

**La correction**

```python
# APRÈS — JWT signé HS256 avec PyJWT
import jwt

token = jwt.encode(
    {"user_id": row[0], "role": row[1]},
    JWT_SECRET,
    algorithm="HS256",
)
return jsonify(token=token, user_id=row[0], role=row[1])
```

Le token est maintenant signé cryptographiquement. Sans `JWT_SECRET`, il est impossible de forger un token valide.

---

## 4. Flask debug=False + Gunicorn — `thread-api/app.py`

**Le problème original**

```python
# AVANT — debug=True expose la console interactive Werkzeug
app.run(host="0.0.0.0", port=8080, debug=True)
```

`debug=True` en production active la console Werkzeug interactive accessible depuis le navigateur — exécution de code arbitraire garantie si un attaquant y accède.

**La correction**

```python
# APRÈS — debug=False + gunicorn comme serveur WSGI de production
app.run(host="0.0.0.0", port=int(os.environ.get("PORT", "8080")), debug=False)
```

Et dans le Dockerfile, on remplace `python app.py` par gunicorn :
```dockerfile
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "app:app"]
```

---

## 5. Dockerfiles — non-root, multi-stage, healthcheck

**Le problème original (identique sur les 4 services)**

```dockerfile
# AVANT — thread-api/Dockerfile
FROM python:3.8-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 8080
CMD ["python", "app.py"]
# problèmes : root, pas de healthcheck, pas de multi-stage, Python 3.8 EOL
```

**La correction — pattern appliqué à tous les Dockerfiles**

```dockerfile
# APRÈS — thread-api/Dockerfile
# Stage 1 : build (contient pip, compilateurs, etc.)
FROM python:3.12-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2 : image finale propre (sans les outils de build)
FROM python:3.12-slim
RUN useradd -u 1001 -m appuser      # utilisateur non-root
WORKDIR /app
COPY --from=builder --chown=appuser:appuser /usr/local/lib/python3.12/site-packages ...
COPY --chown=appuser:appuser . .
USER 1001                            # bascule vers non-root
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')" || exit 1
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "app:app"]
```

**Pourquoi multi-stage ?**
L'image finale ne contient que le runtime, pas `pip`, pas les headers C, pas les compilateurs. Surface d'attaque réduite, image plus petite.

**Pourquoi USER 1001 ?**
Un processus root dans un conteneur qui exploite une faille kernel peut sortir du conteneur et compromettre l'hôte. UID 1001 = moindre privilège.

---

## 6. Suppression du docker.sock — `docker-compose.yml`

**Le problème original**

```yaml
# AVANT — fabric-watch avait accès au daemon Docker
fabric-watch:
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock  # CRITIQUE
```

Monter `docker.sock` dans un conteneur = accès complet à l'API Docker = créer un conteneur privilegié avec tout le système de fichiers hôte monté = container escape en 2 commandes.

**La correction**

```yaml
# APRÈS — volume supprimé, Grafana surveille les métriques via Prometheus
fabric-watch:
  build: ./fabric-watch
  environment:
    GF_SECURITY_ADMIN_USER: admin
    GF_AUTH_ANONYMOUS_ENABLED: "false"
  # docker.sock absent
```

---

## 7. Secrets hors du docker-compose — `docker-compose.yml`

**Le problème original**

```yaml
# AVANT — mots de passe en clair dans le fichier de config
environment:
  DB_PASSWORD: velvet
  JWT_SECRET: sl1p-super-secret-key-2024
  GF_SECURITY_ADMIN_PASSWORD: admin
```

N'importe qui avec accès au dépôt Git pouvait lire tous les secrets.

**La correction — Docker secrets**

```yaml
# APRÈS — secrets injectés via fichiers au runtime
secrets:
  db_password:
    file: ./secrets/db_password.txt
  jwt_secret:
    file: ./secrets/jwt_secret.txt

services:
  thread-api:
    secrets:
      - db_password
      - jwt_secret
    environment:
      DB_PASSWORD_FILE: /run/secrets/db_password
      JWT_SECRET_FILE: /run/secrets/jwt_secret
```

Les secrets sont montés dans `/run/secrets/` avec des permissions 0400 — seul le processus applicatif peut les lire, et ils n'apparaissent jamais dans `docker inspect`.

---

## 8. Port PostgreSQL non exposé

**Avant**
```yaml
db-velvet:
  ports:
    - "5432:5432"  # PostgreSQL accessible depuis l'extérieur de la machine
```

**Après**
```yaml
db-velvet:
  # pas de ports: — PostgreSQL accessible uniquement depuis le réseau interne Docker
  networks:
    - backend
```

Combiné avec `networks.backend.internal: true`, le réseau backend est totalement coupé de l'extérieur.

---

## Résumé des versions mises à jour

| Service | Avant | Après | Raison |
|---|---|---|---|
| thread-api | Python 3.8-slim | Python 3.12-slim | 3.8 EOL depuis oct 2024 |
| tailor-panel | PHP 7.4-apache | PHP 8.3-apache | 7.4 EOL depuis nov 2022 |
| stitch-processor | Node 14-alpine | Node 22-alpine | 14 EOL depuis avril 2023 |
| fabric-watch | Grafana 8.3.0 | Grafana 11.1.0 | 8.3 a 40+ CVE connues |
| db-velvet | postgres:12 | postgres:16-alpine | 12 EOL depuis nov 2024 |

---

## Commandes de vérification

```bash
# Confirmer que les conteneurs tournent non-root
docker compose exec thread-api whoami      # appuser
docker compose exec tailor-panel whoami   # appuser
docker compose exec stitch-processor whoami # appuser

# Vérifier les healthchecks (STATUS = healthy)
docker compose ps

# Vérifier que les secrets ne sont pas dans l'environnement
docker compose exec thread-api env | grep -i "pass\|secret\|token"
# Résultat attendu : DB_PASSWORD_FILE et JWT_SECRET_FILE (chemins seulement, pas les valeurs)

# Scan Trivy — doit retourner 0 CRITICAL, 0 HIGH
trivy image sl1pconnect-iot-stack-thread-api:latest
```
