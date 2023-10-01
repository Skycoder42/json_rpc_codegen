import 'dart:async';

import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:meta/meta.dart';
import 'package:stream_channel/stream_channel.dart';

import 'client_base.dart';
import 'server_base.dart';

abstract class PeerBase implements ClientBase, ServerBase {
  /// The internally use JSON-RPC peer
  @override
  final Peer jsonRpc;

  /// See [Peer].
  PeerBase(
    StreamChannel<String> channel, {
    ErrorCallback? onUnhandledError,
    bool strictProtocolChecks = true,
  }) : jsonRpc = Peer(
          channel,
          onUnhandledError: onUnhandledError,
          strictProtocolChecks: strictProtocolChecks,
        ) {
    registerMethods();
  }

  /// See [Peer.withoutJson].
  PeerBase.withoutJson(
    StreamChannel channel, {
    ErrorCallback? onUnhandledError,
    bool strictProtocolChecks = true,
  }) : jsonRpc = Peer.withoutJson(
          channel,
          onUnhandledError: onUnhandledError,
          strictProtocolChecks: strictProtocolChecks,
        ) {
    registerMethods();
  }

  /// Creates a new instance from an existing peer.
  PeerBase.fromPeer(this.jsonRpc) {
    registerMethods();
  }

  /// See [Peer.onUnhandledError]
  @override
  ErrorCallback? get onUnhandledError => jsonRpc.onUnhandledError;

  /// See [Peer.strictProtocolChecks]
  @override
  bool get strictProtocolChecks => jsonRpc.strictProtocolChecks;

  /// See [Peer.done]
  @override
  Future<void> get done => jsonRpc.done;

  /// See [Peer.isClosed]
  @override
  bool get isClosed => jsonRpc.isClosed;

  /// See [Peer.listen]
  @override
  Future<void> listen() => jsonRpc.listen();

  /// See [Peer.close]
  @override
  Future<void> close() => jsonRpc.close();

  /// See [Peer.withBatch]
  @override
  void withBatch(FutureOr<void> Function() callback) =>
      jsonRpc.withBatch(callback);

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
    jsonRpc.registerFallback(onUnknownMethod);
  }
}
