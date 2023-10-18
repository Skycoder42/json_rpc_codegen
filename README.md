# json_rpc_codegen
[![CI/CD for json_rpc_codegen](https://github.com/Skycoder42/json_rpc_codegen/actions/workflows/json_rpc_codegen.yml/badge.svg)](https://github.com/Skycoder42/json_rpc_codegen/actions/workflows/json_rpc_codegen.yml)
[![CI/CD for json_rpc_codegen_builder](https://github.com/Skycoder42/json_rpc_codegen/actions/workflows/json_rpc_codegen_builder.yml/badge.svg)](https://github.com/Skycoder42/json_rpc_codegen/actions/workflows/json_rpc_codegen_builder.yml)
[![Pub Version](https://img.shields.io/pub/v/json_rpc_codegen)](https://pub.dev/packages/json_rpc_codegen)
[![Pub Version](https://img.shields.io/pub/v/json_rpc_codegen_builder)](https://pub.dev/packages/json_rpc_codegen_builder)

A dart code generator that generates typed client and server code for the json_rpc_2 package.

## Table of Contents

## Features
- Code generator for the [json_rpc_2](https://pub.dev/packages/json_rpc_2) package (The official JSON-RPC 2.0
implementation for dart)
- Creates Client and Server classes, as well as Mixins
  - You can directly use the Client/Server classes for simple usecases
  - If you need to work with Peers, or if you want to have a single server/client instance that provides/consumes
  multiple definitions, you can creates those by using the base class and the mixins
- Supports all basic dart types and custom JSON serializables as well
  - Can handle primitive types (bool, int, ...)
  - Can handle infinitely nested containes (List, Set, Map, ...)
  - Can handle infinitely nested records
  - Can handle advanced dart types (DateTime, Uri)
  - Can handle custom types via `fromJson` and `toJson` methods
- Methods can define typed named or positional parameters
  - All types supported
  - With server-sided JSON validation
  - Default-Values are supported (Client or Server-Sided)

## Installation
As this is a builder package, you need to also install the annotations and build_runner:

```yaml
dependencies:
  json_rpc_codegen: <latest>

dev_dependencies:
  build_runner: <latest>
  json_rpc_codegen_builder: <latest>
```

## Usage
The API usage is very basic. You create an abstract dart class that describes the interface, and the code generator
will do the rest for you:

```dart
import 'package:json_rpc_codegen/json_rpc_codegen.dart'

part 'my_class.g.dart'

@jsonRpc
abstract class _MyClass {

}
```

## Documentation
