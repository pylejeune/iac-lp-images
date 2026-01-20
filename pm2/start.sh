#!/bin/bash
################################################################################
# Script de démarrage PM2
# Ce script gère le démarrage de l'application Node.js avec PM2
################################################################################

set -e

APP_DIR="/home/appuser/app"
PM2_CONFIG="${APP_DIR}/ecosystem.config.js"
PACKAGE_JSON="${APP_DIR}/package.json"

cd "$APP_DIR"

echo "🚀 Démarrage de l'application avec PM2..."
echo "   Répertoire: $APP_DIR"
echo "   Environnement: ${NODE_ENV:-production}"

# Vérifier si ecosystem.config.js existe
if [ -f "$PM2_CONFIG" ]; then
    echo "✅ Configuration PM2 trouvée: $PM2_CONFIG"
    pm2-runtime start "$PM2_CONFIG"
elif [ -f "$PACKAGE_JSON" ]; then
    echo "✅ package.json trouvé, démarrage avec npm"
    # Vérifier si un script start existe
    if grep -q '"start"' "$PACKAGE_JSON"; then
        pm2-runtime start npm -- start
    else
        echo "⚠️  Aucun script 'start' trouvé dans package.json"
        echo "   Démarrage avec node server.js par défaut"
        pm2-runtime start server.js || pm2-runtime start index.js || pm2-runtime start app.js
    fi
else
    echo "⚠️  Aucune application Node.js trouvée."
    echo "   Fichiers attendus:"
    echo "   - $PM2_CONFIG"
    echo "   - $PACKAGE_JSON"
    echo "   - server.js, index.js ou app.js"
    echo ""
    echo "   Nginx continuera de fonctionner, mais l'application Node.js ne sera pas démarrée."
    # Garder le conteneur en vie
    tail -f /dev/null
fi
