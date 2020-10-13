# OpenFn/microservice ![Build Status](https://travis-ci.org/OpenFn/microservice.svg?branch=master)

![openfn](assets/logo.png)

## Intent

OpenFn is used by numerous health and humanitarian organizations around the
world to scale their progrms through real-time interoperability, systems
integration, and workflow automation. **OpenFn/microservice** makes use of
OpenFn's open-core technology—namely **OpenFn/core** and the various OpenFn
**adaptors**—to create standalone microservices which can be deployed on any
hardware.

This microservice approach helps to ensure that governments and NGOs are never
locked-in to OpenFn's SaaS offering, and can port their existing jobs, triggers,
and credentials from [OpenFn.org](www.openfn.org) to their own infrastructure
easily.

## Up and running:

- Clone this repo with `git clone git@github.com:OpenFn/microservice.git`
- Enter the directory with `cd microservice`
- Install dependencies with `mix deps.get`
- Install Node.js dependencies with `npm install --prefix ./assets`
- Create a `.env` file with `cp .env.example .env`
- Run the tests with `mix test`
- Start your server with `env $(cat .env | grep -v "#" | xargs ) iex -S mix phx.server`

HTTP `post` requests made to
[`localhost:4000/inbox`](http://localhost:4000/inbox) will be processed by the
job runner, accoridng to the `credential`, `expression`, and `adaptor` defined
in your `.env` file.

## Development

### MVP, supported by the DIAL OSC

1. An open source server application (this application, `microservice`.)
2. The open source `inbox` application, which will be used by both `platform`
   and `microservice` to handle HTTP requests
3. The open source `dispatcher` application which will be used by both
   `platform` and `microservice` to execute jobs using `OpenFn/core`.
4. A Dockerfile that, given a `job`, an `adaptor`, and a `credential`, is able
   to automatically generate a container that runs the microservice for that
   job.

### Roadmap for this application

- [x] `mix phx.server` receives receipts and sends 200
- [ ] Chain jobs together
- [ ] Timer jobs can keep state
- [ ] `tmp` files are deleted after job is run
- [ ] bring `core` out of package.json
- [ ] endpoint gets `URL` and `PORT` from `.env`
- [x] `ShellWorker` picks up config from `.env`
- [x] `ShellWorker` executes it, given preloaded job, cred, adaptor, and core.
- [ ] `ShellWorker` can pipe to stdout.
- [ ] Write tests for everything.

#### Dynamic Configuration required for MVP

##### Container Config (Dockerfile)

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

##### Application Config

See [.env.example](./.env.example) for a possible config.

```sh
# basic application config
webserver=true # not necessary if we're not saving final state
url='some.thing.nice'
port='4000'

# service configuration
EXPRESSION_PATH='./job/expression.js'
CREDENTIAL_PATH='./job/credential.json'
CRON_EXPRESSION= # (only provided for a timer job)

FINAL_STATE_PATH= # if we're saving final state.

ADAPTOR_PATH='./assets/node_modules/language-http/lib/Adaptor'
NODE_JS_PATH='./assets/node_modules/.bin'
```

### How to make it shelf ready?

1. Build and relaese a fully featured documentation site like
   [OpenFn/docs](https://openfn.github.io/docs/)
2. Make fully `InstantHIE` compliant (including `kubernetes.yaml`)
3. Build out `openfn-devtools` to include a script that pulls and configures
   `microservice` based one the current configuration of jobs and credentials in
   `devtools`.
4. Click a button on OpenFn to prepare a `microservice.zip` which is this repo
   with a new Dockerfile, based on the current job's configuration at OpenFn.org
   (we're not just "shelf ready", we're _providing the shelf_ with a "free
   forever" project on our website.)
5. An open-source jobs library.

### Jobs Library

1. All jobs that "opt-in" on OpenFn.org are exposed with an open API, which
   **expects** `{adaptor, version, ...helperFunction}` and **returns** `[ { expression: 'createTEI({})', active: true, runsLast90: 32178, successRateLast90: 0.973 , source: 'openfn.org' }, { ...job, source: 'openfn/docs' }, ... ]` — which includes both the jobs in the OpenFn.org
   database _and_ the jobs in
   [OpenFn/Docs/jobs](https://www.github.com/openfn/docs/jobs)
2. That API is consumed by the docs site (open source) _AND_ by openfn.org so
   that it can use used to generate jobs with our free-forever projects.
3. In the IDE on OpenFn.org, a user clicks DHIS2, then `createTEI` and it
   suggests that you look at the top 10 most `successful/active`
   dhis2:your-version expressions, searchable and copy/pastable.
4. New jobs are automatically added to the library from OpenFn.org, and
   open-source users can submit pull requests to post their jobs to the
   `OpenFn/docs/` repo. (OpenFn/docs is open source also, btw.)

### Future nice to haves

- Notifications module
- Better Logging
- Visual interface for application (Phx LiveView?)
- ~~Message persistence plugin (enables retries)~~
