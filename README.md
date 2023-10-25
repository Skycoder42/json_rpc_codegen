# json_rpc_codegen
[![CI/CD for json_rpc_codegen](https://github.com/Skycoder42/json_rpc_codegen/actions/workflows/json_rpc_codegen_ci.yaml/badge.svg)](https://github.com/Skycoder42/json_rpc_codegen/actions/workflows/json_rpc_codegen_ci.yaml)
[![CI/CD for json_rpc_codegen_builder](https://github.com/Skycoder42/json_rpc_codegen/actions/workflows/json_rpc_codegen_builder_ci.yaml/badge.svg)](https://github.com/Skycoder42/json_rpc_codegen/actions/workflows/json_rpc_codegen_builder_ci.yaml)
[![json_rpc_codegen pub version](https://img.shields.io/pub/v/json_rpc_codegen?label=pub%20-%20json_rpc_codegen)](https://pub.dev/packages/json_rpc_codegen)
[![json_rpc_codegen_builder pub version](https://img.shields.io/pub/v/json_rpc_codegen_builder?label=pub%20-%20json_rpc_codegen_builder)](https://pub.dev/packages/json_rpc_codegen_builder)

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
import 'package:json_rpc_codegen/json_rpc_codegen.dart';

part 'my_class.g.dart';

enum Stage { all, pre, post }

@jsonRpc
abstract class _MyClass {
  void startServerTask({
    required int id,
    required String taskName,
    bool verbose = false,
    double? scale,
  });

  @clientDefaults
  double getProgress(int id, [Stage stage = Stage.all]);
}
```

This will generate a bunch of code for both, the client and the server implementation. Have a look at the documentation
on how to control which of these classes get generated. By default, the following will be generated:

- `MyClassClientMixin`: A Mixin on the `ClientBase` class that has all the client implementations of the interface
- `MyClassServerMixin`: A Mixin on the `ServerBase` class that has all the server implementations of the interface
- `MyClassClient`: A class that uses the `MyClassClientMixin`, ready for use
- `MyClassServer`: A class that uses the `MyClassServerMixin`, ready for use

In most cases, you will want to use `MyClassClient` and `MyClassServer` directly. However, if you want to combine
multiple interfaces into one, or if you are working with `Peer`s, you may want to use the mixins instead.

Here is a simplified example, of how the generated classes look:

```dart
class MyClassClient {
  void startServerTask({
    required int id,
    required String taskName,
    // all optional parameters are nullable, as the defaults are managed by the server
    bool? verbose,
    double? scale,
  });

  // non-void methods become futures to wait for the result
  Future<double> getProgress(
    int id, [
    // client defaults are set on the client instead
    Stage stage = Stage.all,
  ]);
}

// The server is abstract, as you need to implement the logic of the server methods
abstract class MyClassServer {
  // All server methods use FutureOr and can be synchronous or asynchronous
  @protected
  FutureOr<void> startServerTask(
    int id,
    String taskName,
    // server defaults are set by the implementation
    bool verbose,
    double? scale,
  );

  @protected
  FutureOr<double> getProgress(
    int id,
    // client defaults are required on the server side
    Stage stage,
  );
}
```

To use the client, simply create a new instance, just as you would with the standard `json_rpc_2` client. For the
server, create your own server class that extends the generated server to implement the server methods. Then you can
use this class just like the `json_rpc_2`, but without you having to take care of any registrations.

## Documentation
The documentation is available at https://pub.dev/documentation/json_rpc_codegen/latest/. A full example can be found
at https://pub.dev/packages/json_rpc_codegen_builder/example.
