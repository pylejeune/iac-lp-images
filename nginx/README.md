# Configuration Nginx

Ce répertoire contient les fichiers de configuration Nginx qui seront montés dans `/etc/nginx/` du conteneur Docker.

## 📁 Structure

```
nginx/
├── nginx.conf          # Configuration principale Nginx
├── conf.d/
│   └── default.conf    # Configuration du serveur virtuel par défaut
├── modules-enabled/    # Modules nginx activés
│   ├── 50-mod-http-image-filter.conf
│   └── 50-mod-http-xslt-filter.conf
├── sites-available/    # Configurations de sites disponibles
│   └── ia-api.conf     # Configuration pour ia-api.livemixr.com
└── logs/               # Répertoire pour les logs (créé automatiquement)
```

## 📝 Fichiers de Configuration

### `nginx.conf`
Configuration principale de Nginx qui sera montée dans `/etc/nginx/nginx.conf`.

**Modules activés:**
- `mod-http-image-filter` - Filtrage et transformation d'images
- `mod-http-xslt-filter` - Transformation XSLT
- `mod-mail` - Support des protocoles mail (POP3, IMAP)
- `mod-stream` - Proxy TCP/UDP

### `modules-enabled/`
Répertoire contenant les fichiers de configuration pour activer les modules nginx dynamiques.

**Modules disponibles:**
- `50-mod-http-image-filter.conf` - Module de filtrage d'images
- `50-mod-http-xslt-filter.conf` - Module de transformation XSLT

### `sites-available/ia-api.conf`
Configuration du serveur virtuel pour `ia-api.livemixr.com`.

**Caractéristiques:**
- Upstream vers `localhost:3000` et `localhost:3001` (load balancing)
- Proxy vers l'application Node.js
- Headers de proxy configurés
- Écoute sur le port 80

### `conf.d/default.conf`
Configuration du serveur virtuel par défaut qui sera montée dans `/etc/nginx/conf.d/default.conf`.

**Caractéristiques:**
- Écoute sur le port 80
- Proxy vers l'application Node.js (port 3000)
- Health check endpoint (`/health`)
- Headers de sécurité
- Compression Gzip
- Support des fichiers statiques

## 🔧 Personnalisation

### Modules Nginx

Les modules suivants sont installés et activés :

- **mod-http-image-filter** : Filtrage et transformation d'images (redimensionnement, rotation, etc.)
- **mod-http-xslt-filter** : Transformation XSLT des réponses XML
- **mod-mail** : Support des protocoles mail (POP3, IMAP) - configuré dans `nginx.conf`
- **mod-stream** : Proxy TCP/UDP pour les connexions non-HTTP - configuré dans `nginx.conf`

**Utilisation des modules:**

```nginx
# Exemple avec image-filter
location /images/ {
    image_filter resize 800 600;
    image_filter_jpeg_quality 85;
}

# Exemple avec xslt-filter
location /xml/ {
    xslt_stylesheet /path/to/transform.xsl;
}
```

### Modifier la Configuration

1. **Éditer les fichiers de configuration** dans `nginx/`
2. **Redémarrer le conteneur** pour appliquer les changements:
   ```bash
   make restart
   # ou
   docker-compose restart
   ```

### Ajouter de Nouvelles Configurations

Pour ajouter de nouveaux serveurs virtuels:

1. Créer un nouveau fichier dans `nginx/conf.d/`:
   ```bash
   touch nginx/conf.d/myapp.conf
   ```

2. Ajouter la configuration:
   ```nginx
   server {
       listen 8080;
       server_name myapp.example.com;
       # ... votre configuration
   }
   ```

3. Redémarrer le conteneur

### Vérifier la Configuration

Avant de redémarrer, vérifiez que la configuration est valide:

```bash
docker exec app-container nginx -t
```

## 🔄 Proxy vers Node.js

La configuration par défaut configure Nginx comme reverse proxy vers l'application Node.js sur le port 3000.

**Configuration actuelle:**
```nginx
location / {
    proxy_pass http://localhost:3000;
    # ... headers et options
}
```

**Pour modifier le port:**
Éditez `nginx/conf.d/default.conf` et changez `proxy_pass http://localhost:3000;` vers le port souhaité.

## 📊 Logs

Les logs Nginx sont montés dans `nginx/logs/`:

- `access.log` - Logs d'accès
- `error.log` - Logs d'erreur

**Voir les logs:**
```bash
# Logs d'accès
tail -f nginx/logs/access.log

# Logs d'erreur
tail -f nginx/logs/error.log

# Via Docker
docker exec app-container tail -f /var/log/nginx/access.log
```

## 🔒 Sécurité

La configuration inclut des headers de sécurité:

- `X-Frame-Options: SAMEORIGIN`
- `X-Content-Type-Options: nosniff`
- `X-XSS-Protection: 1; mode=block`

Pour ajouter plus de sécurité (HTTPS, rate limiting, etc.), modifiez les fichiers de configuration.

## 🚀 HTTPS (Optionnel)

Pour activer HTTPS:

1. Obtenir des certificats SSL (Let's Encrypt, etc.)
2. Ajouter la configuration SSL dans `conf.d/default.conf`:
   ```nginx
   server {
       listen 443 ssl;
       ssl_certificate /path/to/cert.pem;
       ssl_certificate_key /path/to/key.pem;
       # ... reste de la configuration
   }
   ```

3. Monter les certificats dans docker-compose.yml:
   ```yaml
   volumes:
     - ./ssl:/etc/nginx/ssl:ro
   ```

## 📚 Ressources

- [Documentation Nginx](https://nginx.org/en/docs/)
- [Nginx Configuration Guide](https://nginx.org/en/docs/http/ngx_http_core_module.html)
- [Nginx Reverse Proxy](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/)
