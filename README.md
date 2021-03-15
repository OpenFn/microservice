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

## Prerequisites

Familiarity with other elements of OpenFn's open source integration toolkit is
helpful:

- [OpenFn/docs](https://docs.openfn.org)
- [OpenFn/core](https://github.com/openFn/core)
- [OpenFn/engine](https://github.com/openFn/engine)
- [OpenFn/devtools](https://openfn.github.io/devtools/)

## Docker run

Assuming you've got an `.env` and a project directory with a `project.yaml`
spec:

```sh
docker run -v <path-to-your-project-folder>:/home/microservice/<path-to-your-project-folder> \
  --env-file <path-to-your-env-file> \
  --network host \
  openfn/microservice:v0.3.1
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

### Up and running inside Docker

- Build a docker image with `docker build -t openfn/microservice:v0.3.0 .`
- Run with the [docker run command](#Docker-run)

## Project configuration

You can configure the jobs, triggers, credentials and language packs used in
your microservice in the `project.yaml` config file.

### First setup using the sample config

The
[sample project configuration file](https://github.com/OpenFn/microservice/blob/main/project.yaml.example)
describes an example project setup to help you get acquainted with this
structure.

By default microservice is configured with 4 sample jobs:

1. `job-1` is triggered when a matching message arrives to the inbox (see
   `trigger-1`).
2. `recurring-job` is a timed job scheduled to run every minute and is linked to
   the `every-minute` cron trigger.
3. `flow-job` and `catch-job` run after the `success` and `failure` of job-1,
   respectively.

All of the jobs are configured with the language pack `openfn/language-common`.

In the default sample configuration a new message posted to
`localhost:4000/inbox` that matches `trigger-1` (i.e. the message contains
`"number":2`) is greeted with an asynchronous acknowledgement receipt
(`HTTP 202` `Data accepted and processing has begun`) and will trigger `job-1`
to run.

You can try this out with the following snippet:

```sh
curl -X POST -H "Content-Type: application/json" \
 -d '{
  "number":2,
  "surveyId": 37479
}' \
 http://localhost:4000/inbox
```

Posting a message not matching any of the triggers (e.g. `“number”:3`) equally
prompts an acknowledgement but doesn’t trigger any jobs.

Example message post for this non-match scenario:

```sh
curl -X POST -H "Content-Type: application/json" \
 -d '{
  "number":3,
  "surveyId": 37479
}' \
 http://localhost:4000/inbox
```

HTTP `post` requests made to
[`localhost:4000/inbox`](http://localhost:4000/inbox) will be processed by the
`Receiver`, according to the `credential`, `expression`, and `adaptor` defined
in the project configuration `YAML` file.

Time-based jobs will be run by `Engine` according to the `credential`,
`expression`, and `adaptor` defined in your `project.yaml` file.

### Setup from your existing OpenFn platform project

If you have a project configured on OpenFn, you have two ways for exporting your
config on the project settings page and running your project in microservice.

1. If you export as `project.yaml`, you'll get a email with a link to your
   encrypted settings in `yaml` format that you can into your environment as set
   up using the Development Up and Running Guide above.

2. If you export as `microservice.zip`, you'll get your project folder ready to
   run with `docker`, containing

- your `project.yaml`
- `.env` file with the default environment variables for docker
- a `Readme` file

`cd` into the folder and run the project with `docker-compose up`. If you don't have the docker
image, it will be auto-pulled from `hub.docker.com`.
