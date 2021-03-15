FROM bitwalker/alpine-elixir-phoenix:latest

# Set exposed ports
EXPOSE 4000
ENV PORT=4000

# Cache elixir deps
ADD mix.exs mix.lock ./
ADD assets/ ./assets/

RUN mix do setup, deps.compile

ADD config ./config
ADD lib ./lib

# Run frontend build, compile, and digest assets
RUN cd assets/ && \
    npm run deploy && \
    cd - && \
    mix do compile, phx.digest

RUN mkdir -p tmp

CMD ["mix", "phx.server"]