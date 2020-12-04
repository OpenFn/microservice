# OpenFn/microservice [![CircleCI](https://circleci.com/gh/OpenFn/microservice.svg?style=svg)](https://circleci.com/gh/OpenFn/microservice)

[![openfn](assets/logo.png)](https://www.openfn.org)
[![unicef](https://raw.githubusercontent.com/OpenFn/microservice/master/assets/unicef.png)](https://digitalimpactalliance.org)
[![dial](https://raw.githubusercontent.com/OpenFn/microservice/master/assets/dial.png)](https://www.unicef.org)

## Intent

OpenFn is used by numerous health and humanitarian organizations around the
world to scale their programs through real-time interoperability, systems
integration, and workflow automation. **OpenFn/microservice** makes use of
OpenFn's open-core technology—namely **OpenFn/core** and the various OpenFn
**adaptors**—to create standalone microservices which can be deployed on any
hardware.

This microservice approach helps to ensure that governments and NGOs are never
locked-in to OpenFn's SaaS offering, and can port their existing jobs, triggers,
and credentials from [OpenFn.org](www.openfn.org) to their own infrastructure
easily.

Learn more about the open-source OpenFn/devtools: https://openfn.github.io/devtools/

## Docker usage

- `git clone git@github.com:OpenFn/microservice.git && cd microservice` to clone
- `docker build -t openfn/microservice:v0.2.1 .` to build
- `cp .env.example .env` to configure
- `docker run --network host --env-file ./.env openfn/microservice:v0.2.1` to run

## Development up and running guide

- Clone this repo with `git clone git@github.com:OpenFn/microservice.git`
- Enter the directory with `cd microservice`
- Install dependencies with `mix deps.get`
- Install Node.js dependencies with `npm install --prefix ./assets`
- Run the tests with `mix test`
- Create a `.env` file with `cp .env.example .env`
- Start your server with `env $(cat .env | grep -v "#" | xargs ) iex -S mix phx.server`

HTTP `post` requests made to
[`localhost:4000/inbox`](http://localhost:4000/inbox) will be processed by the
`Receiver |> Dispatcher`, according to the `credential`, `expression`, and
`adaptor` defined in your `.env` file.

Time-based jobs will be run by `Repeater |> Dispatcher` according to the
`credential`, `expression`, and `adaptor` defined in your `.env` file.

## Development

This is a rough draft. Note that we're using the BEAM here because we see this
growing significantly and want to leverage inter-node communication on large
deployments, among other things. We may also fork and go another direction,
using nothing but a small Express server (dropping Elixir/Erlang entirely) to
call OpenFn/core (with a directly Javascript interface, rather than the CLI).
Ideas, suggestions, questions welcome.

### Potential roadmap for this application

- [x] `mix phx.server` receives receipts and sends 201/202
- [x] timer jobs can keep state (via `Repeater` and a simple `GenServer`)
- [x] endpoint gets `URL` and `PORT` from `.env`
- [x] `Dispatcher` picks up config from `.env`
- [x] `Dispatcher` executes it, given preloaded job, cred, adaptor, and core
- [x] write tests for everything
- [x] dashboard for visual performance monitoring
- [ ] pass project artifacts during `docker run`
- [ ] `tmp` files are deleted after job is run
- [ ] chain jobs together (replicate OpenFn.org "flow")
- [ ] bring `core` out of package.json
- [ ] `Dispatcher` can pipe to stdout
- [ ] notifications module
- [ ] better Logging
- [ ] visual interface for application (Phx LiveView?)
- [ ] message persistence plugin (enables retries)

### Dynamic Configuration required for MVP

- See [/project](https://github.com/OpenFn/microservice/blob/master/project) for
  project artifacts
- See
  [.env.example](https://github.com/OpenFn/microservice/blob/master/.env.example)
  for a possible configuration
- See
  [Dockerfile](https://github.com/OpenFn/microservice/blob/master/Dockerfile) to
  build a microservice

### How to make it shelf ready

1. Build a fully featured documentation site like
   [OpenFn/docs](https://docs.openfn.org)
2. Make fully `Instant OpenHIE` compliant (including `kubernetes.yaml`)
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
   **expects** `{adaptor, version, ...helperFunction}` and **returns** the
   following—which includes both the jobs in the OpenFn.org database _and_ the
   jobs in [OpenFn/Docs/jobs](https://www.github.com/openfn/docs/jobs):

```json
[
  {
    "expression": "createTEI({})",
    "active": true,
    "runsLast90": 32178,
    "successRateLast90": 0.973,
    "source": "openfn.org"
  },
  {
    ...job,
    "source": "openfn/docs"
  }
]
```

2. That API is consumed by the docs site (open source) _AND_ by openfn.org so
   that it can use used to generate jobs with our free-forever projects.
3. In the IDE on OpenFn.org, a user clicks DHIS2, then `createTEI` and it
   suggests that you look at the top 10 most `successful/active`
   dhis2:your-version expressions, searchable and copy/pastable.
4. New jobs are automatically added to the library from OpenFn.org, and
   open-source users can submit pull requests to post their jobs to the
   `OpenFn/docs/` repo. (OpenFn/docs is open source also, btw.)
