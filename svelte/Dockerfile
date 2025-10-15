FROM node:22.20.0-alpine AS dev
WORKDIR /app
COPY package.json ./
EXPOSE 5173
ENTRYPOINT ["sh","-c","npm install && npm run dev"]

FROM node:22.20.0-alpine AS build
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build

FROM caddy:2-builder AS caddy
RUN xcaddy build --with github.com/caddyserver/replace-response

FROM gcr.io/distroless/base-debian12 AS prod
ARG CADDYFILE=Caddyfile.prod
COPY --from=caddy /usr/bin/caddy /usr/bin/caddy
COPY --from=build /app/build /usr/share/caddy
COPY ${CADDYFILE} /etc/caddy/Caddyfile
USER 65532:65532
EXPOSE 80 443
VOLUME ["/data","/config"]
ENTRYPOINT ["/usr/bin/caddy","run","--config","/etc/caddy/Caddyfile","--adapter","caddyfile"]