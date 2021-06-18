# OpenFn/microservice [![CircleCI](https://circleci.com/gh/OpenFn/microservice.svg?style=svg)](https://circleci.com/gh/OpenFn/microservice)

Supported by [OpenFn](https://www.openfn.org),
[DIAL](https://digitalimpactalliance.org), [UNICEF](https://www.unicef.org), and
with UK aid from the British people.

## [Documentation](https://docs.openfn.org/documentation/microservice/home)

_🔥 The documentation for this project can be found at
[docs.openfn.org](https://docs.openfn.org/documentation/microservice/home). 🔥_

## Docker build

```sh
`docker build -t openfn/microservice:<version> .`
```

## Docker compose or run

Assuming you've got an `.env` and a project directory with a `project.yaml`
spec:

```sh
docker-compose up
```

```sh
docker run -v <path-to-your-project-folder>:/home/microservice/<path-to-your-project-folder> \
  --env-file <path-to-your-env-file> \
  --network host \
  openfn/microservice:<version>
```

## Instant OpenHIE

First ensure you have cloned this repository, then from the
[`instant`](https://github.com/openhie/instant) folder (the folder where you'd
typically run your "Instant OpenHIE commands") run the following command:

```
yarn docker:instant init openfnMicroservice --custom-package="<path to this folder>"
```

Test the deployment by posting messages to port `4001`.

## Development up and running guide

### Installing pre-requisites

- It's recommended to use [`nvm`](https://github.com/nvm-sh/nvm) to install
  NodeJs. At the time of writing, the `platform-app` instance on US servers and
  the dockerized `microservice` instance are running on NodeJs `v12.20.2`.
- It's highly recommended to use [`asdf`](https://github.com/asdf-vm/asdf) for
  managing your Erlang and Elixir versions. After installing `asdf`, install
  Erlang and Elixir.
- `asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git`
- `asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git`
- At the time of writing, we're using `Erlang/OTP 23 [erts-11.1.8]` and
  `Elixir 1.11.3 (compiled with Erlang/OTP 23)`
- Also at the time of writing, we're assuming that logs are ingested by a host
  service so we don't depend on a database!
- Once NodeJs, Erlang and Elixir are installed, proceed to the application
  build/setup section below.

### Application build/setup

- Clone this repo with `git clone git@github.com:OpenFn/microservice.git`
- Enter the directory with `cd microservice`
- Install dependencies with `mix setup`
- Run the tests with `mix test`
- Make a project directory to hold your project artifacts with
  `mkdir sample-project`
- Create a new project specification with
  `cp project.yaml.example ./sample-project/project.yaml`
- Create a `.env` file with `cp .env.example .env`
- Install necessary adaptors via
  `npm install @openfn/language-http --prefix priv/openfn/runtime/node_modules --no-save --no-package-lock --global-style`
- Start your microservice server with
  `env $(cat .env | grep -v "#" | xargs ) iex -S mix phx.server`
