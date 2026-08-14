# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 2.1.1 - 2026-08-14
### Changed
- Updated min sdk version to ^3.13.0
- Updated dependencies

## 2.1.0 - 2026-08-01
### Added
- Support the `@RpcMethod` and `@RpcParam` annotations to customize the JSON-RPC
mapping of generated methods and parameters
  - `name` overrides the transmitted name of a method or named parameter
  - `fromJson` and `toJson` override how a parameter, method result or stream
  element is converted

## 2.0.0 - 2026-07-30
### Changed
- Rework the library with a new interface

## 1.0.0 - 2023-10-25
### Added
- Initial release
