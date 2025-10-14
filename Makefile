dev:
	docker build -f svelte/Dockerfile svelte \
		--target dev \
		-t svelte-dev
	docker run --rm -it \
		-p 5173:5173 \
		-v $$PWD/svelte:/app \
		-v /app/node_modules \
		svelte-dev 

preview:
	@set -a; . .env.prod; set +a; \
	docker build -f svelte/Dockerfile svelte \
		--target prod \
		--build-arg CADDYFILE=Caddyfile.preview \
		-t svelte-preview
	docker run --rm -it \
		-p 80:80 -p 443:443 \
		-e TZ=$$TZ \
		svelte-preview 

prod:
	git checkout prod
	git merge --ff-only main
	git push origin prod
	git checkout main

clean:
	docker image rm svelte-dev 2>/dev/null || true
	docker image rm svelte-preview 2>/dev/null || true