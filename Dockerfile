FROM bitwalker/alpine-elixir-phoenix:latest

# Set exposed ports
EXPOSE 4001
ENV PORT=4001

ENV HEX_HTTP_CONCURRENCY=2
ENV HEX_HTTP_TIMEOUT=120

# Cache elixir deps
ADD mix.exs mix.lock ./
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