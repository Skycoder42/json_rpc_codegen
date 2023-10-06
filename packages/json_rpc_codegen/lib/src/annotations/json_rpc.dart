import 'package:meta/meta_meta.dart';

/// Build annotation for JSON-RPC enabled interfaces
@Target({TargetKind.classType})
class JsonRpc {
  /// Build the code for an JSON-RPC client
  final bool client;

  /// Build the code for an JSON-RPC server
  final bool server;

  /// Only generate the mixin, not the client/server wrappers
  final bool mixinsOnly;

  /// Default constructor.
  const JsonRpc({
    this.client = true,
    this.server = true,
    this.mixinsOnly = false,
  });
}

/// Build annotation for JSON-RPC enabled interfaces
@Target({TargetKind.classType})
const jsonRpc = JsonRpc();

/// Build annotation for JSON-RPC enabled interfaces (mixins only)
@Target({TargetKind.classType})
const jsonRpcMixins = JsonRpc(mixinsOnly: true);
