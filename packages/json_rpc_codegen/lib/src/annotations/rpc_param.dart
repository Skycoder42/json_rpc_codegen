// coverage:ignore-file

import 'package:meta/meta_meta.dart';

/// Customizes how the annotated parameter is mapped to JSON-RPC.
///
/// Without this annotation, the dart name of the parameter is used as is and
/// the value is converted based on it's type.
@Target({.parameter})
class RpcParam {
  /// The name to use for the parameter when sending or extracting it.
  ///
  /// If not set, the dart name of the parameter is used as is. Can only be set
  /// for named parameters, as positional parameters are transmitted as a list.
  final String? name;

  /// A custom function to deserialize the parameter from JSON.
  ///
  /// Must be a reference to a top level function, a static method or a
  /// constructor that takes a single, positional JSON parameter and returns the
  /// type of the parameter.
  ///
  /// The function is never invoked with `null` - a nullable parameter is mapped
  /// to `null` directly.
  final Function? fromJson;

  /// A custom function to serialize the parameter to JSON.
  ///
  /// Must be a reference to a top level function, a static method or a
  /// constructor that takes the type of the parameter as single, positional
  /// parameter and returns it's JSON representation.
  ///
  /// The function is never invoked with `null` - a nullable parameter is mapped
  /// to `null` directly.
  final Function? toJson;

  /// Default constructor.
  const RpcParam({this.name, this.fromJson, this.toJson});
}
