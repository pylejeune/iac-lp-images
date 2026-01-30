#!/bin/bash
################################################################################
# Entrypoint optionnel pour Strapi
# Ce script peut être lancé manuellement une fois le container up
# Usage: docker exec -it <container> /usr/local/bin/entrypoint.sh [command]
################################################################################

set -e

APP_DIR="${APP_DIR:-/opt/app}"
cd "${APP_DIR}"

# Fonction d'aide
show_help() {
    echo "═══════════════════════════════════════════════════════════════════════"
    echo "  Strapi Ready - Entrypoint Helper"
    echo "═══════════════════════════════════════════════════════════════════════"
    echo ""
    echo "Commandes disponibles:"
    echo ""
    echo "  install     - Exécute npm install"
    echo "  build       - Exécute npm run build"
    echo "  develop     - Exécute npm run develop (mode développement)"
    echo "  start       - Exécute npm run start (mode production)"
    echo "  full        - Exécute install + build + start"
    echo "  dev         - Exécute install + develop (mode développement)"
    echo "  shell       - Lance un shell bash interactif"
    echo "  help        - Affiche cette aide"
    echo ""
    echo "Exemples:"
    echo "  docker exec -it strapi-container /usr/local/bin/entrypoint.sh install"
    echo "  docker exec -it strapi-container /usr/local/bin/entrypoint.sh dev"
    echo "  docker exec -it strapi-container /usr/local/bin/entrypoint.sh full"
    echo ""
    echo "═══════════════════════════════════════════════════════════════════════"
}

# Fonction pour npm install
do_install() {
    echo "🔧 Installation des dépendances npm..."
    npm install --no-audit
    echo "✅ Installation terminée"
}

# Fonction pour npm build
do_build() {
    echo "🔨 Build de l'application Strapi..."
    npm run build
    echo "✅ Build terminé"
}

# Fonction pour npm develop
do_develop() {
    echo "🚀 Lancement de Strapi en mode développement..."
    npm run develop
}

# Fonction pour npm start
do_start() {
    echo "🚀 Lancement de Strapi en mode production..."
    npm run start
}

# Traitement des commandes
case "${1:-help}" in
    install)
        do_install
        ;;
    build)
        do_build
        ;;
    develop)
        do_develop
        ;;
    start)
        do_start
        ;;
    full)
        do_install
        do_build
        do_start
        ;;
    dev)
        do_install
        do_develop
        ;;
    shell)
        echo "🐚 Lancement du shell..."
        exec /bin/bash
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "❌ Commande inconnue: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
