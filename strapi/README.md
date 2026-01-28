# Strapi CMS avec PostgreSQL/Aurora

Strapi CMS configuré pour fonctionner avec une base de données PostgreSQL/Aurora et accessible depuis l'extérieur.

## 📋 Prérequis

- Docker et Docker Compose installés
- Une base de données Aurora PostgreSQL accessible
- Les identifiants de connexion à la base de données

## 🚀 Démarrage rapide

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
├── Dockerfile          # Image Docker production
├── docker-compose.yml  # Configuration Docker Compose
├── .env.example        # Exemple de variables d'environnement
└── package.json        # Dépendances Node.js
```

## 🐳 Commandes Docker

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

### Erreur de connexion à la base de données

Vérifiez :
1. Les variables d'environnement dans `.env`
2. Que le cluster Aurora est accessible depuis votre réseau
3. Les règles de sécurité (Security Groups) pour autoriser le trafic depuis le conteneur
4. Les paramètres SSL si nécessaire

### Strapi ne démarre pas

```bash
# Vérifier les logs
docker-compose logs strapi

# Vérifier le statut
docker-compose ps

# Reconstruire l'image
docker-compose build --no-cache
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
