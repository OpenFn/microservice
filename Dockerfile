FROM hexpm/elixir:1.11.3-erlang-23.2.7.2-alpine-3.13.3

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
    inotify-tools \
    nodejs \
    nodejs-npm && \
    update-ca-certificates --fresh && \
    rm -rf /var/cache/apk/*

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

CMD ["mix", "phx.server"]