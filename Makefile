dev:
	docker build -f frontend/Dockerfile frontend \
		--target dev \
		-t svelte-dev
	docker run --rm -it \
		-p 5173:5173 \
		-v $$PWD/frontend:/app \
		-v /app/node_modules \
		svelte-dev 

preview:
	docker build -f frontend/Dockerfile frontend \
		--target prod \
		--build-arg CADDYFILE=Caddyfile.preview \
		-t svelte-prod
	docker run --rm -it \
		-p 80:80 -p 443:443 \
		-e TZ=Europe/Paris \
		svelte-prod 
 
prod:
	docker run --rm -it \
		-p 80:80 -p 443:443 \
		-e TZ=Europe/Paris \
		-v caddy_data:/data \
		-v caddy_config:/config \
		ghcr.io/<OWNER>/<REPO>-frontend:latest

clean:
	docker image rm svelte-dev 2>/dev/null || true
	docker image rm svelte-prod 2>/dev/null || true
