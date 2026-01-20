# Configuration PM2

Ce répertoire contient les fichiers de configuration et de démarrage pour PM2 (Process Manager 2).

## 📁 Structure

```
pm2/
├── ecosystem.config.js    # Configuration PM2 (ecosystem file)
├── start.sh               # Script de démarrage PM2
└── README.md              # Cette documentation
```

## 📝 Fichiers de Configuration

### `ecosystem.config.js`
Fichier de configuration PM2 qui sera monté dans `/home/appuser/app/ecosystem.config.js`.

**Caractéristiques:**
- Nom de l'application: `app`
- Script: `./server.js` (modifiable)
- Mode: `cluster` (ou `fork`)
- Instances: 1 (ou `max` pour utiliser tous les CPU)
- Redémarrage automatique
- Gestion des logs
- Limite mémoire: 500M

**Options principales:**
- `instances`: Nombre d'instances (1, nombre, ou 'max')
- `exec_mode`: 'fork' ou 'cluster'
- `watch`: Surveillance des fichiers (true/false)
- `max_memory_restart`: Redémarrer si la mémoire dépasse cette limite
- `env`: Variables d'environnement

### `start.sh`
Script de démarrage PM2 qui sera copié dans `/usr/local/bin/pm2-start.sh`.

**Fonctionnalités:**
- Détecte automatiquement la configuration PM2
- Fallback vers `package.json` si ecosystem.config.js n'existe pas
- Gestion des erreurs
- Messages informatifs

**Ordre de priorité:**
1. `ecosystem.config.js` (dans `/home/appuser/app/`)
2. `package.json` avec script `start`
3. `server.js`, `index.js` ou `app.js` par défaut

## 🔧 Personnalisation

### Modifier la Configuration PM2

1. **Éditer `pm2/ecosystem.config.js`**
2. **Redémarrer le conteneur** pour appliquer les changements:
   ```bash
   make restart
   # ou
   docker-compose restart
   ```

### Exemples de Configuration

#### Mode Cluster (Multi-instances)
```javascript
{
  name: 'app',
  script: './server.js',
  instances: 'max', // Utilise tous les CPU
  exec_mode: 'cluster'
}
```

#### Mode Fork (Single instance)
```javascript
{
  name: 'app',
  script: './server.js',
  instances: 1,
  exec_mode: 'fork'
}
```

#### Avec Watch (Développement)
```javascript
{
  name: 'app',
  script: './server.js',
  watch: true,
  ignore_watch: ['node_modules', 'logs']
}
```

#### Variables d'Environnement
```javascript
{
  name: 'app',
  script: './server.js',
  env: {
    NODE_ENV: 'production',
    PORT: 3000,
    DATABASE_URL: 'postgresql://...'
  },
  env_production: {
    NODE_ENV: 'production',
    PORT: 3000
  },
  env_development: {
    NODE_ENV: 'development',
    PORT: 3000
  }
}
```

## 🚀 Utilisation

### Commandes PM2 dans le Conteneur

Une fois le conteneur démarré, vous pouvez utiliser PM2:

```bash
# Ouvrir un shell dans le conteneur
make shell
# ou
docker exec -it app-container /bin/bash

# Commandes PM2 disponibles:
pm2 list              # Lister les processus
pm2 logs              # Voir les logs
pm2 logs app          # Logs de l'application spécifique
pm2 monit             # Monitoring en temps réel
pm2 restart app       # Redémarrer l'application
pm2 stop app          # Arrêter l'application
pm2 reload app        # Recharger sans downtime
pm2 delete app        # Supprimer l'application
pm2 info app          # Informations sur l'application
pm2 describe app      # Description détaillée
```

### Logs PM2

Les logs sont configurés dans `ecosystem.config.js`:
- `error_file`: `./logs/pm2-error.log`
- `out_file`: `./logs/pm2-out.log`

**Voir les logs:**
```bash
# Via Docker
docker exec app-container pm2 logs

# Ou directement dans le conteneur
docker exec app-container tail -f /home/appuser/app/logs/pm2-out.log
```

## 📊 Monitoring

### PM2 Monitoring

PM2 fournit un monitoring intégré:

```bash
# Monitoring en temps réel
docker exec -it app-container pm2 monit

# Statistiques
docker exec app-container pm2 describe app
```

### Métriques Disponibles

- CPU usage
- Memory usage
- Restart count
- Uptime
- Logs

## 🔄 Redémarrage et Reload

### Redémarrage Complet
```bash
# Redémarre l'application (downtime)
docker exec app-container pm2 restart app
```

### Reload (Zero Downtime)
```bash
# Recharge l'application sans downtime (cluster mode)
docker exec app-container pm2 reload app
```

**Note:** Le reload fonctionne uniquement en mode `cluster`.

## 🐛 Dépannage

### Application ne démarre pas

1. **Vérifier les logs:**
   ```bash
   docker exec app-container pm2 logs
   ```

2. **Vérifier la configuration:**
   ```bash
   docker exec app-container pm2 describe app
   ```

3. **Vérifier que le fichier existe:**
   ```bash
   docker exec app-container ls -la /home/appuser/app/
   ```

### Application redémarre en boucle

1. **Vérifier les limites mémoire:**
   ```bash
   docker exec app-container pm2 describe app
   ```

2. **Augmenter la limite dans ecosystem.config.js:**
   ```javascript
   max_memory_restart: '1G' // Au lieu de '500M'
   ```

### Changer le Port

Modifiez `ecosystem.config.js`:
```javascript
env: {
  PORT: 8080 // Nouveau port
}
```

Et mettez à jour la configuration nginx pour proxy vers le nouveau port.

## 📚 Ressources

- [Documentation PM2](https://pm2.keymetrics.io/docs/usage/quick-start/)
- [PM2 Ecosystem File](https://pm2.keymetrics.io/docs/usage/application-declaration/)
- [PM2 Cluster Mode](https://pm2.keymetrics.io/docs/usage/cluster-mode/)
