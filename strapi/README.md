# Strapi CMS avec PostgreSQL/Aurora

Strapi CMS configuré pour fonctionner avec une base de données PostgreSQL/Aurora et accessible depuis l'extérieur.

## 📋 Prérequis

- Docker et Docker Compose installés
- Une base de données Aurora PostgreSQL accessible
- Les identifiants de connexion à la base de données

## 🚀 Démarrage rapide

### Option 1 : Développement local (recommandé pour tester)

Pour tester Strapi en local avec une base de données PostgreSQL intégrée :

```bash
# Créer le fichier .env.local (automatique avec make)
make local-init

# Lancer Strapi avec PostgreSQL en local
make local-up

# Voir les logs
make local-logs

# Arrêter
make local-down
```

**Accès à Strapi :**
- **Admin Panel** : http://localhost:1337/admin
- **API** : http://localhost:1337/api

Le fichier `.env.local` sera créé automatiquement depuis `.env.local.example`. Vous pouvez le modifier pour personnaliser les secrets.

**Génération des secrets pour le développement local :**
```bash
# Générer JWT_SECRET
openssl rand -base64 32

# Générer ADMIN_JWT_SECRET
openssl rand -base64 32

# Générer APP_KEYS (4 clés séparées par des virgules)
openssl rand -base64 32,openssl rand -base64 32,openssl rand -base64 32,openssl rand -base64 32
```

### Option 2 : Production avec Aurora PostgreSQL

### 1. Configuration

Copiez le fichier `.env.example` vers `.env` et configurez vos variables d'environnement :

```bash
cp .env.example .env
```

Éditez `.env` et configurez :
- Les informations de connexion à Aurora PostgreSQL
- Les secrets Strapi (JWT_SECRET, ADMIN_JWT_SECRET, APP_KEYS)

**Génération des secrets :**
```bash
# Générer JWT_SECRET
openssl rand -base64 32

# Générer ADMIN_JWT_SECRET
openssl rand -base64 32

# Générer APP_KEYS (4 clés séparées par des virgules)
openssl rand -base64 32,openssl rand -base64 32,openssl rand -base64 32,openssl rand -base64 32
```

### 2. Construction et démarrage

```bash
# Construire l'image
docker-compose build

# Démarrer le conteneur
docker-compose up -d

# Voir les logs
docker-compose logs -f
```

### 3. Accès à Strapi

Une fois démarré, Strapi sera accessible sur :
- **Admin Panel** : http://localhost:1337/admin
- **API** : http://localhost:1337/api

Lors du premier démarrage, vous devrez créer un compte administrateur.

## 🔧 Configuration Aurora PostgreSQL

### SSL

Pour Aurora PostgreSQL, SSL est généralement requis. La configuration par défaut utilise :
- `DATABASE_SSL=true`
- `DATABASE_SSL_REJECT_UNAUTHORIZED=false` (pour les certificats auto-signés AWS)

Si vous utilisez des certificats AWS RDS, vous pouvez définir :
```env
DATABASE_SSL_REJECT_UNAUTHORIZED=true
```

### Pool de connexions

La configuration par défaut utilise un pool de connexions :
- Minimum : 2 connexions
- Maximum : 10 connexions

Vous pouvez ajuster ces valeurs via les variables d'environnement :
```env
DATABASE_POOL_MIN=2
DATABASE_POOL_MAX=10
```

## 📁 Structure du projet

```
strapi/
├── config/              # Configuration Strapi
│   ├── database.js     # Configuration PostgreSQL/Aurora
│   ├── server.js       # Configuration serveur (HOST=0.0.0.0)
│   ├── middlewares.js  # Middlewares
│   └── api.js          # Configuration API
├── src/                # Code source
│   ├── admin/          # Personnalisation admin panel
│   ├── api/            # APIs personnalisées
│   └── index.js        # Bootstrap
├── public/             # Fichiers publics (uploads)
├── Dockerfile              # Image Docker production
├── Dockerfile.dev          # Image Docker développement local (Alpine)
├── docker-compose.yml      # Configuration Docker Compose (production)
├── docker-compose.local.yml # Configuration Docker Compose (développement local)
├── .env.example            # Exemple de variables d'environnement (production)
├── .env.local.example      # Exemple de variables d'environnement (local)
└── package.json            # Dépendances Node.js
```

## 🐳 Commandes Docker

### Développement local

```bash
# Lancer Strapi avec PostgreSQL en local
make local-up

# Arrêter
make local-down

# Voir les logs
make local-logs

# Ouvrir un shell dans le conteneur
make local-shell
```

### Production (Aurora PostgreSQL)

```bash
# Construire l'image
docker-compose build

# Démarrer en arrière-plan
docker-compose up -d

# Arrêter
docker-compose down

# Voir les logs
docker-compose logs -f strapi

# Redémarrer
docker-compose restart

# Accéder au shell du conteneur
docker-compose exec strapi sh
```

## 🔒 Sécurité

- ✅ Utilisateur non-root dans le conteneur
- ✅ Variables d'environnement pour les secrets
- ✅ SSL pour la connexion à Aurora
- ✅ Health check configuré

## 🐛 Dépannage

### Problème de proxy d'entreprise lors du build Docker

Si vous rencontrez des erreurs liées au proxy (ex: `emea-private-zscaler.proxy.lvmh`), vous pouvez :

**Option 1 : Désactiver temporairement le proxy Docker**
```bash
# Vérifier les variables de proxy Docker
echo $HTTP_PROXY
echo $HTTPS_PROXY

# Désactiver temporairement pour le build
unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy
make local-up

# Ou désactiver uniquement pour Docker
docker build --network=host -f Dockerfile.dev .
```

**Option 2 : Configurer le proxy Docker correctement**
```bash
# Créer/modifier ~/.docker/config.json
mkdir -p ~/.docker
cat > ~/.docker/config.json << EOF
{
  "proxies": {
    "default": {
      "httpProxy": "",
      "httpsProxy": "",
      "noProxy": "localhost,127.0.0.1"
    }
  }
}
EOF
```

**Option 3 : Utiliser --network=host**
Le Dockerfile.dev utilise déjà Alpine Linux qui devrait mieux gérer le proxy. Si le problème persiste, vous pouvez modifier le docker-compose.local.yml pour ajouter `network_mode: host` au service strapi.

### Erreur de connexion à la base de données

Vérifiez :
1. Les variables d'environnement dans `.env.local` (pour le développement local)
2. Que le cluster Aurora est accessible depuis votre réseau (pour la production)
3. Les règles de sécurité (Security Groups) pour autoriser le trafic depuis le conteneur
4. Les paramètres SSL si nécessaire

### Strapi ne démarre pas

```bash
# Vérifier les logs
make local-logs
# ou
docker-compose -f docker-compose.local.yml logs strapi

# Vérifier le statut
docker-compose -f docker-compose.local.yml ps

# Reconstruire l'image
docker-compose -f docker-compose.local.yml build --no-cache
```

### Première installation

Lors du premier démarrage, Strapi va :
1. Se connecter à la base de données
2. Créer les tables nécessaires
3. Vous demander de créer un compte administrateur

## 📚 Documentation

- [Documentation Strapi](https://docs.strapi.io)
- [Strapi Docker](https://docs.strapi.io/dev-docs/installation/docker)
- [Aurora PostgreSQL](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Overview.html)
