import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

@internal
abstract base class JsonRpcInstance {
  static const serverError = Reference('JSON_RPC_2_SERVER_ERROR');

  static const ref = Reference('jsonRpcInstance');
  static final sendNotification = ref.property('sendNotification');
  static final sendRequest = ref.property('sendRequest');
  static final registerMethod = ref.property('registerMethod');
  static final isClosed = ref.property('isClosed');

  static const methodParams = Reference(r'$params');
}

abstract base class Globals {
  static const unawaitedRef = Reference('unawaited');
}
