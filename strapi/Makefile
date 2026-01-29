# =============================================================================
# Makefile Strapi — Image Docker & déploiement
# =============================================================================
# Usage rapide:
#   make              → affiche l'aide
#   make local-up     → lancer Strapi en local (PostgreSQL inclus)
#   make build        → construire l'image pour la prod
#   make help         → aide détaillée avec exemples
# =============================================================================

.PHONY: help build build-no-cache run run-compose stop stop-compose clean clean-all
.PHONY: logs logs-compose shell test health stats restart
.PHONY: ecr-login ecr-tag ecr-push
.PHONY: local-up local-down local-logs local-shell local-init

# -----------------------------------------------------------------------------
# Variables (surchargeables en ligne de commande : make build IMAGE_TAG=v1.0)
# -----------------------------------------------------------------------------
IMAGE_NAME     ?= shared-images
IMAGE_TAG      ?= strapi
CONTAINER_NAME ?= strapi-container
AWS_ACCOUNT_ID ?= 918845180861
AWS_REGION     ?= eu-west-3
ECR_REPOSITORY  = $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(IMAGE_NAME)

# Cible par défaut : afficher l'aide
.DEFAULT_GOAL := help

# -----------------------------------------------------------------------------
# Aide
# -----------------------------------------------------------------------------
help: ## Afficher cette aide (sections + exemples)
	@echo ""
	@echo "\033[1mMakefile Strapi — Commandes disponibles\033[0m"
	@echo "\033[90m────────────────────────────────────────────────────────────\033[0m"
	@echo ""
	@echo "\033[1;36m▶ Développement local (recommandé pour démarrer)\033[0m"
	@grep -E '^local-[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "\033[1;36m▶ Build & exécution (image prod)\033[0m"
	@grep -E '^(build|build-no-cache|run|run-compose|stop|stop-compose):.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "\033[1;36m▶ Logs, debug, santé\033[0m"
	@grep -E '^(logs|logs-compose|shell|test|health|stats|restart):.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "\033[1;36m▶ Nettoyage\033[0m"
	@grep -E '^(clean|clean-all):.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "\033[1;36m▶ AWS ECR (push image)\033[0m"
	@grep -E '^ecr-[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "\033[90m────────────────────────────────────────────────────────────\033[0m"
	@echo "\033[1mExemples d'utilisation\033[0m"
	@echo ""
	@echo "  \033[33m# Démarrer Strapi en local (PostgreSQL inclus, prêt à l'emploi)\033[0m"
	@echo "  make local-init    \033[90m# crée .env.local si besoin\033[0m"
	@echo "  make local-up      \033[90m# lance Strapi + PostgreSQL\033[0m"
	@echo "  make local-logs    \033[90m# suivre les logs\033[0m"
	@echo "  \033[90m→ Admin: http://localhost:1337/admin\033[0m"
	@echo ""
	@echo "  \033[33m# Construire et pousser l'image vers ECR\033[0m"
	@echo "  make build        \033[90m# build image\033[0m"
	@echo "  make ecr-push     \033[90m# login ECR + tag + push\033[0m"
	@echo ""
	@echo "  \033[33m# Lancer en prod (docker-compose + .env)\033[0m"
	@echo "  make run-compose  \033[90m# nécessite un .env configuré\033[0m"
	@echo "  make logs-compose \033[90m# logs\033[0m"
	@echo "  make stop-compose \033[90m# arrêter\033[0m"
	@echo ""
	@echo "\033[1mExemples avec paramètres\033[0m \033[90m(VAR=val surcharge les variables)\033[0m"
	@echo ""
	@echo "  \033[33m# Build avec un tag personnalisé (ex: version, branche)\033[0m"
	@echo "  make build IMAGE_TAG=v1.0.0"
	@echo "  make build IMAGE_TAG=develop IMAGE_NAME=strapi-dev"
	@echo ""
	@echo "  \033[33m# Lancer un conteneur avec un nom dédié (plusieurs instances)\033[0m"
	@echo "  make run CONTAINER_NAME=strapi-staging"
	@echo "  make run IMAGE_TAG=v1.0.0 CONTAINER_NAME=strapi-v1"
	@echo ""
	@echo "  \033[33m# Logs / shell / stop sur un conteneur précis\033[0m"
	@echo "  make logs CONTAINER_NAME=strapi-staging"
	@echo "  make shell CONTAINER_NAME=strapi-staging"
	@echo "  make stop CONTAINER_NAME=strapi-staging"
	@echo ""
	@echo "  \033[33m# Nettoyer une image/conteneur spécifiques\033[0m"
	@echo "  make clean IMAGE_TAG=old CONTAINER_NAME=strapi-old"
	@echo "  make clean IMAGE_NAME=strapi-dev IMAGE_TAG=develop"
	@echo ""
	@echo "  \033[33m# Push ECR avec tag et région personnalisés\033[0m"
	@echo "  make ecr-push IMAGE_TAG=release-1.0"
	@echo "  make ecr-push AWS_REGION=eu-west-1 IMAGE_TAG=hotfix"
	@echo ""
	@echo "  \033[90mVariables surchargeables: IMAGE_NAME, IMAGE_TAG, CONTAINER_NAME, AWS_ACCOUNT_ID, AWS_REGION\033[0m"
	@echo ""

# -----------------------------------------------------------------------------
# Développement local (Strapi + PostgreSQL)
# -----------------------------------------------------------------------------
local-init: ## Créer .env.local depuis .env.local.example si absent
	@if [ ! -f .env.local ]; then \
		cp .env.local.example .env.local; \
		echo "✅ Fichier .env.local créé depuis .env.local.example"; \
		echo "⚠️  Générer des secrets: openssl rand -base64 32"; \
	else \
		echo "ℹ️  Le fichier .env.local existe déjà"; \
	fi

local-up: local-init ## Lancer Strapi en local (PostgreSQL inclus)
	@echo "🚀 Démarrage de Strapi en local..."
	@HTTP_PROXY= HTTPS_PROXY= http_proxy= https_proxy= NO_PROXY= no_proxy= docker-compose -f docker-compose.local.yml build --no-cache
	@HTTP_PROXY= HTTPS_PROXY= http_proxy= https_proxy= NO_PROXY= no_proxy= docker-compose -f docker-compose.local.yml up -d
	@echo "✅ Strapi: http://localhost:1337 — Admin: http://localhost:1337/admin"
	@echo "📊 Logs: make local-logs"

local-down: ## Arrêter Strapi en local
	@echo "🛑 Arrêt de Strapi en local..."
	docker-compose -f docker-compose.local.yml down

local-logs: ## Afficher les logs Strapi (local)
	docker-compose -f docker-compose.local.yml logs -f strapi

local-shell: ## Shell dans le conteneur Strapi local
	docker exec -it strapi-local /bin/bash

# -----------------------------------------------------------------------------
# Build & exécution (image production)
# -----------------------------------------------------------------------------
build: ## Construire l'image Docker (linux/amd64)
	docker build --platform linux/amd64 -t $(IMAGE_NAME):$(IMAGE_TAG) .

build-no-cache: ## Construire l'image sans cache
	docker build --platform linux/amd64 --no-cache -t $(IMAGE_NAME):$(IMAGE_TAG) .

run: ## Lancer le conteneur (nécessite .env)
	docker run -d \
		--name $(CONTAINER_NAME) \
		--env-file .env \
		-p 1337:1337 \
		-v $(PWD)/public/uploads:/opt/app/public/uploads \
		$(IMAGE_NAME):$(IMAGE_TAG)

run-compose: ## Lancer avec docker-compose
	docker-compose up -d

stop: ## Arrêter le conteneur
	docker stop $(CONTAINER_NAME) || true

stop-compose: ## Arrêter docker-compose
	docker-compose down

# -----------------------------------------------------------------------------
# Logs, debug, santé
# -----------------------------------------------------------------------------
logs: ## Logs du conteneur (mode suivi)
	docker logs -f $(CONTAINER_NAME)

logs-compose: ## Logs docker-compose
	docker-compose logs -f

shell: ## Shell dans le conteneur
	docker exec -it $(CONTAINER_NAME) /bin/sh

test: ## Vérifier Node/npm dans l'image
	docker run --rm $(IMAGE_NAME):$(IMAGE_TAG) node --version
	docker run --rm $(IMAGE_NAME):$(IMAGE_TAG) npm --version

health: ## Statut de santé du conteneur
	docker inspect --format='{{.State.Health.Status}}' $(CONTAINER_NAME) 2>/dev/null || echo "Aucun health check"

stats: ## Statistiques du conteneur (CPU, RAM)
	docker stats $(CONTAINER_NAME)

restart: stop run-compose ## Redémarrer (stop + run-compose)

# -----------------------------------------------------------------------------
# Nettoyage
# -----------------------------------------------------------------------------
clean: ## Supprimer conteneur et image locale
	docker rm -f $(CONTAINER_NAME) || true
	docker rmi $(IMAGE_NAME):$(IMAGE_TAG) || true

clean-all: clean ## Nettoyage complet (+ volumes docker-compose, prune)
	docker-compose down -v
	docker system prune -f

# -----------------------------------------------------------------------------
# AWS ECR
# -----------------------------------------------------------------------------
ecr-login: ## Authentification AWS ECR
	@echo "Authentification ECR..."
	aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(ECR_REPOSITORY)

ecr-tag: build ## Taguer l'image pour ECR
	docker tag $(IMAGE_NAME):$(IMAGE_TAG) $(ECR_REPOSITORY):$(IMAGE_TAG)

ecr-push: ecr-login ecr-tag ## Build + login ECR + tag + push
	@echo "Push vers ECR..."
	docker push $(ECR_REPOSITORY):$(IMAGE_TAG)
	@echo "✅ Image poussée: $(ECR_REPOSITORY):$(IMAGE_TAG)"
