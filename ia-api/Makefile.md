# 📚 Documentation du Makefile

Ce Makefile fournit des commandes pratiques pour gérer l'image Docker et les conteneurs de manière simplifiée.

## 🚀 Commandes Disponibles

### Aide
```bash
make help
```
Affiche la liste de toutes les commandes disponibles avec leur description.

### Build

#### `make build`
Construit l'image Docker avec le nom et le tag par défaut (`app:latest`).

```bash
make build
# Équivalent à: docker build -t app:latest .
```

**Variables utilisées:**
- `IMAGE_NAME = app`
- `IMAGE_TAG = latest`

#### `make build-no-cache`
Construit l'image Docker sans utiliser le cache. Utile pour forcer une reconstruction complète.

```bash
make build-no-cache
# Équivalent à: docker build --no-cache -t app:latest .
```

**Quand l'utiliser:**
- Après avoir modifié des dépendances système
- Pour s'assurer que toutes les couches sont reconstruites
- En cas de problèmes de cache

### Exécution

#### `make run`
Lance un conteneur Docker en mode détaché avec les ports et volumes configurés.

```bash
make run
# Équivalent à:
# docker run -d \
#   --name app-container \
#   -p 80:80 \
#   -p 443:443 \
#   -v $(pwd)/app:/home/appuser/app \
#   app:latest
```

**Configuration:**
- Ports exposés: 80 (HTTP), 443 (HTTPS)
- Volume monté: `./app` → `/home/appuser/app`
- Nom du conteneur: `app-container`

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

### Arrêt

#### `make stop`
Arrête le conteneur Docker nommé `app-container`.

```bash
make stop
# Équivalent à: docker stop app-container
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
# docker rm -f app-container
# docker rmi app:latest
```

**Attention:** Cette commande est destructive. Elle supprime:
- Le conteneur `app-container` (forcé)
- L'image `app:latest`

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

### Logs

#### `make logs`
Affiche les logs du conteneur en temps réel (mode suivi).

```bash
make logs
# Équivalent à: docker logs -f app-container
```

**Utilisation:**
- Appuyez sur `Ctrl+C` pour quitter
- Affiche tous les logs depuis le démarrage du conteneur

#### `make logs-compose`
Affiche les logs de tous les services docker-compose.

```bash
make logs-compose
# Équivalent à: docker-compose logs -f
```

**Options:**
- Pour un service spécifique: `docker-compose logs -f <service-name>`

### Debugging

#### `make shell`
Ouvre un shell interactif dans le conteneur en cours d'exécution.

```bash
make shell
# Équivalent à: docker exec -it app-container /bin/bash
```

**Utilisation:**
- Permet d'exécuter des commandes à l'intérieur du conteneur
- Utile pour le debugging et l'inspection
- Quittez avec `exit` ou `Ctrl+D`

#### `make test`
Vérifie que toutes les versions installées sont correctes.

```bash
make test
# Affiche:
# - Version de Node.js
# - Version de npm
# - Version de nginx
# - Version de PM2
```

**Utilité:**
- Vérification rapide après le build
- Validation des dépendances
- Debugging des problèmes de version

#### `make health`
Vérifie le statut de santé du conteneur.

```bash
make health
# Équivalent à: docker inspect --format='{{.State.Health.Status}}' app-container
```

**Résultats possibles:**
- `healthy` - Le conteneur est en bonne santé
- `unhealthy` - Le health check échoue
- `starting` - Le conteneur démarre encore
- `none` - Aucun health check configuré

#### `make stats`
Affiche les statistiques d'utilisation des ressources en temps réel.

```bash
make stats
# Équivalent à: docker stats app-container
```

**Informations affichées:**
- Utilisation CPU (%)
- Utilisation mémoire (actuelle / limite)
- I/O réseau
- I/O disque

**Note:** Appuyez sur `Ctrl+C` pour quitter.

### Redémarrage

#### `make restart`
Redémarre le conteneur (arrêt + démarrage).

```bash
make restart
# Équivalent à:
# docker stop app-container
# docker run -d --name app-container ...
```

**Utilisation:**
- Après modification de la configuration
- Pour appliquer de nouveaux paramètres
- En cas de problème

## 🔧 Personnalisation

### Modifier les Variables

Éditez les variables en haut du Makefile:

```makefile
IMAGE_NAME = app          # Nom de l'image
IMAGE_TAG = latest        # Tag de l'image
CONTAINER_NAME = app-container  # Nom du conteneur
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
# 1. Construire l'image
make build

# 2. Tester les versions
make test

# 3. Lancer le conteneur
make run

# 4. Vérifier les logs
make logs

# 5. Vérifier la santé
make health

# 6. Voir les statistiques
make stats

# 7. Arrêter
make stop

# 8. Nettoyer
make clean
```

### Développement avec Docker Compose

```bash
# 1. Construire et lancer
make run-compose

# 2. Voir les logs
make logs-compose

# 3. Arrêter
make stop-compose

# 4. Nettoyer complètement
make clean-all
```

### Debugging

```bash
# 1. Lancer le conteneur
make run

# 2. Ouvrir un shell
make shell

# 3. Dans le shell, inspecter:
#    - node --version
#    - npm --version
#    - pm2 list
#    - nginx -t

# 4. Vérifier les logs
make logs

# 5. Vérifier la santé
make health
```

## ⚠️ Précautions

### Commandes Destructives

Les commandes suivantes suppriment des données:
- `make clean` - Supprime le conteneur et l'image
- `make clean-all` - Nettoyage complet du système Docker

**Recommandation:** Vérifiez toujours avant d'exécuter ces commandes.

### Ports en Conflit

Si les ports 80 ou 443 sont déjà utilisés:
- Modifiez les ports dans `docker-compose.yml`
- Ou utilisez: `docker run -p 8080:80 ...`

### Volumes

Le Makefile monte `./app` comme volume. Assurez-vous que:
- Le répertoire `app/` existe
- Il contient votre application
- Les permissions sont correctes

## 🔗 Commandes Docker Équivalentes

Pour référence, voici les équivalents directs:

| Makefile | Docker Command |
|----------|---------------|
| `make build` | `docker build -t app:latest .` |
| `make run` | `docker run -d --name app-container -p 80:80 -p 443:443 -v $(pwd)/app:/home/appuser/app app:latest` |
| `make stop` | `docker stop app-container` |
| `make logs` | `docker logs -f app-container` |
| `make shell` | `docker exec -it app-container /bin/bash` |
| `make clean` | `docker rm -f app-container && docker rmi app:latest` |

## 📚 Ressources

- [Documentation Docker](https://docs.docker.com/)
- [Documentation Docker Compose](https://docs.docker.com/compose/)
- [Documentation Make](https://www.gnu.org/software/make/manual/)
