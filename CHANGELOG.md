# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2021-02-26

### Added

- Multiple jobs per instance
- Flow jobs run on success or failure triggers
- Credential configuration via YAML

### Changed

- Projects are now configured via `YAML`, rather than `.env` files for greater
  flexibility. See updated README.

### Removed

- Removed `Microservice.Repeater`, cron is now handled by
  [OpenFn/engine](https://github.com/openfn/engine)

## [0.2.1] - 2020-12-04

### Added

- An `env` based prototype that would run an OpenFn job via cron or trigger an
  OpenFn job via web request.
