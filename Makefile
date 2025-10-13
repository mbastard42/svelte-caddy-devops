dev:
	docker compose -f compose.dev.yaml up --build

down:
	docker compose down

prod-up:
	docker compose -f compose.prod.yaml up -d

prod-pull:
	docker compose -f compose.prod.yaml pull

logs:
	docker compose logs -f