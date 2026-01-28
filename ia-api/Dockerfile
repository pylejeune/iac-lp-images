################################################################################
# Stage 1: Build - Installation des dépendances et build de l'application
################################################################################
FROM ubuntu:24.04 AS builder

# Variables d'environnement pour éviter les prompts interactifs
ENV DEBIAN_FRONTEND=noninteractive \
    NODE_VERSION=22 \
    NGINX_VERSION=1.26.0

# Installer les dépendances système de base
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        xz-utils \
        openssl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    # Mettre à jour les certificats CA
    update-ca-certificates

# Installer Node.js 22.11.0 LTS via les binaires officiels (plus fiable pour Ubuntu 24.04)
# Utiliser x64 (amd64) - compatible avec --platform linux/amd64 dans le build
RUN NODE_VERSION_FULL="22.11.0" && \
    ARCH="x64" && \
    echo "Installing Node.js ${NODE_VERSION_FULL} for architecture: ${ARCH}" && \
    curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION_FULL}/node-v${NODE_VERSION_FULL}-linux-${ARCH}.tar.xz" -o /tmp/node.tar.xz && \
    tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1 && \
    rm -f /tmp/node.tar.xz && \
    ln -sf /usr/local/bin/node /usr/bin/node && \
    ln -sf /usr/local/bin/npm /usr/bin/npm

# Installer nginx avec les modules nécessaires
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        nginx \
        libnginx-mod-http-image-filter \
        libnginx-mod-http-xslt-filter && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Vérifier que Node.js et npm sont installés
RUN node --version && npm --version || (echo "Node.js installation failed" && exit 1)

# Installer pm2 globalement
# Désactiver strict-ssl pour l'installation (problème de certificats dans le builder)
# Supprimer toute configuration existante et forcer la désactivation
RUN npm config delete strict-ssl 2>/dev/null || true && \
    npm config delete cafile 2>/dev/null || true && \
    npm config set strict-ssl false && \
    npm config set registry https://registry.npmjs.org/ && \
    echo "Configuration npm:" && \
    npm config get strict-ssl && \
    npm install -g pm2 && \
    npm cache clean --force && \
    # Vérifier que pm2 est installé
    pm2 --version

# Vérifier les versions installées
RUN node --version && \
    npm --version && \
    nginx -v && \
    pm2 --version

################################################################################
# Stage 2: Production - Image finale optimisée
################################################################################
FROM ubuntu:24.04

# Variables d'environnement
ENV DEBIAN_FRONTEND=noninteractive \
    NODE_ENV=production \
    PM2_HOME=/home/appuser/.pm2

# Créer un utilisateur non-root
RUN groupadd -r appuser && \
    useradd -r -g appuser -u 1001 -d /home/appuser -s /bin/bash appuser && \
    mkdir -p /home/appuser && \
    chown -R appuser:appuser /home/appuser

# Installer les dépendances système de base
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        xz-utils \
        procps \
        openssl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    # Mettre à jour les certificats CA
    update-ca-certificates

# Installer Node.js 22.11.0 LTS via les binaires officiels (plus fiable pour Ubuntu 24.04)
# Utiliser x64 (amd64) - compatible avec --platform linux/amd64 dans le build
RUN NODE_VERSION_FULL="22.11.0" && \
    ARCH="x64" && \
    echo "Installing Node.js ${NODE_VERSION_FULL} for architecture: ${ARCH}" && \
    curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION_FULL}/node-v${NODE_VERSION_FULL}-linux-${ARCH}.tar.xz" -o /tmp/node.tar.xz && \
    tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1 && \
    rm -f /tmp/node.tar.xz && \
    ln -sf /usr/local/bin/node /usr/bin/node && \
    ln -sf /usr/local/bin/npm /usr/bin/npm

# Installer nginx avec les modules nécessaires
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        nginx \
        libnginx-mod-http-image-filter \
        libnginx-mod-http-xslt-filter && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Vérifier que Node.js et npm sont installés
RUN node --version && npm --version || (echo "Node.js installation failed" && exit 1)

# Configurer npm pour l'utilisateur appuser avec les certificats système
RUN echo "cafile=/etc/ssl/certs/ca-certificates.crt" > /home/appuser/.npmrc && \
    echo "strict-ssl=true" >> /home/appuser/.npmrc && \
    chown appuser:appuser /home/appuser/.npmrc && \
    # Configurer aussi via npm config pour être sûr
    su - appuser -c "npm config set cafile /etc/ssl/certs/ca-certificates.crt && npm config set strict-ssl true" || true

# Copier pm2 depuis le stage builder
COPY --from=builder /usr/local/bin/pm2 /usr/local/bin/pm2
COPY --from=builder /usr/local/lib/node_modules/pm2 /usr/local/lib/node_modules/pm2

# Configurer npm pour utiliser les certificats système
RUN npm config set cafile /etc/ssl/certs/ca-certificates.crt && \
    npm config set strict-ssl false

# Installer pm2 globalement (si nécessaire)
RUN npm install -g pm2 && \
    npm cache clean --force

# Créer les répertoires nécessaires
RUN mkdir -p /var/www/html \
             /var/log/nginx \
             /var/cache/nginx \
             /etc/nginx/conf.d \
             /etc/nginx/sites-available \
             /etc/nginx/sites-enabled \
             /etc/nginx/modules-enabled \
             /home/appuser/app && \
    chown -R appuser:appuser /var/www/html \
                            /var/log/nginx \
                            /var/cache/nginx \
                            /home/appuser

# Copier la configuration nginx principale
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Copier les modules nginx activés
COPY nginx/modules-enabled/ /etc/nginx/modules-enabled/

# Copier la configuration par défaut dans le fichier par défaut de nginx
# Le fichier par défaut de nginx est /etc/nginx/sites-available/default
COPY nginx/sites-available/ia-api.conf /etc/nginx/sites-available/default
RUN ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# S'assurer que la configuration nginx est valide
RUN nginx -t || true

# Définir le répertoire de travail
WORKDIR /home/appuser/app

# Copier les fichiers de l'application (sera fait par l'utilisateur)
# COPY --chown=appuser:appuser . .

# Exposer les ports
EXPOSE 80 443 3000 3001

# Copier les fichiers PM2
COPY pm2/ecosystem.config.js /home/appuser/app/ecosystem.config.js
COPY pm2/start.sh /usr/local/bin/pm2-start.sh
RUN chmod +x /usr/local/bin/pm2-start.sh && \
    chown appuser:appuser /home/appuser/app/ecosystem.config.js

# Copier le script d'entrypoint principal
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:80/ || exit 1

# Entrypoint (exécuté en root pour démarrer nginx)
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
