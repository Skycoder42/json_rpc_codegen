// coverage:ignore-file

import 'package:meta/meta_meta.dart';

/// Customizes how the annotated method is mapped to JSON-RPC.
///
/// Without this annotation, the dart name of the method is used as is and the
/// result is converted based on it's type.
@Target({.method})
class RpcMethod {
  /// The name to use for the method when sending or registering it.
  ///
  /// If not set, the dart name of the method is used as is.
  final String? name;

  /// A custom function to deserialize the result of the method from JSON.
  ///
  /// Must be a reference to a top level function, a static method or a
  /// constructor that takes a single, positional JSON parameter and returns the
  /// result type of the method. For streams, a single stream element is
  /// converted.
  ///
  /// The function is never invoked with `null` - a nullable result is mapped to
  /// `null` directly.
  final Function? fromJson;

  /// A custom function to serialize the result of the method to JSON.
  ///
  /// Must be a reference to a top level function, a static method or a
  /// constructor that takes the result type of the method as single, positional
  /// parameter and returns it's JSON representation. For streams, a single
  /// stream element is converted.
  ///
  /// The function is never invoked with `null` - a nullable result is mapped to
  /// `null` directly.
  final Function? toJson;

  /// Default constructor.
  const new({this.name, this.fromJson, this.toJson});
}
