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
        xz-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

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

# Installer nginx
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Vérifier que Node.js et npm sont installés
RUN node --version && npm --version || (echo "Node.js installation failed" && exit 1)

# Installer pm2 globalement
# Configurer npm pour utiliser les certificats système
RUN npm config set strict-ssl false || true && \
    npm install -g pm2 && \
    npm cache clean --force && \
    npm config set strict-ssl true || true

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
        procps && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

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

# Installer nginx
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Vérifier que Node.js et npm sont installés
RUN node --version && npm --version || (echo "Node.js installation failed" && exit 1)

# Copier pm2 depuis le stage builder
COPY --from=builder /usr/local/bin/pm2 /usr/local/bin/pm2
COPY --from=builder /usr/local/lib/node_modules/pm2 /usr/local/lib/node_modules/pm2

# Installer pm2 globalement (si nécessaire)
# Configurer npm pour utiliser les certificats système
RUN npm config set strict-ssl false || true && \
    npm install -g pm2 && \
    npm cache clean --force && \
    npm config set strict-ssl true || true

# Créer les répertoires nécessaires
RUN mkdir -p /var/www/html \
             /var/log/nginx \
             /var/cache/nginx \
             /etc/nginx/conf.d \
             /etc/nginx/sites-available \
             /etc/nginx/sites-enabled \
             /home/appuser/app && \
    chown -R appuser:appuser /var/www/html \
                            /var/log/nginx \
                            /var/cache/nginx \
                            /home/appuser

# Copier la configuration nginx par défaut (sera remplacée par le volume si monté)
COPY nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# S'assurer que la configuration nginx est valide
RUN nginx -t || true

# Définir le répertoire de travail
WORKDIR /home/appuser/app

# Copier les fichiers de l'application (sera fait par l'utilisateur)
# COPY --chown=appuser:appuser . .

# Exposer les ports
EXPOSE 80 443

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
