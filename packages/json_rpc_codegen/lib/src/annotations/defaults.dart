import 'package:meta/meta_meta.dart';

/// Adds a server side default value to an optional RPC parameter.
@Target({TargetKind.parameter})
class ServerDefault {
  /// The default value. Must be a compile time constant.
  final dynamic value;

  /// Default constructor.
  const ServerDefault(this.value);
}

/// Adds a client side default value to an optional RPC parameter.
@Target({TargetKind.parameter})
class ClientDefault {
  /// The default value. Must be a compile time constant.
  final dynamic value;

  /// Default constructor.
  const ClientDefault(this.value);
}
