#!/bin/bash

################################################################################
# Script pour vérifier la disponibilité des serveurs MCP Docker
################################################################################

set -e

echo "🔍 Vérification de la disponibilité des serveurs MCP Docker..."
echo ""

PACKAGES=(
  "@modelcontextprotocol/server-docker"
  "@modelcontextprotocol/server-docker-compose"
  "@modelcontextprotocol/server-kubernetes"
  "@modelcontextprotocol/server-filesystem"
)

AVAILABLE=()
UNAVAILABLE=()

for package in "${PACKAGES[@]}"; do
  echo "Vérification de $package..."
  if npm view "$package" version >/dev/null 2>&1; then
    VERSION=$(npm view "$package" version)
    echo "  ✅ Disponible (version: $VERSION)"
    AVAILABLE+=("$package")
  else
    echo "  ❌ Non disponible sur npm"
    UNAVAILABLE+=("$package")
  fi
done

echo ""
echo "📊 Résumé:"
echo "  ✅ Disponibles: ${#AVAILABLE[@]}"
echo "  ❌ Non disponibles: ${#UNAVAILABLE[@]}"

if [ ${#UNAVAILABLE[@]} -gt 0 ]; then
  echo ""
  echo "⚠️  Packages non disponibles:"
  for package in "${UNAVAILABLE[@]}"; do
    echo "  - $package"
  done
  echo ""
  echo "💡 Alternatives:"
  echo "  - Utiliser des scripts shell personnalisés"
  echo "  - Utiliser l'API Docker directement"
  echo "  - Créer des wrappers autour de docker/docker-compose"
fi

echo ""
echo "✅ Vérification terminée"
