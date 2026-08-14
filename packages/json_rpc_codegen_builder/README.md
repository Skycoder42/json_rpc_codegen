# json_rpc_codegen
[![CI/CD for json_rpc_codegen_builder](https://github.com/Skycoder42/json_rpc_codegen/actions/workflows/json_rpc_codegen_builder_ci.yaml/badge.svg)](https://github.com/Skycoder42/json_rpc_codegen/actions/workflows/json_rpc_codegen_builder_ci.yaml)
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
  - Can handle infinitely nested containers (List, Set, Map, ...)
    - Map keys must be non nullable `String`s, as JSON objects can only have string keys
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
The API usage is very basic. You create an abstract interface class that describes the interface, and the code
generator will do the rest for you:

```dart
import 'package:json_rpc_codegen/json_rpc_codegen.dart';

part 'my_class.g.dart';

enum Stage { all, pre, post }

@jsonRpc
abstract interface class MyClass {
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

### Customizing methods and parameters
By default, the dart names of methods and parameters are used as is for the JSON-RPC method and parameter names, and
values are converted based on their type. Both can be overridden with the `@RpcMethod` and `@RpcParam` annotations. All
of their properties are optional - without them, nothing changes.

#### Renaming
If the remote uses a naming scheme that cannot be expressed in dart, set the `name`:

```dart
@jsonRpc
abstract interface class MyClass {
  @RpcMethod(name: 'dart-foo')
  void dartFoo({@RpcParam(name: 'dart:bar') required int dartBar});
}
```

Calling `dartFoo(dartBar: 42)` will send `{"method": "dart-foo", "params": {"dart:bar": 42}}`, and the generated server
registers and reads the same names.

The `name` of `@RpcParam` can only be set on named parameters, as positional parameters are transmitted as a list and
therefore have no names on the wire.

#### Custom conversion
If a type cannot be converted automatically, or the remote expects a different representation than the default
conversion produces, set `fromJson` and `toJson`. On `@RpcParam` they convert the parameter, on `@RpcMethod` the result
of the method - or, for streams, a single stream element:

```dart
List<int> colorToRgb(Color color) => [color.r, color.g, color.b];

Color colorFromRgb(List<dynamic> json) =>
    Color(json[0] as int, json[1] as int, json[2] as int);

@jsonRpc
abstract interface class MyClass {
  @RpcMethod(fromJson: colorFromRgb, toJson: colorToRgb)
  Future<Color> blend(
    @RpcParam(fromJson: colorFromRgb, toJson: colorToRgb) Color color,
  );
}
```

Both are independent - if only one is set, the other direction keeps using the default conversion. They can be set on
positional parameters as well and also work for types that are handled natively, like `double` or `DateTime`.

A few rules apply to the referenced functions:

- They must be a reference to a top level function, a static method or a constructor - not a closure. Each must take
  at least one required, positional parameter and only optional parameters after that.
- They must be visible from the annotated library, as the generated code is a `part` of it.
- They are never invoked with `null`. A nullable value is mapped to `null` directly, so a converter for a `Color?` is
  still written as `Color Function(List<dynamic>)`.
- They replace the conversion of the whole value. For a `List<Color>`, the converter receives the entire list, not the
  individual colors.

## Documentation
The documentation is available at https://pub.dev/documentation/json_rpc_codegen/latest/. A full example can be found
at https://pub.dev/packages/json_rpc_codegen_builder/example.
