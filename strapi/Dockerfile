################################################################################
# Stage 1: Build - Installation des dépendances et build de l'application
################################################################################
FROM ubuntu:24.04 AS builder

# Variables d'environnement pour éviter les prompts interactifs
ENV DEBIAN_FRONTEND=noninteractive \
    NODE_VERSION=22 \
    NODE_ENV=production

# Installer les dépendances système de base
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        xz-utils \
        openssl \
        build-essential \
        python3 \
        make \
        g++ \
        git \
        libvips-dev \
        libpng-dev \
        zlib1g-dev \
        autoconf \
        automake \
        nasm && \
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

# Vérifier que Node.js et npm sont installés
RUN node --version && npm --version || (echo "Node.js installation failed" && exit 1)

# Installer node-gyp globalement
RUN npm config delete strict-ssl 2>/dev/null || true && \
    npm config delete cafile 2>/dev/null || true && \
    npm config set strict-ssl false && \
    npm config set registry https://registry.npmjs.org/ && \
    npm install -g node-gyp && \
    npm cache clean --force

# Définir le répertoire de travail
WORKDIR /opt

# Copier les fichiers de dépendances
COPY package.json package-lock.json* ./

# Installer les dépendances (toutes pour le build)
RUN npm config set fetch-retry-maxtimeout 600000 && \
    npm install && \
    npm cache clean --force

ENV PATH=/opt/node_modules/.bin:$PATH

WORKDIR /opt/app

# Copier le reste de l'application
COPY . .

# Construire l'admin panel
RUN npm run build

################################################################################
# Stage 2: Production - Image finale optimisée
################################################################################
FROM ubuntu:24.04

# Variables d'environnement
ENV DEBIAN_FRONTEND=noninteractive \
    NODE_ENV=production \
    HOST=0.0.0.0 \
    PORT=1337

# Créer un utilisateur non-root
RUN groupadd -r appuser && \
    useradd -r -g appuser -u 1001 -d /home/appuser -s /bin/bash appuser && \
    mkdir -p /home/appuser && \
    chown -R appuser:appuser /home/appuser

# Installer les dépendances système de base et runtime pour Strapi
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        xz-utils \
        procps \
        openssl \
        libvips-dev \
        libpng-dev \
        zlib1g-dev && \
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

# Vérifier que Node.js et npm sont installés
RUN node --version && npm --version || (echo "Node.js installation failed" && exit 1)

# Configurer npm pour l'utilisateur appuser avec les certificats système
RUN echo "cafile=/etc/ssl/certs/ca-certificates.crt" > /home/appuser/.npmrc && \
    echo "strict-ssl=true" >> /home/appuser/.npmrc && \
    chown appuser:appuser /home/appuser/.npmrc && \
    # Configurer aussi via npm config pour être sûr
    su - appuser -c "npm config set cafile /etc/ssl/certs/ca-certificates.crt && npm config set strict-ssl true" || true

# Configurer npm pour utiliser les certificats système
RUN npm config set cafile /etc/ssl/certs/ca-certificates.crt && \
    npm config set strict-ssl true

# Créer les répertoires nécessaires
RUN mkdir -p /opt/app && \
    chown -R appuser:appuser /opt/app

# Définir le répertoire de travail
WORKDIR /opt/app

# Copier les node_modules depuis le stage de build
COPY --from=builder --chown=appuser:appuser /opt/node_modules ./node_modules

# Copier l'application construite depuis le stage de build
COPY --from=builder --chown=appuser:appuser /opt/app ./

ENV PATH=/opt/app/node_modules/.bin:$PATH

# Vérifier les versions installées
RUN node --version && \
    npm --version

# Exposer le port Strapi
EXPOSE 1337

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:1337/_health || exit 1

# Passer à l'utilisateur non-root
USER appuser

# Commande de démarrage
CMD ["npm", "run", "start"]
