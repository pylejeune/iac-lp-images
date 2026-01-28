# Image Docker - Ubuntu 24 LTS + Node.js 22 + Nginx + PM2

Image Docker optimisée avec Ubuntu 24 LTS, Node.js 22 LTS, nginx, npm et PM2.

## 📦 Contenu de l'Image

- **Ubuntu 24.04 LTS** - Distribution de base
- **Node.js 22 LTS** - Runtime JavaScript
- **npm** - Gestionnaire de paquets Node.js (inclus avec Node.js)
- **nginx** - Serveur web et reverse proxy
- **PM2** - Gestionnaire de processus pour Node.js

## 🚀 Utilisation

### Build de l'Image

```bash
docker build -t app:latest .
```

### Lancer le Conteneur

```bash
docker run -d \
  --name app-container \
  -p 80:80 \
  -p 443:443 \
  -v $(pwd)/app:/home/appuser/app \
  app:latest
```

### Avec Docker Compose

```bash
docker-compose up -d
```

## 📁 Structure du Projet

```
.
├── Dockerfile              # Configuration de l'image Docker
├── docker-compose.yml      # Configuration Docker Compose
├── .dockerignore          # Fichiers à exclure du build
├── entrypoint.sh          # Script d'entrypoint principal
├── app/                   # Répertoire de l'application
│   ├── package.json
│   ├── server.js          # Point d'entrée de l'application
│   └── ...
├── nginx/                 # Configuration Nginx
│   ├── nginx.conf         # Configuration principale
│   ├── conf.d/
│   │   └── default.conf   # Configuration du serveur virtuel
│   └── logs/              # Logs Nginx (générés à l'exécution)
└── pm2/                   # Configuration PM2
    ├── ecosystem.config.js # Configuration PM2
    ├── start.sh           # Script de démarrage PM2
    └── README.md          # Documentation PM2
```

## 🔧 Configuration

### Variables d'Environnement

- `NODE_ENV` - Environnement Node.js (production par défaut)
- `PM2_HOME` - Répertoire de configuration PM2

### Ports

- **80** - HTTP (nginx)
- **443** - HTTPS (nginx, nécessite configuration SSL)

### Volumes

- `/home/appuser/app` - Répertoire de l'application
- `/etc/nginx/conf.d` - Configuration nginx (fichiers de serveurs virtuels)
- `/etc/nginx/nginx.conf` - Configuration principale nginx
- `/var/log/nginx` - Logs nginx

**Configuration Nginx:**
- Les fichiers de configuration sont dans `nginx/`
- `nginx/nginx.conf` → `/etc/nginx/nginx.conf`
- `nginx/conf.d/*.conf` → `/etc/nginx/conf.d/`
- Voir [nginx/README.md](nginx/README.md) pour plus de détails

## 📝 Configuration PM2

L'image utilise PM2 pour gérer l'application Node.js. La configuration PM2 se trouve dans `pm2/`.

**Fichiers:**
- `pm2/ecosystem.config.js` - Configuration PM2 (montée dans `/home/appuser/app/ecosystem.config.js`)
- `pm2/start.sh` - Script de démarrage automatique

**Personnalisation:**
- Modifiez `pm2/ecosystem.config.js` pour ajuster la configuration
- Redémarrez le conteneur pour appliquer les changements

📖 **Documentation complète:** Voir [pm2/README.md](pm2/README.md) pour plus de détails.

## 🔒 Sécurité

- ✅ Utilisateur non-root (`appuser`)
- ✅ Image multi-stage pour réduire la taille
- ✅ Nettoyage des caches et fichiers temporaires
- ✅ Health check configuré

## 🐛 Dépannage

### Vérifier les Versions

```bash
docker run --rm app:latest node --version
docker run --rm app:latest npm --version
docker run --rm app:latest nginx -v
docker run --rm app:latest pm2 --version
```

### Logs

```bash
# Logs du conteneur
docker logs app-container

# Logs PM2
docker exec app-container pm2 logs

# Logs nginx
docker exec app-container tail -f /var/log/nginx/access.log
```

### Shell Interactif

```bash
docker exec -it app-container /bin/bash
```

## 📚 Bonnes Pratiques

Cette image suit les bonnes pratiques Docker :
- Multi-stage build
- Utilisateur non-root
- Health check
- Cache des layers optimisé
- Nettoyage des fichiers inutiles

Voir [../.cursor/rules/](../.cursor/rules/) pour plus de détails.

## 🔄 Mise à Jour

Pour mettre à jour les dépendances :

```bash
docker build --no-cache -t app:latest .
```

## 🛠️ Makefile

Un Makefile est fourni pour simplifier les commandes Docker courantes.

### Commandes Principales

```bash
make build          # Construire l'image
make run            # Lancer le conteneur
make stop           # Arrêter le conteneur
make logs           # Voir les logs
make shell          # Ouvrir un shell dans le conteneur
make clean          # Nettoyer le conteneur et l'image
```

### Voir Toutes les Commandes

```bash
make help
```

📖 **Documentation complète:** Voir [Makefile.md](Makefile.md) pour la documentation détaillée de toutes les commandes.

## 📄 Licence

Voir le fichier LICENSE pour plus de détails.
