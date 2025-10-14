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
	@set -a; . .env.prod; set +a; \
	docker build -f frontend/Dockerfile frontend \
		--target prod \
		--build-arg CADDYFILE=Caddyfile.preview \
		-t svelte-preview
	docker run --rm -it \
		-p 80:80 -p 443:443 \
		-e TZ=$$TZ \
		svelte-preview 

clean:
	docker image rm svelte-dev 2>/dev/null || true
	docker image rm svelte-preview 2>/dev/null || true