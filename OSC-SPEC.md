# Specifications for the UNICEF/OSC project

1. An open source server application (this application, `microservice`.)
2. The open source `inbox` application (which could be used by both `platform`
   and `microservice`) to handle HTTP requests
3. The open source `dispatcher` application (which could be used by both
   `platform` and `microservice`) to execute jobs using `OpenFn/core`.
4. A Dockerfile that, given a `job`, an `adaptor`, and a `credential`, is able
   to automatically generate a container that runs the microservice for that
   job.

## (1) Development of a web server

- [x] Using an existing open-source framework we will create a basic, secure
      REST API.
- [x] The REST API will be able to receive an authenticated HTTP POST request
      with a valid JSON body, respond with a 202/Accepted, and pass that body to a
      handler.

## (2) Development of a handler (or a job-runner)

- [x] When called with a JSON body, the handler will prepare an initial “state”
      which includes the relevant credential and the data provided by the REST API
      and call OpenFn/core/lib/cli.js with the following arguments: (1) the job to
      execute, (2) the state, (3) the language-package to utilize, and (4) the
      desired output path to write the logs.

## (3) Containerization of the microservice

- [x] Once developed, this microsevice will be containerized using a technology
      like Docker, such that it could be quickly and easily deployed, alongside many
      others like it, on virtually any server.

## (4) Deployment & administrative features

- [x] The containerized microservice could be deployed to servers, ideally
      cloud-hosted, which provide users with as much out-of-the-box monitoring,
      logging, administration, and introspective abilities as possible.
- [x] Developers may choose to deploy with jobs, credentials, and triggers
      built-in to the container, or may choose to pass them in as environment
      variables.
