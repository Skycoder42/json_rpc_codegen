// coverage:ignore-file

import 'package:meta/meta_meta.dart';

/// Configures the class or method to apply default values on the server side.
///
/// This is the default if nothing else is configured.
@Target({TargetKind.classType, TargetKind.method})
class ServerDefaults {
  /// Default constructor.
  const ServerDefaults();
}

/// Configures the class or method to apply default values on the server side.
///
/// This is the default if nothing else is configured.
const serverDefaults = ServerDefaults();

/// Configures the class or method to apply default values on the client side.
@Target({TargetKind.classType, TargetKind.method})
class ClientDefaults {
  /// Default constructor.
  const ClientDefaults();
}

/// Configures the class or method to apply default values on the client side.
const clientDefaults = ServerDefaults();
