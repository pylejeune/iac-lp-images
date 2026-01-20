.PHONY: help build run stop clean logs shell test

# Variables
IMAGE_NAME = app
IMAGE_TAG = latest
CONTAINER_NAME = app-container

help: ## Afficher l'aide
	@echo "Commandes disponibles:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Construire l'image Docker
	docker build --platform linux/amd64 -t $(IMAGE_NAME):$(IMAGE_TAG) .

build-no-cache: ## Construire l'image sans utiliser le cache
	docker build --platform linux/amd64 --no-cache -t $(IMAGE_NAME):$(IMAGE_TAG) .

run: ## Lancer le conteneur
	docker run -d \
		--name $(CONTAINER_NAME) \
		-p 80:80 \
		-p 443:443 \
		-v $(PWD)/app:/home/appuser/app \
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
	docker exec -it $(CONTAINER_NAME) /bin/bash

test: ## Tester l'image (versions installées)
	docker run --rm $(IMAGE_NAME):$(IMAGE_TAG) node --version
	docker run --rm $(IMAGE_NAME):$(IMAGE_TAG) npm --version
	docker run --rm $(IMAGE_NAME):$(IMAGE_TAG) nginx -v
	docker run --rm $(IMAGE_NAME):$(IMAGE_TAG) pm2 --version

health: ## Vérifier le statut de santé
	docker inspect --format='{{.State.Health.Status}}' $(CONTAINER_NAME)

stats: ## Afficher les statistiques du conteneur
	docker stats $(CONTAINER_NAME)

restart: stop run ## Redémarrer le conteneur
