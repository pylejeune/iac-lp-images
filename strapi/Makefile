.PHONY: help build build-no-cache run run-compose stop stop-compose clean clean-all logs logs-compose shell test health stats restart

# Variables
IMAGE_NAME = strapi
IMAGE_TAG = latest
CONTAINER_NAME = strapi-container

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
