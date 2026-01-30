# =============================================================================
# Makefile Strapi Ready — Container Alpine qui reste up
# =============================================================================
# Usage rapide:
#   make              → affiche l'aide
#   make up           → démarrer le container (reste idle)
#   make exec-dev     → lancer npm install + npm develop dans le container
#   make help         → aide détaillée avec exemples
# =============================================================================

.PHONY: help build build-no-cache up down restart
.PHONY: logs shell exec exec-install exec-build exec-dev exec-start exec-full
.PHONY: clean clean-all test health stats
.PHONY: ecr-login ecr-tag ecr-push
.PHONY: connect-ecs list-ecs-tasks

# -----------------------------------------------------------------------------
# Variables (surchargeables en ligne de commande : make build IMAGE_TAG=v1.0)
# -----------------------------------------------------------------------------
IMAGE_NAME     ?= strapi-ready
IMAGE_TAG      ?= latest
CONTAINER_NAME ?= strapi-ready
AWS_ACCOUNT_ID ?= 918845180861
AWS_REGION     ?= eu-west-3
ECR_REPOSITORY  = $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(IMAGE_NAME)

# Variables ECS (pour connect-ecs)
ECS_CLUSTER    ?= strapi-cluster
ECS_SERVICE    ?= strapi-service
ECS_CONTAINER  ?= strapi

# Cible par défaut : afficher l'aide
.DEFAULT_GOAL := help

# -----------------------------------------------------------------------------
# Aide
# -----------------------------------------------------------------------------
help: ## Afficher cette aide (sections + exemples)
	@echo ""
	@echo "\033[1mMakefile Strapi Ready — Commandes disponibles\033[0m"
	@echo "\033[90m────────────────────────────────────────────────────────────\033[0m"
	@echo ""
	@echo "\033[1;36m▶ Démarrage & arrêt\033[0m"
	@grep -E '^(up|down|restart):.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "\033[1;36m▶ Exécution de commandes dans le container\033[0m"
	@grep -E '^exec[a-zA-Z_-]*:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "\033[1;36m▶ Build de l'image\033[0m"
	@grep -E '^build[a-zA-Z_-]*:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "\033[1;36m▶ Logs, debug, santé\033[0m"
	@grep -E '^(logs|shell|test|health|stats):.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "\033[1;36m▶ Nettoyage\033[0m"
	@grep -E '^clean[a-zA-Z_-]*:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "\033[1;36m▶ AWS ECR (push image)\033[0m"
	@grep -E '^ecr-[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "\033[1;36m▶ AWS ECS (connexion)\033[0m"
	@grep -E '^(connect-ecs|list-ecs-tasks):.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "\033[90m────────────────────────────────────────────────────────────\033[0m"
	@echo "\033[1mExemples d'utilisation\033[0m"
	@echo ""
	@echo "  \033[33m# Workflow typique (container idle → commandes manuelles)\033[0m"
	@echo "  make up           \033[90m# démarre le container (reste idle)\033[0m"
	@echo "  make exec-install \033[90m# npm install\033[0m"
	@echo "  make exec-dev     \033[90m# npm install + npm develop\033[0m"
	@echo "  make logs         \033[90m# suivre les logs\033[0m"
	@echo "  \033[90m→ Strapi: http://localhost:1337/admin\033[0m"
	@echo ""
	@echo "  \033[33m# Entrer dans le container pour commandes manuelles\033[0m"
	@echo "  make shell        \033[90m# ouvre un bash interactif\033[0m"
	@echo ""
	@echo "  \033[33m# Construire et pousser l'image vers ECR\033[0m"
	@echo "  make build        \033[90m# build image\033[0m"
	@echo "  make ecr-push     \033[90m# login ECR + tag + push\033[0m"
	@echo ""
	@echo "  \033[33m# Se connecter au container ECS (via SSM/ECS Exec)\033[0m"
	@echo "  make list-ecs-tasks \033[90m# lister les tâches ECS en cours\033[0m"
	@echo "  make connect-ecs    \033[90m# ouvrir un shell dans le container ECS\033[0m"
	@echo ""
	@echo "\033[1mExemples avec paramètres\033[0m \033[90m(VAR=val surcharge les variables)\033[0m"
	@echo ""
	@echo "  \033[33m# Build avec un tag personnalisé\033[0m"
	@echo "  make build IMAGE_TAG=v1.0.0"
	@echo ""
	@echo "  \033[33m# Lancer avec un nom de container différent\033[0m"
	@echo "  make up CONTAINER_NAME=strapi-test"
	@echo "  make exec-dev CONTAINER_NAME=strapi-test"
	@echo ""
	@echo "  \033[33m# Connexion ECS avec cluster/service personnalisé\033[0m"
	@echo "  make connect-ecs ECS_CLUSTER=my-cluster ECS_SERVICE=my-service"
	@echo ""
	@echo "  \033[90mVariables: IMAGE_NAME, IMAGE_TAG, CONTAINER_NAME, AWS_ACCOUNT_ID, AWS_REGION\033[0m"
	@echo "  \033[90mVariables ECS: ECS_CLUSTER, ECS_SERVICE, ECS_CONTAINER\033[0m"
	@echo ""

# -----------------------------------------------------------------------------
# Démarrage & arrêt
# -----------------------------------------------------------------------------
up: ## Démarrer les containers (Strapi reste idle + PostgreSQL)
	@echo "🚀 Démarrage des containers..."
	docker-compose up -d --build
	@echo "✅ Containers démarrés (Strapi reste idle)"
	@echo ""
	@echo "📌 Prochaines étapes:"
	@echo "   make exec-install  → installer les dépendances"
	@echo "   make exec-dev      → install + lancer en mode développement"
	@echo "   make shell         → entrer dans le container"

down: ## Arrêter les containers
	@echo "🛑 Arrêt des containers..."
	docker-compose down

restart: down up ## Redémarrer les containers

# -----------------------------------------------------------------------------
# Exécution de commandes dans le container
# -----------------------------------------------------------------------------
exec: ## Lancer entrypoint.sh avec une commande (usage: make exec CMD=install)
	docker exec -it $(CONTAINER_NAME) /usr/local/bin/entrypoint.sh $(CMD)

exec-install: ## Exécuter npm install dans le container
	@echo "📦 Installation des dépendances..."
	docker exec -it $(CONTAINER_NAME) /usr/local/bin/entrypoint.sh install

exec-build: ## Exécuter npm run build dans le container
	@echo "🔨 Build de Strapi..."
	docker exec -it $(CONTAINER_NAME) /usr/local/bin/entrypoint.sh build

exec-dev: ## Exécuter install + develop (mode développement)
	@echo "🚀 Lancement en mode développement..."
	docker exec -it $(CONTAINER_NAME) /usr/local/bin/entrypoint.sh dev

exec-start: ## Exécuter npm run start (mode production)
	@echo "🚀 Lancement en mode production..."
	docker exec -it $(CONTAINER_NAME) /usr/local/bin/entrypoint.sh start

exec-full: ## Exécuter install + build + start (production complète)
	@echo "🚀 Lancement complet (install + build + start)..."
	docker exec -it $(CONTAINER_NAME) /usr/local/bin/entrypoint.sh full

# -----------------------------------------------------------------------------
# Build de l'image
# -----------------------------------------------------------------------------
build: ## Construire l'image Docker (linux/amd64)
	docker build --platform linux/amd64 -t $(IMAGE_NAME):$(IMAGE_TAG) .

build-no-cache: ## Construire l'image sans cache
	docker build --platform linux/amd64 --no-cache -t $(IMAGE_NAME):$(IMAGE_TAG) .

# -----------------------------------------------------------------------------
# Logs, debug, santé
# -----------------------------------------------------------------------------
logs: ## Afficher les logs du container Strapi
	docker-compose logs -f strapi

shell: ## Ouvrir un shell bash dans le container
	docker exec -it $(CONTAINER_NAME) /bin/bash

test: ## Vérifier Node/npm dans l'image
	docker run --rm $(IMAGE_NAME):$(IMAGE_TAG) node --version
	docker run --rm $(IMAGE_NAME):$(IMAGE_TAG) npm --version

health: ## Statut de santé du container
	@docker inspect --format='{{.State.Status}}' $(CONTAINER_NAME) 2>/dev/null || echo "Container non trouvé"

stats: ## Statistiques du container (CPU, RAM)
	docker stats $(CONTAINER_NAME)

# -----------------------------------------------------------------------------
# Nettoyage
# -----------------------------------------------------------------------------
clean: ## Supprimer le container et l'image locale
	docker rm -f $(CONTAINER_NAME) || true
	docker rmi $(IMAGE_NAME):$(IMAGE_TAG) || true

clean-all: clean ## Nettoyage complet (+ volumes, prune)
	docker-compose down -v
	docker system prune -f

# -----------------------------------------------------------------------------
# AWS ECR
# -----------------------------------------------------------------------------
ecr-login: ## Authentification AWS ECR
	@echo "🔐 Authentification ECR..."
	aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(ECR_REPOSITORY)

ecr-tag: build ## Taguer l'image pour ECR
	docker tag $(IMAGE_NAME):$(IMAGE_TAG) $(ECR_REPOSITORY):$(IMAGE_TAG)

ecr-push: ecr-login ecr-tag ## Build + login ECR + tag + push
	@echo "📤 Push vers ECR..."
	docker push $(ECR_REPOSITORY):$(IMAGE_TAG)
	@echo "✅ Image poussée: $(ECR_REPOSITORY):$(IMAGE_TAG)"

# -----------------------------------------------------------------------------
# AWS ECS (connexion via SSM/ECS Exec)
# -----------------------------------------------------------------------------
list-ecs-tasks: ## Lister les tâches ECS en cours pour le service
	@echo "📋 Tâches ECS en cours pour $(ECS_SERVICE)..."
	@aws ecs list-tasks \
		--cluster $(ECS_CLUSTER) \
		--service-name $(ECS_SERVICE) \
		--region $(AWS_REGION) \
		--query 'taskArns[]' \
		--output table

connect-ecs: ## Se connecter au container ECS via SSM/ECS Exec
	@echo "🔌 Connexion au container ECS..."
	@echo "   Cluster: $(ECS_CLUSTER)"
	@echo "   Service: $(ECS_SERVICE)"
	@echo "   Container: $(ECS_CONTAINER)"
	@echo ""
	@TASK_ARN=$$(aws ecs list-tasks \
		--cluster $(ECS_CLUSTER) \
		--service-name $(ECS_SERVICE) \
		--region $(AWS_REGION) \
		--query 'taskArns[0]' \
		--output text); \
	if [ "$$TASK_ARN" = "None" ] || [ -z "$$TASK_ARN" ]; then \
		echo "❌ Aucune tâche ECS trouvée pour le service $(ECS_SERVICE)"; \
		exit 1; \
	fi; \
	echo "📌 Task ARN: $$TASK_ARN"; \
	echo ""; \
	aws ecs execute-command \
		--cluster $(ECS_CLUSTER) \
		--task $$TASK_ARN \
		--container $(ECS_CONTAINER) \
		--region $(AWS_REGION) \
		--interactive \
		--command "/bin/bash"
