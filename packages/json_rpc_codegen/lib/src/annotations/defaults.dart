// coverage:ignore-file

import 'package:meta/meta_meta.dart';

/// Configures the class or method to apply default values on the server side.
///
/// This is the default if nothing else is configured.
@Target({.classType, .method})
class ServerDefaults {
  /// Default constructor.
  const new();
}

/// Configures the class or method to apply default values on the server side.
///
/// This is the default if nothing else is configured.
const serverDefaults = ServerDefaults();

/// Configures the class or method to apply default values on the client side.
@Target({.classType, .method})
class ClientDefaults {
  /// Default constructor.
  const new();
}

/// Configures the class or method to apply default values on the client side.
const clientDefaults = ClientDefaults();
