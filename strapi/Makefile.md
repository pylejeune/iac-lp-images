# 📚 Documentation du Makefile Strapi

Ce Makefile fournit des commandes pratiques pour gérer l'image Docker Strapi et les conteneurs de manière simplifiée.

## 🚀 Commandes Disponibles

### Aide
```bash
make help
```
Affiche la liste de toutes les commandes disponibles avec leur description.

### Build

#### `make build`
Construit l'image Docker Strapi avec le nom et le tag par défaut (`strapi:latest`).

```bash
make build
# Équivalent à: docker build --platform linux/amd64 -t strapi:latest .
```

**Variables utilisées:**
- `IMAGE_NAME = strapi`
- `IMAGE_TAG = latest`

**Note:** Le build utilise `--platform linux/amd64` pour assurer la compatibilité.

#### `make build-no-cache`
Construit l'image Docker sans utiliser le cache. Utile pour forcer une reconstruction complète.

```bash
make build-no-cache
# Équivalent à: docker build --platform linux/amd64 --no-cache -t strapi:latest .
```

**Quand l'utiliser:**
- Après avoir modifié des dépendances système
- Pour s'assurer que toutes les couches sont reconstruites
- En cas de problèmes de cache
- Après avoir mis à jour les dépendances npm

### Exécution

#### `make run`
Lance un conteneur Docker en mode détaché avec les ports et volumes configurés.

```bash
make run
# Équivalent à:
# docker run -d \
#   --name strapi-container \
#   --env-file .env \
#   -p 1337:1337 \
#   -v $(pwd)/public/uploads:/opt/app/public/uploads \
#   strapi:latest
```

**Configuration:**
- Port exposé: 1337 (port par défaut de Strapi)
- Volume monté: `./public/uploads` → `/opt/app/public/uploads` (pour persister les fichiers uploadés)
- Variables d'environnement: chargées depuis `.env`
- Nom du conteneur: `strapi-container`

**⚠️ Important:** Assurez-vous que le fichier `.env` existe avant d'exécuter cette commande.

#### `make run-compose`
Lance tous les services définis dans `docker-compose.yml`.

```bash
make run-compose
# Équivalent à: docker-compose up -d
```

**Avantages:**
- Gère plusieurs services simultanément
- Configuration centralisée dans `docker-compose.yml`
- Réseaux et volumes automatiques
- Health checks configurés

**Recommandation:** Utilisez cette commande plutôt que `make run` pour un environnement complet.

### Arrêt

#### `make stop`
Arrête le conteneur Docker nommé `strapi-container`.

```bash
make stop
# Équivalent à: docker stop strapi-container
```

**Note:** La commande utilise `|| true` pour ne pas échouer si le conteneur n'existe pas.

#### `make stop-compose`
Arrête tous les services définis dans `docker-compose.yml`.

```bash
make stop-compose
# Équivalent à: docker-compose down
```

**Effets:**
- Arrête tous les conteneurs
- Supprime les conteneurs (mais pas les volumes)

### Nettoyage

#### `make clean`
Supprime le conteneur et l'image Docker.

```bash
make clean
# Équivalent à:
# docker rm -f strapi-container
# docker rmi strapi:latest
```

**Attention:** Cette commande est destructive. Elle supprime:
- Le conteneur `strapi-container` (forcé)
- L'image `strapi:latest`

#### `make clean-all`
Nettoyage complet du système Docker.

```bash
make clean-all
# Équivalent à:
# docker-compose down -v
# docker system prune -f
```

**Effets:**
- Arrête et supprime tous les services docker-compose
- Supprime les volumes associés (`-v`)
- Nettoie le système Docker (images, conteneurs, réseaux non utilisés)

**⚠️ ATTENTION:** Cette commande supprime:
- Tous les conteneurs arrêtés
- Toutes les images non utilisées
- Tous les réseaux non utilisés
- Tous les volumes non utilisés
- **Les uploads dans le volume `public/uploads` seront préservés** (montage bind)

### Logs

#### `make logs`
Affiche les logs du conteneur en temps réel (mode suivi).

```bash
make logs
# Équivalent à: docker logs -f strapi-container
```

**Utilisation:**
- Appuyez sur `Ctrl+C` pour quitter
- Affiche tous les logs depuis le démarrage du conteneur
- Utile pour déboguer les problèmes de connexion à la base de données

#### `make logs-compose`
Affiche les logs de tous les services docker-compose.

```bash
make logs-compose
# Équivalent à: docker-compose logs -f
```

**Options:**
- Pour un service spécifique: `docker-compose logs -f strapi`

### Debugging

#### `make shell`
Ouvre un shell interactif dans le conteneur en cours d'exécution.

```bash
make shell
# Équivalent à: docker exec -it strapi-container /bin/sh
```

**Utilisation:**
- Permet d'exécuter des commandes à l'intérieur du conteneur
- Utile pour le debugging et l'inspection
- Quittez avec `exit` ou `Ctrl+D`
- **Note:** Utilise `/bin/sh` car l'image Alpine n'a pas bash

**Commandes utiles dans le shell:**
```bash
# Vérifier les variables d'environnement
env | grep DATABASE

# Vérifier la connexion à la base de données
node -e "console.log(process.env.DATABASE_HOST)"

# Voir les fichiers de l'application
ls -la /opt/app
```

#### `make test`
Vérifie que toutes les versions installées sont correctes.

```bash
make test
# Affiche:
# - Version de Node.js
# - Version de npm
```

**Utilité:**
- Vérification rapide après le build
- Validation des dépendances
- Debugging des problèmes de version

#### `make health`
Vérifie le statut de santé du conteneur.

```bash
make health
# Équivalent à: docker inspect --format='{{.State.Health.Status}}' strapi-container
```

**Résultats possibles:**
- `healthy` - Le conteneur est en bonne santé
- `unhealthy` - Le health check échoue
- `starting` - Le conteneur démarre encore
- `none` - Aucun health check configuré (si utilisé avec `make run`)

**Note:** Le health check est configuré dans `docker-compose.yml`. Si vous utilisez `make run`, le health check ne sera pas disponible.

#### `make stats`
Affiche les statistiques d'utilisation des ressources en temps réel.

```bash
make stats
# Équivalent à: docker stats strapi-container
```

**Informations affichées:**
- Utilisation CPU (%)
- Utilisation mémoire (actuelle / limite)
- I/O réseau
- I/O disque

**Note:** Appuyez sur `Ctrl+C` pour quitter.

### Redémarrage

#### `make restart`
Redémarre le conteneur (arrêt + démarrage avec docker-compose).

```bash
make restart
# Équivalent à:
# docker-compose down
# docker-compose up -d
```

**Utilisation:**
- Après modification de la configuration
- Pour appliquer de nouveaux paramètres
- En cas de problème
- Après modification du fichier `.env`

## 🔧 Personnalisation

### Modifier les Variables

Éditez les variables en haut du Makefile:

```makefile
IMAGE_NAME = strapi          # Nom de l'image
IMAGE_TAG = latest           # Tag de l'image
CONTAINER_NAME = strapi-container  # Nom du conteneur
```

### Ajouter de Nouvelles Commandes

Ajoutez une nouvelle cible dans le Makefile:

```makefile
ma-commande: ## Description de ma commande
	docker <votre-commande>
```

**Format:**
- `##` après le nom de la cible = description pour `make help`
- Utilisez `@` devant les commandes pour masquer l'affichage

## 📋 Exemples d'Utilisation

### Workflow Complet

```bash
# 1. Créer le fichier .env depuis .env.example
cp .env.example .env
# Éditer .env avec vos configurations

# 2. Construire l'image
make build

# 3. Tester les versions
make test

# 4. Lancer le conteneur avec docker-compose (recommandé)
make run-compose

# 5. Vérifier les logs
make logs-compose

# 6. Vérifier la santé
make health

# 7. Voir les statistiques
make stats

# 8. Accéder à Strapi
# Ouvrir http://localhost:1337/admin dans votre navigateur

# 9. Arrêter
make stop-compose

# 10. Nettoyer
make clean
```

### Développement avec Docker Compose

```bash
# 1. Construire et lancer
make run-compose

# 2. Voir les logs
make logs-compose

# 3. Ouvrir un shell pour déboguer
make shell

# 4. Arrêter
make stop-compose

# 5. Nettoyer complètement (attention: supprime les volumes)
make clean-all
```

### Debugging

```bash
# 1. Lancer le conteneur
make run-compose

# 2. Vérifier les logs pour les erreurs de connexion DB
make logs-compose

# 3. Ouvrir un shell
make shell

# 4. Dans le shell, inspecter:
#    - node --version
#    - npm --version
#    - env | grep DATABASE
#    - ls -la /opt/app

# 5. Vérifier la santé
make health

# 6. Voir les statistiques
make stats
```

### Première Installation

```bash
# 1. Copier et configurer .env
cp .env.example .env
# Éditer .env avec vos informations Aurora PostgreSQL

# 2. Générer les secrets Strapi
openssl rand -base64 32  # Pour JWT_SECRET
openssl rand -base64 32  # Pour ADMIN_JWT_SECRET
openssl rand -base64 32,openssl rand -base64 32,openssl rand -base64 32,openssl rand -base64 32  # Pour APP_KEYS

# 3. Construire l'image
make build

# 4. Lancer
make run-compose

# 5. Vérifier les logs
make logs-compose

# 6. Accéder à http://localhost:1337/admin
# Créer votre compte administrateur
```

## ⚠️ Précautions

### Commandes Destructives

Les commandes suivantes suppriment des données:
- `make clean` - Supprime le conteneur et l'image
- `make clean-all` - Nettoyage complet du système Docker (supprime les volumes)

**Recommandation:** Vérifiez toujours avant d'exécuter ces commandes.

### Fichier .env Requis

Les commandes `make run` et `make run-compose` nécessitent un fichier `.env` configuré avec:
- Les informations de connexion à Aurora PostgreSQL
- Les secrets Strapi (JWT_SECRET, ADMIN_JWT_SECRET, APP_KEYS)

**Solution:** Copiez `.env.example` vers `.env` et configurez-le.

### Port en Conflit

Si le port 1337 est déjà utilisé:
- Modifiez le port dans `docker-compose.yml` ou `.env`
- Ou utilisez: `docker run -p 1338:1337 ...`

### Volumes

Le Makefile monte `./public/uploads` comme volume. Assurez-vous que:
- Le répertoire `public/uploads/` existe (créé automatiquement)
- Les permissions sont correctes
- Les fichiers uploadés seront persistés localement

### Connexion à Aurora PostgreSQL

Pour que Strapi puisse se connecter à Aurora PostgreSQL:
1. Vérifiez que le cluster Aurora est accessible depuis votre réseau
2. Configurez les Security Groups AWS pour autoriser le trafic depuis votre IP/conteneur
3. Utilisez `DATABASE_SSL=true` dans `.env` pour Aurora
4. Vérifiez les logs avec `make logs-compose` en cas d'erreur de connexion

## 🔗 Commandes Docker Équivalentes

Pour référence, voici les équivalents directs:

| Makefile | Docker Command |
|----------|---------------|
| `make build` | `docker build --platform linux/amd64 -t strapi:latest .` |
| `make run` | `docker run -d --name strapi-container --env-file .env -p 1337:1337 -v $(pwd)/public/uploads:/opt/app/public/uploads strapi:latest` |
| `make run-compose` | `docker-compose up -d` |
| `make stop` | `docker stop strapi-container` |
| `make stop-compose` | `docker-compose down` |
| `make logs` | `docker logs -f strapi-container` |
| `make logs-compose` | `docker-compose logs -f` |
| `make shell` | `docker exec -it strapi-container /bin/sh` |
| `make clean` | `docker rm -f strapi-container && docker rmi strapi:latest` |

## 📚 Ressources

- [Documentation Strapi](https://docs.strapi.io)
- [Strapi Docker](https://docs.strapi.io/dev-docs/installation/docker)
- [Documentation Docker](https://docs.docker.com/)
- [Documentation Docker Compose](https://docs.docker.com/compose/)
- [Documentation Make](https://www.gnu.org/software/make/manual/)
- [Aurora PostgreSQL](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Overview.html)
