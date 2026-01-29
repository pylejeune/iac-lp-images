################################################################################
# Stage 0: Base - Node.js et dépendances système de base (cache optimisé)
# Ce stage change rarement et sera mis en cache
################################################################################
FROM ubuntu:24.04 AS base

# Variables d'environnement pour éviter les prompts interactifs
ENV DEBIAN_FRONTEND=noninteractive \
    NODE_VERSION_FULL="22.11.0" \
    ARCH="x64"

# Installer les dépendances système de base (cache layer)
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        xz-utils \
        openssl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    update-ca-certificates

# Installer Node.js 22.11.0 LTS (cache layer - change très rarement)
RUN curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION_FULL}/node-v${NODE_VERSION_FULL}-linux-${ARCH}.tar.xz" -o /tmp/node.tar.xz && \
    tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1 && \
    rm -f /tmp/node.tar.xz && \
    ln -sf /usr/local/bin/node /usr/bin/node && \
    ln -sf /usr/local/bin/npm /usr/bin/npm && \
    node --version && npm --version

################################################################################
# Stage 1: Builder Base - Dépendances système pour le build
################################################################################
FROM base AS builder-base

# Installer les dépendances système nécessaires pour le build
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
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
    rm -rf /var/lib/apt/lists/*

# Configurer npm pour le build
RUN npm config set strict-ssl false && \
    npm config set registry https://registry.npmjs.org/ && \
    npm install -g node-gyp

################################################################################
# Stage 2: Dependencies - Installation des dépendances npm (cache optimisé)
# Ce stage est mis en cache si package.json/package-lock.json ne changent pas
################################################################################
FROM builder-base AS dependencies

WORKDIR /opt

# Copier uniquement les fichiers de dépendances (layer cacheable)
COPY package.json package-lock.json* ./

# Installer les dépendances avec cache npm (toutes pour le build)
RUN --mount=type=cache,target=/root/.npm,sharing=locked \
    npm config set fetch-retry-maxtimeout 600000 && \
    npm ci --prefer-offline --no-audit && \
    npm cache clean --force

################################################################################
# Stage 3: Builder - Build de l'application
# Ce stage est invalidé seulement si le code source change
################################################################################
FROM dependencies AS builder

WORKDIR /opt/app

# Copier le reste de l'application (après l'installation des dépendances)
COPY . .

ENV PATH=/opt/node_modules/.bin:$PATH

# Construire l'admin panel
RUN npm run build

################################################################################
# Stage 4: Runtime Base - Base pour l'image de production
################################################################################
FROM base AS runtime-base

# Variables d'environnement
ENV NODE_ENV=production \
    HOST=0.0.0.0 \
    PORT=1337

# Créer un utilisateur non-root
RUN groupadd -r appuser && \
    useradd -r -g appuser -u 1001 -d /home/appuser -s /bin/bash appuser && \
    mkdir -p /home/appuser /opt/app && \
    chown -R appuser:appuser /home/appuser /opt/app

# Installer les dépendances système runtime uniquement (plus légères)
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        procps \
        libvips-dev \
        libpng-dev \
        zlib1g-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configurer npm pour l'utilisateur appuser avec les certificats système
RUN echo "cafile=/etc/ssl/certs/ca-certificates.crt" > /home/appuser/.npmrc && \
    echo "strict-ssl=true" >> /home/appuser/.npmrc && \
    chown appuser:appuser /home/appuser/.npmrc && \
    npm config set cafile /etc/ssl/certs/ca-certificates.crt && \
    npm config set strict-ssl true

################################################################################
# Stage 5: Production - Image finale optimisée
################################################################################
FROM runtime-base AS production

WORKDIR /opt/app

# Copier uniquement les node_modules de production depuis le stage dependencies
# (on pourrait filtrer devDependencies, mais Strapi peut en avoir besoin)
COPY --from=dependencies --chown=appuser:appuser /opt/node_modules ./node_modules

# Copier l'application construite depuis le stage builder
COPY --from=builder --chown=appuser:appuser /opt/app ./

ENV PATH=/opt/app/node_modules/.bin:$PATH

# Vérifier les versions installées
RUN node --version && npm --version

# Exposer le port Strapi
EXPOSE 1337

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:1337/_health || exit 1

# Passer à l'utilisateur non-root
USER appuser

# Commande de démarrage
CMD ["npm", "run", "start"]
