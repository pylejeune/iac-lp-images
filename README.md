# terraform-lp-images

Projet regroupant les applications et services du projet LP Images.

## Structure

```
.
├── ia-api/          # API principale (Node.js, Nginx, PM2)
├── strapi/          # CMS Strapi (à configurer)
├── .cursor/         # Configuration Cursor
└── README.md
```

## Répertoires

### ia-api

Application API avec Ubuntu 24 LTS, Node.js 22, Nginx et PM2.

**Démarrer :**
```bash
cd ia-api
make build
make run-compose
```

Voir [ia-api/README.md](ia-api/README.md) pour la documentation complète.

### strapi

Répertoire dédié au CMS Strapi. À configurer.

## Développement

Chaque application se trouve dans son propre répertoire avec ses propres configurations Docker et scripts.
