import 'dart:async';

import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:meta/meta.dart';
import 'package:stream_channel/stream_channel.dart';

/// A base class for all generated JSON RPC servers that wraps the [Server].
abstract class ServerBase {
  /// The internally use JSON-RPC server to handle requests to the server.
  final Server jsonRpc;

  /// See [Server].
  ServerBase(
    StreamChannel<String> channel, {
    ErrorCallback? onUnhandledError,
    bool strictProtocolChecks = true,
  }) : jsonRpc = Server(
          channel,
          onUnhandledError: onUnhandledError,
          strictProtocolChecks: strictProtocolChecks,
        ) {
    registerMethods();
  }

  /// See [Server.withoutJson].
  ServerBase.withoutJson(
    StreamChannel channel, {
    ErrorCallback? onUnhandledError,
    bool strictProtocolChecks = true,
  }) : jsonRpc = Server.withoutJson(
          channel,
          onUnhandledError: onUnhandledError,
          strictProtocolChecks: strictProtocolChecks,
        ) {
    registerMethods();
  }

  /// Creates a new instance from an existing server.
  ServerBase.fromServer(this.jsonRpc) {
    registerMethods();
  }

  /// See [Server.onUnhandledError].
  ErrorCallback? get onUnhandledError => jsonRpc.onUnhandledError;

  /// See [Server.strictProtocolChecks].
  bool get strictProtocolChecks => jsonRpc.strictProtocolChecks;

  /// See [Server.done].
  Future<void> get done => jsonRpc.done;

  /// See [Server.isClosed].
  bool get isClosed => jsonRpc.isClosed;

  /// See [Server.listen].
  Future<void> listen() => jsonRpc.listen();

  /// See [Server.close].
  Future<void> close() => jsonRpc.close();

  /// Can be overridden to implement custom handling for unknown method calls.
  ///
  /// The default implementation simply throws [RpcException.methodNotFound],
  /// which will report an error back to the client.
  ///
  /// See [Server.registerFallback].
  @visibleForOverriding
  FutureOr<dynamic> onUnknownMethod(Parameters params) =>
      throw RpcException.methodNotFound(params.method);

  /// Internal helper method to register server methods.
  ///
  /// You should not invoke this method yourself.
  @visibleForOverriding
  @mustCallSuper
  void registerMethods() {
    jsonRpc.registerFallback(onUnknownMethod);
  }
}
