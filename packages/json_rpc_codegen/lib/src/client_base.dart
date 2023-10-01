import 'dart:async';

import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:stream_channel/stream_channel.dart';

/// A base class for all generated JSON RPC clients that wraps the [Client]
abstract class ClientBase {
  /// The internally use JSON-RPC client to make the requests to the server
  final Client jsonRpc;

  /// See [Client]
  ClientBase(StreamChannel<String> channel) : jsonRpc = Client(channel);

  /// See [Client.withoutJson]
  ClientBase.withoutJson(StreamChannel channel)
      : jsonRpc = Client.withoutJson(channel);

  /// Creates a new instance from an existing client
  ClientBase.fromClient(this.jsonRpc);

  /// See [Client.done]
  Future<void> get done => jsonRpc.done;

  /// See [Client.isClosed]
  bool get isClosed => jsonRpc.isClosed;

  /// See [Client.listen]
  Future<void> listen() => jsonRpc.listen();

  /// See [Client.close]
  Future<void> close() => jsonRpc.close();

  /// See [Client.withBatch]
  void withBatch(FutureOr<void> Function() callback) =>
      jsonRpc.withBatch(callback);
}
