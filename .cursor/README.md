# Configuration Cursor pour Docker

Ce répertoire contient la configuration complète de Cursor pour le développement Docker.

## 📁 Structure

```
.cursor/
├── rules/                    # Règles et bonnes pratiques
│   ├── 15-docker-best-practices.mdc
│   ├── 16-docker-optimization.mdc
│   └── INDEX.md
├── commands/                  # Commandes personnalisées
│   ├── docker-commands.json
│   └── README.md
└── mcp/                       # Configuration MCP
    ├── docker-mcp.json
    └── README.md
```

## 🐳 Règles Docker

### Bonnes Pratiques (`15-docker-best-practices.mdc`)
- Images multi-stage
- Gestion des dépendances
- Sécurité (utilisateur non-root, secrets)
- Health checks
- Anti-patterns à éviter

### Optimisation (`16-docker-optimization.mdc`)
- Optimisation des builds (BuildKit, cache)
- Réduction de la taille des images
- Performance runtime
- Docker Compose optimization
- CI/CD optimization

## 🎯 Commandes Docker

35+ commandes Docker prêtes à l'emploi :
- Build et images
- Gestion des conteneurs
- Inspection et debugging
- Docker Compose
- Nettoyage et maintenance

Voir [commands/README.md](commands/README.md) pour la liste complète.

## 🔌 Serveurs MCP

Configuration pour 4 serveurs MCP :
- **Docker MCP** - Gestion des conteneurs et images
- **Docker Compose MCP** - Orchestration des services
- **Kubernetes MCP** - Pour K8s et Docker Swarm
- **Filesystem MCP** - Accès aux fichiers Docker

Voir [mcp/README.md](mcp/README.md) pour plus de détails.

## 🚀 Démarrage Rapide

1. **Vérifier les MCP disponibles** :
   ```bash
   ./scripts/check-docker-mcp.sh
   ```

2. **Configurer les MCP dans Cursor** :
   - Ouvrir les paramètres Cursor
   - Aller dans "MCP Servers"
   - Importer `.cursor/mcp/docker-mcp.json`

3. **Utiliser les commandes** :
   - Ouvrir la palette (`Cmd+Shift+P` / `Ctrl+Shift+P`)
   - Taper "Docker:" pour voir toutes les commandes

## 📚 Documentation

- [Règles Docker](rules/INDEX.md)
- [Commandes Docker](commands/README.md)
- [MCP Servers](mcp/README.md)
