import 'package:meta/meta_meta.dart';

/// Build annotation for JSON-RPC enabled interfaces
@Target({TargetKind.classType})
class JsonRpc {
  /// Default constructor.
  const JsonRpc();
}

/// Build annotation for JSON-RPC enabled interfaces
@Target({TargetKind.classType})
const jsonRpc = JsonRpc();
