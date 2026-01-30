################################################################################
# Dockerfile Strapi Ready - Alpine
# Container qui reste up sans exécuter automatiquement npm install/run/build
# Utiliser entrypoint.sh pour lancer les commandes manuellement
################################################################################
FROM node:18-alpine AS base

# Métadonnées
LABEL maintainer="LP Images"
LABEL description="Strapi ready container - Alpine based"

# Variables d'environnement
ENV NODE_ENV=development \
    HOST=0.0.0.0 \
    PORT=1337 \
    APP_DIR=/opt/app

# Installer les dépendances système nécessaires pour Strapi
# - build-base : outils de compilation (gcc, g++, make)
# - python3 : requis par node-gyp
# - git : pour certaines dépendances npm
# - vips-dev : traitement d'images (sharp/libvips pour Strapi)
# - autoconf/automake : outils de build
# - openssh : client et serveur SSH
RUN apk add --no-cache \
    build-base \
    python3 \
    git \
    vips-dev \
    libpng-dev \
    zlib-dev \
    autoconf \
    automake \
    nasm \
    curl \
    bash \
    openssh \
    && npm config set registry https://registry.npmjs.org/ \
    && npm install -g node-gyp pm2

# Créer un utilisateur non-root
RUN addgroup -g 1001 -S appuser \
    && adduser -u 1001 -S appuser -G appuser -h /home/appuser -s /bin/bash \
    && mkdir -p ${APP_DIR} \
    && chown -R appuser:appuser ${APP_DIR} /home/appuser

# Répertoire de travail
WORKDIR ${APP_DIR}

# Copier l'entrypoint optionnel
COPY --chown=appuser:appuser entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Exposer le port Strapi
EXPOSE 1337

# Passer à l'utilisateur non-root
USER appuser

# Le container reste up sans rien exécuter
# Utiliser 'docker exec' pour entrer dans le container
# Ou lancer manuellement entrypoint.sh
CMD ["tail", "-f", "/dev/null"]
