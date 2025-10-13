FROM node:22.20.0-alpine AS base
WORKDIR /app
COPY package.json ./
RUN npm install

FROM base AS dev
COPY . .
EXPOSE 5173
ENTRYPOINT ["npm","run","dev"]

FROM base AS build
COPY . .
RUN npm run build

FROM caddy:2-builder AS caddy
RUN xcaddy build --with github.com/caddyserver/replace-response

FROM gcr.io/distroless/base-debian12 AS prod
COPY --from=caddy /usr/bin/caddy /usr/bin/caddy
COPY --from=build /app/build /usr/share/caddy
COPY Caddyfile /etc/caddy/Caddyfile
USER 65532:65532
EXPOSE 80 443
VOLUME ["/data","/config"]
ENTRYPOINT ["/usr/bin/caddy","run","--config","/etc/caddy/Caddyfile","--adapter","caddyfile"]