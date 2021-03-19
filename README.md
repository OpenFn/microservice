# OpenFn/microservice [![CircleCI](https://circleci.com/gh/OpenFn/microservice.svg?style=svg)](https://circleci.com/gh/OpenFn/microservice)

Supported by [OpenFn](https://www.openfn.org),
[DIAL](https://digitalimpactalliance.org), and [UNICEF](https://www.unicef.org)

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

## Development up and running guide

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
