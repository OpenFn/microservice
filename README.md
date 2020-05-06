# Microservice

To start your Phoenix server:

- Install dependencies with `mix deps.get`
- Install Node.js dependencies with `cd assets && npm install`
- Create a `.env` file with `cp .env.example .env`
- Run tests with `env $(cat .env | grep -v "#" | xargs ) mix test`
- Start Phoenix interactively with `env $(cat .env | grep -v "#" | xargs ) iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## MVP

1. An open source server application (this application, `microservice`.)
2. The open source `inbox` application, which will be used by both `platform`
   and `microservice` to handle HTTP requests
3. The open source `dispatcher` application which will be used by both
   `platform` and `microservice` to execute jobs using `OpenFn/core`.
4. A Dockerfile that, given a `job`, an `adaptor`, and a `credential`, is able
   to automatically generate a container that runs the microservice for that
   job.

### Dynamic Configuration required for MVP

#### Container Config (Dockerfile)

See [Dockerfile](./Dockerfile). Must dynamically build:

```dockerfile

# ---- Build Stage ----
FROM alpine-elixir-phoenix:latest AS app_builder
RUN Please build the phoenix application...

# ---- Application Stage ----
FROM node:12-alpine AS app
COPY --from=app_builder /app/_build .

# Pull in user credential and job expression...
COPY credential.json to ./credential.json
COPY expression.js to ./expression.js

# Install core and the chosen language package
RUN su - app -c "npm install github:openfn/core#v1.3.1 --prefix ./assets"
RUN su - app -c "npm install github:openfn/language-dhis2#v1.1.1 --prefix ./assets"

USER app
CMD './bin/lib/microservice/start'
ARG 'foreground
```

#### Application Config

See [.env.example](./.env.example) for a possible config.

```sh
# basic application config
webserver=true
port='4000'

# service configuration
job_path='/home/app/expresion.js'
credential_path='/home/app/credential.json'
cron_expression='*/15 * * * *' # (only provided for a timer job)
```

## Wishlist

- Timer jobs can keep state
- Click a button on OpenFn to prepare a `microservice.zip` which is this repo
  with a new Dockerfile, based on the current job's configuration at OpenFn.org
- Visual interface for application (Phx LiveView?)
- Better Logging
- Message persistence plugin (enables retries)
- Notifications module
- more?

## Roadmap for this application

- [x] `mix phx.server` receives receipts and sends 200
- [ ] bring `core` out of package.json
- [ ] endpoint gets `URL` and `PORT` from `.env`
- [x] `ShellWorker` picks up config from `.env`
- [x] `ShellWorker` executes it, given preloaded job, cred, adaptor, and core.
- [ ] Write tests for everything.
