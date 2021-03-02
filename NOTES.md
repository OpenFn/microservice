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
- [x] chain jobs together (replicate OpenFn.org "flow")
- [ ] bring `core` out of package.json
- [ ] `Engine` can pipe to stdout
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
