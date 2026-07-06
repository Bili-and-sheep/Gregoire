# TP Docker Swarm — 2 VMs

## Pre-requis

- 2 VMs Linux (Ubuntu recommande)
- Acces root / sudo
- Connexion reseau entre les 2 VMs

---

## Etape 1 — Preparer les 2 VMs

Sur **les deux VMs**, executer :

```bash
# Mise a jour du systeme
sudo apt update && sudo apt upgrade -y

# Installer Docker
curl -fsSL https://get.docker.com | sudo sh

# Ajouter l'utilisateur courant au groupe docker
sudo usermod -aG docker $USER
newgrp docker

# Verifier l'installation
docker --version
docker compose version
```

---

## Etape 2 — Initialiser le cluster Swarm

Sur la **VM1 (manager)** :

```bash
# Recuperer l'IP de la VM1
ip a  # noter l'IP, ex: 192.168.1.10

# Initialiser le swarm
docker swarm init --advertise-addr 192.168.58.141
```

Copier la commande `docker swarm join --token ...` affichee dans la sortie.

Si le port `2377` est bloque, l'ouvrir sur **les deux VMs** :

```bash
sudo ufw allow 2377/tcp
sudo ufw allow 7946/tcp
sudo ufw allow 7946/udp
sudo ufw allow 4789/udp
sudo ufw reload
```

Sur la **VM2 (worker)** :

```bash
# Coller la commande copiee depuis VM1
docker swarm join --token SWMTKN-1-xxxxx 192.168.58.141:2377
```

Verifier le cluster depuis **VM1** :

```bash
docker node ls
# Doit afficher les 2 noeuds : 1 Leader + 1 Worker
```

---

## Etape 3 — Creer l'image Docker

Sur **VM1**, creer un dossier de travail :

```bash
mkdir peche && cd peche
```

Creer le script Python `app.py` :

```python
#!/usr/bin/env python3
while True:
    print("je suis une peche", flush=True)
```

Creer le `Dockerfile` :

```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY app.py .
CMD ["python3", "app.py"]
```

Builder l'image :

```bash
docker build -t peche-app:latest .
```

---

## Etape 4 — Pousser l'image dans un registry

### Option A — Docker Hub (le plus simple)

```bash
# Se connecter
docker login

# Tagger l'image avec ton username Docker Hub
docker tag peche-app:latest <TON_USERNAME>/peche-app:latest

# Pousser
docker push <TON_USERNAME>/peche-app:latest
```

### Option B — Registry local (si pas de compte Docker Hub)

Sur **VM1**, lancer un registry local :

```bash
docker run -d -p 5000:5000 --name registry registry:2

# Tagger et pousser vers le registry local
docker tag peche-app:latest localhost:5000/peche-app:latest
docker push localhost:5000/peche-app:latest
```

Sur **VM2**, autoriser le registry insecure :

```bash
sudo tee /etc/docker/daemon.json << 'EOF'
{
  "insecure-registries": ["192.168.58.141:5000"]
}
EOF
sudo systemctl restart docker
```

---

## Etape 5 — Deployer le service avec 2 replicas

Sur **VM1 (manager)** :

### Avec Docker Hub :

```bash
docker service create \
  --name peche-service \
  --replicas 2 \
  <TON_USERNAME>/peche-app:latest
```

### Avec registry local :

```bash
docker service create \
  --name peche-service \
  --replicas 2 \
  192.168.58.141:5000/peche-app:latest
```

---

## Etape 6 — Verification

```bash
# Lister les services
docker service ls

# Voir la repartition des replicas sur les noeuds
docker service ps peche-service

# Consulter les logs
docker service logs -f peche-service
```

Sortie attendue :

```
peche-service.1.xxx | je suis une peche
peche-service.2.xxx | je suis une peche
```

---

## Points cles

- Le port `2377` (Swarm) doit etre ouvert entre les VMs
- Le `flush=True` dans le print est important pour que les logs apparaissent en temps reel dans Docker
- Les commandes `docker service` se lancent uniquement depuis le **manager (VM1)**
