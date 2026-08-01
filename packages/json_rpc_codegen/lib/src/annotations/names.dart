// coverage:ignore-file

import 'package:meta/meta_meta.dart';

/// Overrides the JSON-RPC method name of the annotated method.
///
/// Without this annotation, the dart name of the method is used as is.
@Target({.method})
class MethodName {
  /// The name to use for the method when sending or registering it.
  final String name;

  /// Default constructor.
  const MethodName(this.name);
}

/// Overrides the JSON-RPC parameter name of the annotated parameter.
///
/// Without this annotation, the dart name of the parameter is used as is. Can
/// only be applied to named parameters, as positional parameters are
/// transmitted as a list.
@Target({.parameter})
class ParamName {
  /// The name to use for the parameter when sending or extracting it.
  final String name;

  /// Default constructor.
  const ParamName(this.name);
}
