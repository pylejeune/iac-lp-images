# Strapi Ready - Container Alpine

Container Docker basé sur Alpine pour Strapi qui reste up sans exécuter automatiquement les commandes npm.

## Principe

Ce container :
- **Reste actif** grâce à `tail -f /dev/null`
- **N'exécute PAS** automatiquement `npm install`, `npm run build` ou `npm start`
- Permet de lancer manuellement les commandes via `entrypoint.sh` ou directement dans le container

## Structure

```
strapi-ready/
├── Dockerfile           # Image Alpine avec Node.js 22
├── entrypoint.sh        # Script helper optionnel
├── docker-compose.yml   # Configuration complète avec PostgreSQL
├── .dockerignore        # Fichiers exclus du build
├── README.md            # Cette documentation
└── app/                 # Répertoire pour le code Strapi (monté en volume)
```

## Utilisation

### 1. Démarrer les containers

```bash
# Build et démarrage
docker compose up -d --build

# Vérifier que le container est up
docker compose ps
```

### 2. Lancer les commandes Strapi

#### Option A : Via entrypoint.sh

```bash
# Voir l'aide
docker exec -it strapi-ready /usr/local/bin/entrypoint.sh help

# Installer les dépendances
docker exec -it strapi-ready /usr/local/bin/entrypoint.sh install

# Mode développement complet (install + develop)
docker exec -it strapi-ready /usr/local/bin/entrypoint.sh dev

# Mode production complet (install + build + start)
docker exec -it strapi-ready /usr/local/bin/entrypoint.sh full
```

#### Option B : Manuellement

```bash
# Entrer dans le container
docker exec -it strapi-ready bash

# Puis exécuter les commandes souhaitées
npm install
npm run develop
# ou
npm run build
npm run start
```

### 3. Commandes disponibles dans entrypoint.sh

| Commande  | Description                                    |
|-----------|------------------------------------------------|
| `install` | Exécute `npm install`                          |
| `build`   | Exécute `npm run build`                        |
| `develop` | Exécute `npm run develop` (mode dev)           |
| `start`   | Exécute `npm run start` (mode prod)            |
| `dev`     | `install` + `develop`                          |
| `full`    | `install` + `build` + `start`                  |
| `shell`   | Lance un shell bash interactif                 |
| `help`    | Affiche l'aide                                 |

## Configuration

### Variables d'environnement

Les variables sont définies dans `docker-compose.yml`. Modifier selon vos besoins :

```yaml
environment:
  - NODE_ENV=development
  - DATABASE_HOST=postgres
  - DATABASE_NAME=strapi
  # ... etc
```

### Volumes

- `./app:/opt/app` : Code source Strapi
- `strapi_node_modules:/opt/app/node_modules` : Persistance des dépendances

## Workflow typique

1. Placer votre code Strapi dans `./app/`
2. Démarrer : `docker compose up -d`
3. Installer : `docker exec -it strapi-ready /usr/local/bin/entrypoint.sh install`
4. Développer : `docker exec -it strapi-ready /usr/local/bin/entrypoint.sh develop`

## Arrêt

```bash
# Arrêter les containers
docker compose down

# Arrêter et supprimer les volumes
docker compose down -v
```
