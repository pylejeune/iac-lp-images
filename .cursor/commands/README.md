# Commandes Cursor pour Docker

Ce répertoire contient les commandes Docker personnalisées pour Cursor.

## 📋 Commandes Disponibles

### Build et Images
- **Docker: Build Image** - Construire une image avec nom et tag
- **Docker: Build with BuildKit** - Build avec BuildKit activé
- **Docker: Build Multi-Platform** - Build pour plusieurs architectures
- **Docker: Build with No Cache** - Build sans utiliser le cache

### Conteneurs
- **Docker: Run Container** - Lancer un conteneur en mode détaché
- **Docker: Run with Environment** - Lancer avec variables d'environnement
- **Docker: Stop All Containers** - Arrêter tous les conteneurs
- **Docker: Remove All Containers** - Supprimer tous les conteneurs

### Inspection et Debugging
- **Docker: View Logs** - Afficher les logs en temps réel
- **Docker: Execute Command** - Exécuter une commande dans un conteneur
- **Docker: Inspect Image** - Inspecter les détails d'une image
- **Docker: Health Check** - Vérifier le statut de santé
- **Docker: Stats** - Statistiques d'utilisation des ressources

### Gestion des Images
- **Docker: Image Size** - Afficher la taille d'une image
- **Docker: Scan Image** - Scanner pour vulnérabilités
- **Docker: Tag Image** - Créer un nouveau tag
- **Docker: Push Image** - Pousser vers un registry
- **Docker: Pull Image** - Télécharger depuis un registry
- **Docker: Export Image** - Exporter vers un fichier
- **Docker: Load Image** - Charger depuis un fichier

### Docker Compose
- **Docker Compose: Up** - Démarrer tous les services
- **Docker Compose: Down** - Arrêter tous les services
- **Docker Compose: Build** - Construire toutes les images
- **Docker Compose: Logs** - Afficher les logs d'un service
- **Docker Compose: Restart Service** - Redémarrer un service

### Nettoyage
- **Docker: Clean System** - Nettoyer complètement le système
- **Docker: Remove Dangling Images** - Supprimer les images non utilisées
- **Docker: Remove Unused Images** - Supprimer toutes les images non utilisées
- **Docker: Remove Unused Volumes** - Supprimer les volumes non utilisés

### Listing
- **Docker: List Running Containers** - Lister les conteneurs actifs
- **Docker: List All Containers** - Lister tous les conteneurs
- **Docker: List Images** - Lister toutes les images
- **Docker: Network List** - Lister les réseaux
- **Docker: Volume List** - Lister les volumes

## 🔧 Utilisation

1. Ouvrir la palette de commandes dans Cursor (`Cmd+Shift+P` / `Ctrl+Shift+P`)
2. Taper "Docker:" pour voir toutes les commandes Docker
3. Sélectionner la commande souhaitée
4. Remplir les variables d'entrée si nécessaire

## 📝 Variables d'Entrée

Les commandes utilisent des variables d'entrée pour plus de flexibilité :
- `${input:imageName}` - Nom de l'image
- `${input:imageTag}` - Tag de l'image
- `${input:containerName}` - Nom du conteneur
- `${input:hostPort}` - Port hôte
- `${input:containerPort}` - Port conteneur
- `${input:envVar}` - Variable d'environnement
- `${input:command}` - Commande à exécuter
- `${input:serviceName}` - Nom du service (docker-compose)

## 🎯 Personnalisation

Pour ajouter vos propres commandes, éditez `docker-commands.json` et ajoutez une nouvelle entrée dans le tableau `commands`.

## ⚠️ Précautions

- Les commandes de nettoyage (`Clean System`, `Remove All`) sont destructives
- Vérifiez toujours avant d'exécuter des commandes qui suppriment des données
- Utilisez les commandes de listing pour vérifier l'état avant de nettoyer
