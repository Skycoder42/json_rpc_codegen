import 'dart:async';

import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:meta/meta.dart';
import 'package:stream_channel/stream_channel.dart';

import 'client_base.dart';
import 'server_base.dart';

/// A base class for all generated JSON RPC peers that wraps the [Peer].
abstract class PeerBase implements ClientBase, ServerBase {
  /// The internally use JSON-RPC peer
  @override
  final Peer jsonRpcInstance;

  // coverage:ignore-start
  /// See [Peer].
  new(
    StreamChannel<String> channel, {
    ErrorCallback? onUnhandledError,
    bool strictProtocolChecks = true,
    Object Function()? idGenerator,
  }) : jsonRpcInstance = Peer(
         channel,
         onUnhandledError: onUnhandledError,
         strictProtocolChecks: strictProtocolChecks,
         idGenerator: idGenerator,
       ) {
    registerMethods();
  }

  /// See [Peer.withoutJson].
  new withoutJson(
    StreamChannel<dynamic> channel, {
    ErrorCallback? onUnhandledError,
    bool strictProtocolChecks = true,
    Object Function()? idGenerator,
  }) : jsonRpcInstance = Peer.withoutJson(
         channel,
         onUnhandledError: onUnhandledError,
         strictProtocolChecks: strictProtocolChecks,
         idGenerator: idGenerator,
       ) {
    registerMethods();
  }
  // coverage:ignore-end

  /// Creates a new instance from an existing peer.
  new fromPeer(this.jsonRpcInstance) {
    registerMethods();
  }

  /// See [Peer.onUnhandledError]
  @override
  ErrorCallback? get onUnhandledError => jsonRpcInstance.onUnhandledError;

  /// See [Peer.strictProtocolChecks]
  @override
  bool get strictProtocolChecks => jsonRpcInstance.strictProtocolChecks;

  /// See [Peer.done]
  @override
  Future<void> get done => jsonRpcInstance.done;

  /// See [Peer.isClosed]
  @override
  bool get isClosed => jsonRpcInstance.isClosed;

  /// See [Peer.listen]
  @override
  Future<void> listen() => jsonRpcInstance.listen();

  /// See [Peer.close]
  @override
  Future<void> close() => jsonRpcInstance.close();

  /// See [Peer.withBatch]
  @override
  void withBatch(FutureOr<void> Function() callback) =>
      jsonRpcInstance.withBatch(callback);

  /// Can be overridden to implement custom handling for unknown method calls.
  ///
  /// The default implementation simply throws [RpcException.methodNotFound],
  /// which will report an error back to the client.
  ///
  /// See [Peer.registerFallback].
  @override
  @visibleForOverriding
  FutureOr<dynamic> onUnknownMethod(Parameters params) =>
      throw RpcException.methodNotFound(params.method);

  @override
  @visibleForOverriding
  @mustCallSuper
  void registerMethods() {
    jsonRpcInstance.registerFallback(onUnknownMethod);
  }
}
