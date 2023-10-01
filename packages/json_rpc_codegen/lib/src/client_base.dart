import 'dart:async';

import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:stream_channel/stream_channel.dart';

/// A base class for all generated JSON RPC clients that wraps the [Client]
abstract class ClientBase {
  /// The internally use JSON-RPC client to make the requests to the server
  final Client jsonRpcInstance;

  /// See [Client]
  ClientBase(StreamChannel<String> channel) : jsonRpcInstance = Client(channel);

  /// See [Client.withoutJson]
  ClientBase.withoutJson(StreamChannel channel)
      : jsonRpcInstance = Client.withoutJson(channel);

  /// Creates a new instance from an existing client
  ClientBase.fromClient(this.jsonRpcInstance);

  /// See [Client.done]
  Future<void> get done => jsonRpcInstance.done;

  /// See [Client.isClosed]
  bool get isClosed => jsonRpcInstance.isClosed;

  /// See [Client.listen]
  Future<void> listen() => jsonRpcInstance.listen();

  /// See [Client.close]
  Future<void> close() => jsonRpcInstance.close();

  /// See [Client.withBatch]
  void withBatch(FutureOr<void> Function() callback) =>
      jsonRpcInstance.withBatch(callback);
}
