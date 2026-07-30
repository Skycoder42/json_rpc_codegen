import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

@internal
sealed class Types {
  static TypeReference $FutureOr([Reference? type]) => TypeReference(
    (b) => b
      ..symbol = 'FutureOr'
      ..types.addAll([?type]),
  );

  static TypeReference $StreamController([Reference? type]) => TypeReference(
    (b) => b
      ..symbol = 'StreamController'
      ..types.addAll([?type]),
  );

  static TypeReference $StreamSubscription([Reference? type]) => TypeReference(
    (b) => b
      ..symbol = 'StreamSubscription'
      ..types.addAll([?type]),
  );

  static final $Parameters = TypeReference((b) => b..symbol = 'Parameters');

  static final $Parameter = TypeReference((b) => b..symbol = 'Parameter');

  static final $RpcException = TypeReference((b) => b..symbol = 'RpcException');

  static final $Chain = TypeReference((b) => b..symbol = 'Chain');

  static final $ClientBase = TypeReference((b) => b..symbol = 'ClientBase');

  static final $ServerBase = TypeReference((b) => b..symbol = 'ServerBase');

  static final $PeerBase = TypeReference((b) => b..symbol = 'PeerBase');
}
