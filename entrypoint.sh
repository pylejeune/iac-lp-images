#!/bin/bash
################################################################################
# Entrypoint principal du conteneur
# Ce script démarre nginx et l'application Node.js avec PM2
################################################################################

set -e

echo "🚀 Démarrage du conteneur..."
echo "   Environnement: ${NODE_ENV:-production}"

# Démarrer nginx en arrière-plan (nécessite root)
echo "📦 Démarrage de Nginx..."
nginx -g "daemon off;" &
NGINX_PID=$!

# Attendre que nginx démarre
sleep 2

# Vérifier que nginx est bien démarré
if ! kill -0 $NGINX_PID 2>/dev/null; then
    echo "❌ Erreur: Nginx n'a pas pu démarrer"
    exit 1
fi

echo "✅ Nginx démarré (PID: $NGINX_PID)"

# Changer vers l'utilisateur non-root et démarrer l'application Node.js avec PM2
echo "📦 Démarrage de l'application Node.js avec PM2..."
su - appuser -c "/usr/local/bin/pm2-start.sh" &
PM2_PID=$!

# Attendre que PM2 démarre
sleep 2

# Vérifier que PM2 est bien démarré
if ! kill -0 $PM2_PID 2>/dev/null; then
    echo "⚠️  Avertissement: PM2 n'a pas pu démarrer, mais le conteneur continue"
fi

echo "✅ Application démarrée"
echo "🌐 Nginx écoute sur le port 80"
echo "📊 PM2 gère l'application Node.js"

# Attendre que nginx se termine (ou PM2 si nginx échoue)
wait $NGINX_PID
NGINX_EXIT=$?

# Si nginx se termine, arrêter PM2 aussi
if [ $NGINX_EXIT -ne 0 ]; then
    echo "❌ Nginx s'est terminé avec le code $NGINX_EXIT"
    kill $PM2_PID 2>/dev/null || true
    exit $NGINX_EXIT
fi
