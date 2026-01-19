# MCP Servers pour Docker

Ce répertoire contient la configuration des serveurs MCP (Model Context Protocol) utiles pour le développement Docker.

## 🐳 Serveurs MCP Disponibles

### 1. Docker MCP Server
**Package**: `@modelcontextprotocol/server-docker`

**Description**: Permet d'interagir avec Docker directement depuis l'IA :
- Gérer les conteneurs (start, stop, restart, logs)
- Gérer les images (build, pull, push, inspect)
- Gérer les réseaux et volumes
- Inspecter l'état des conteneurs

**Installation**:
```bash
npm install -g @modelcontextprotocol/server-docker
```

**Utilisation**:
L'IA peut maintenant exécuter des commandes Docker et analyser l'état de vos conteneurs.

### 2. Docker Compose MCP Server
**Package**: `@modelcontextprotocol/server-docker-compose`

**Description**: Gestion avancée de docker-compose :
- Gérer les services et stacks
- Orchestrer plusieurs conteneurs
- Analyser les dépendances entre services
- Gérer les configurations multi-environnements

**Installation**:
```bash
npm install -g @modelcontextprotocol/server-docker-compose
```

### 3. Kubernetes MCP Server
**Package**: `@modelcontextprotocol/server-kubernetes`

**Description**: Utile si vous utilisez Kubernetes ou Docker Swarm :
- Gérer les pods, services, deployments
- Analyser les configurations K8s
- Gérer les namespaces et ressources

**Installation**:
```bash
npm install -g @modelcontextprotocol/server-kubernetes
```

### 4. Filesystem MCP Server
**Package**: `@modelcontextprotocol/server-filesystem`

**Description**: Accès au système de fichiers pour :
- Lire et modifier les Dockerfiles
- Gérer les fichiers docker-compose.yml
- Accéder aux fichiers de configuration

**Installation**:
```bash
npm install -g @modelcontextprotocol/server-filesystem
```

## 📋 Configuration

La configuration est dans `docker-mcp.json`. Pour l'activer dans Cursor :

1. Ouvrir les paramètres Cursor
2. Aller dans "MCP Servers"
3. Importer la configuration depuis `.cursor/mcp/docker-mcp.json`

## 🔍 Vérification de Disponibilité

Pour vérifier si les packages sont disponibles sur npm :

```bash
npm view @modelcontextprotocol/server-docker
npm view @modelcontextprotocol/server-docker-compose
npm view @modelcontextprotocol/server-kubernetes
npm view @modelcontextprotocol/server-filesystem
```

## ⚠️ Note

Certains packages MCP peuvent ne pas être disponibles publiquement. Dans ce cas :
- Utiliser des alternatives communautaires
- Créer des scripts personnalisés
- Utiliser l'API Docker directement via des scripts

## 🚀 Alternatives

Si les packages officiels ne sont pas disponibles, vous pouvez :

1. **Utiliser des scripts shell** : Créer des scripts dans `scripts/` qui utilisent l'API Docker
2. **API Docker** : Utiliser directement l'API Docker via HTTP
3. **Docker CLI wrapper** : Créer des wrappers autour de `docker` et `docker-compose`

## 📚 Ressources

- [Model Context Protocol](https://modelcontextprotocol.io/)
- [Docker API Documentation](https://docs.docker.com/engine/api/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
