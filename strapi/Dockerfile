# Multi-stage build pour production
FROM node:22-alpine AS build

# Installer les dépendances système nécessaires pour la compilation
RUN apk update && apk add --no-cache \
    build-base \
    gcc \
    autoconf \
    automake \
    zlib-dev \
    libpng-dev \
    nasm \
    bash \
    vips-dev \
    git \
    python3 \
    make \
    g++

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

WORKDIR /opt/

# Copier les fichiers de dépendances
COPY package.json package-lock.json* ./

# Installer node-gyp globalement
RUN npm install -g node-gyp

# Installer les dépendances (toutes pour le build)
RUN npm config set fetch-retry-maxtimeout 600000 -g && \
    npm install

ENV PATH=/opt/node_modules/.bin:$PATH

WORKDIR /opt/app

# Copier le reste de l'application
COPY . .

# Construire l'admin panel
RUN npm run build

# Image finale de production
FROM node:22-alpine

# Installer uniquement les dépendances runtime nécessaires
RUN apk add --no-cache vips-dev

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

# Configurer pour être accessible depuis l'extérieur
ENV HOST=0.0.0.0
ENV PORT=1337

WORKDIR /opt/

# Copier les node_modules depuis le stage de build
COPY --from=build /opt/node_modules ./node_modules

WORKDIR /opt/app

# Copier l'application construite depuis le stage de build
COPY --from=build /opt/app ./

ENV PATH=/opt/node_modules/.bin:$PATH

# Créer un utilisateur non-root pour la sécurité
RUN chown -R node:node /opt/app

USER node

# Exposer le port Strapi
EXPOSE 1337

# Commande de démarrage
CMD ["npm", "run", "start"]
