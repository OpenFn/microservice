FROM node:16.15.1-alpine AS node

FROM hexpm/elixir:1.13.4-erlang-24.2.1-alpine-3.16.0

RUN \
  mkdir -p /opt/app && \
  chmod -R 777 /opt/app && \
  apk update && \
  apk --no-cache --update add \
  make \
  g++ \
  wget \
  curl \
  git \
  python3 \
  inotify-tools && \
  update-ca-certificates --fresh && \
  rm -rf /var/cache/apk/*

COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/share /usr/local/share
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin

# Set exposed ports
EXPOSE 4001
ENV PORT=4001

ENV HEX_HTTP_CONCURRENCY=2
ENV HEX_HTTP_TIMEOUT=120

WORKDIR /opt/app

# Cache elixir deps
ADD mix.exs mix.lock ./
RUN mix local.hex --force && \
    mix local.rebar --force

ADD assets/ ./assets/

ADD config ./config
ADD lib ./lib

RUN mix setup
RUN mix deps.compile

# Run frontend build, compile, and digest assets
RUN (cd assets/ && npm run deploy)
RUN mix do compile, phx.digest

RUN mkdir -p tmp
