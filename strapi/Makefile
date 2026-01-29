.PHONY: help build build-no-cache run run-compose stop stop-compose clean clean-all logs logs-compose shell test health stats restart ecr-login ecr-push local-up local-down local-logs local-shell local-init

# Variables
IMAGE_NAME = shared-images
IMAGE_TAG = strapi
CONTAINER_NAME = strapi-container
AWS_ACCOUNT_ID = 918845180861
AWS_REGION = eu-west-3
ECR_REPOSITORY = $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(IMAGE_NAME)

help: ## Afficher l'aide
	@echo "Commandes disponibles:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Construire l'image Docker
	docker build --platform linux/amd64 -t $(IMAGE_NAME):$(IMAGE_TAG) .

build-no-cache: ## Construire l'image sans utiliser le cache
	docker build --platform linux/amd64 --no-cache -t $(IMAGE_NAME):$(IMAGE_TAG) .

run: ## Lancer le conteneur (nécessite un fichier .env)
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

stop-compose: ## Arrêter avec docker-compose
	docker-compose down

clean: ## Supprimer le conteneur et l'image
	docker rm -f $(CONTAINER_NAME) || true
	docker rmi $(IMAGE_NAME):$(IMAGE_TAG) || true

clean-all: clean ## Nettoyer complètement (conteneur, image, volumes)
	docker-compose down -v
	docker system prune -f

logs: ## Afficher les logs du conteneur
	docker logs -f $(CONTAINER_NAME)

logs-compose: ## Afficher les logs avec docker-compose
	docker-compose logs -f

shell: ## Ouvrir un shell dans le conteneur
	docker exec -it $(CONTAINER_NAME) /bin/sh

test: ## Tester l'image (versions installées)
	docker run --rm $(IMAGE_NAME):$(IMAGE_TAG) node --version
	docker run --rm $(IMAGE_NAME):$(IMAGE_TAG) npm --version

health: ## Vérifier le statut de santé
	docker inspect --format='{{.State.Health.Status}}' $(CONTAINER_NAME) || echo "Aucun health check configuré"

stats: ## Afficher les statistiques du conteneur
	docker stats $(CONTAINER_NAME)

restart: stop run-compose ## Redémarrer le conteneur (avec docker-compose)

ecr-login: ## S'authentifier avec AWS ECR
	@echo "Authentification avec AWS ECR..."
	aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(ECR_REPOSITORY)

ecr-tag: build ## Taguer l'image pour ECR
	docker tag $(IMAGE_NAME):$(IMAGE_TAG) $(ECR_REPOSITORY):$(IMAGE_TAG)

ecr-push: ecr-login ecr-tag ## Pousser l'image vers ECR
	@echo "Push de l'image vers ECR..."
	docker push $(ECR_REPOSITORY):$(IMAGE_TAG)
	@echo "Image poussée avec succès: $(ECR_REPOSITORY):$(IMAGE_TAG)"

# Commandes pour le développement local
local-init: ## Créer le fichier .env.local depuis l'exemple si il n'existe pas
	@if [ ! -f .env.local ]; then \
		cp .env.local.example .env.local; \
		echo "✅ Fichier .env.local créé depuis .env.local.example"; \
		echo "⚠️  N'oubliez pas de générer des secrets sécurisés avec: openssl rand -base64 32"; \
	else \
		echo "ℹ️  Le fichier .env.local existe déjà"; \
	fi

local-up: local-init ## Lancer Strapi en local avec docker-compose (PostgreSQL inclus)
	@echo "🚀 Démarrage de Strapi en local..."
	@echo "⚠️  Désactivation temporaire du proxy pour le build Docker..."
	@HTTP_PROXY= HTTPS_PROXY= http_proxy= https_proxy= NO_PROXY= no_proxy= docker-compose -f docker-compose.local.yml build --no-cache
	@HTTP_PROXY= HTTPS_PROXY= http_proxy= https_proxy= NO_PROXY= no_proxy= docker-compose -f docker-compose.local.yml up -d
	@echo "✅ Strapi est accessible sur http://localhost:1337"
	@echo "📊 Pour voir les logs: make local-logs"

local-down: ## Arrêter Strapi en local
	@echo "🛑 Arrêt de Strapi en local..."
	docker-compose -f docker-compose.local.yml down

local-logs: ## Afficher les logs de Strapi en local
	docker-compose -f docker-compose.local.yml logs -f strapi

local-shell: ## Ouvrir un shell dans le conteneur Strapi local
	docker exec -it strapi-local /bin/bash
