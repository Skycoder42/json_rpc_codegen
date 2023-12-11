// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stream_tests.dart';

// **************************************************************************
// JsonRpcGenerator
// **************************************************************************

// ignore_for_file: type=lint, unused_element

mixin StreamTestsClientMixin on PeerBase {
  var _$streamIdCounter = 0;

  final _$streamControllers = <int, StreamController>{};

  Stream<int> simple() {
    final $streamId = _$streamIdCounter++;
    return (_$streamControllers[$streamId] = StreamController<int>(
      onListen: () async {
        try {
          await jsonRpcInstance.sendRequest(
            'simple#listen',
            <dynamic>[$streamId],
          );
        } catch ($error, $stackTrace) {
          final $controller = _$streamControllers.remove($streamId);
          if ($controller != null) {
            $controller
              ..addError(
                $error,
                $stackTrace,
              )
              ..close();
          } else {
            rethrow;
          }
        }
      },
      onCancel: () => Future.wait([
        if (!jsonRpcInstance.isClosed)
          jsonRpcInstance.sendRequest(
            'simple#cancel',
            [$streamId],
          ),
        if (_$streamControllers.remove($streamId)
            case final StreamController $controller)
          $controller.close(),
      ]),
      onPause: () => jsonRpcInstance.sendNotification(
        'simple#pause',
        [$streamId],
      ),
      onResume: () => jsonRpcInstance.sendNotification(
        'simple#resume',
        [$streamId],
      ),
    ))
        .stream;
  }

  Stream<String> positionalServer(
    String variant,
    User user, [
    List<int>? levels,
    Permission? permission,
    Uri? reference,
    Color? color,
  ]) {
    if (levels == null &&
        (permission != null || reference != null || color != null)) {
      throw ArgumentError(
        'Cannot set optional value to null if any of the following parameters (color, reference, permission) are not null.',
        'levels',
      );
    }
    if (permission == null && (reference != null || color != null)) {
      throw ArgumentError(
        'Cannot set optional value to null if any of the following parameters (color, reference) are not null.',
        'permission',
      );
    }
    if (reference == null && (color != null)) {
      throw ArgumentError(
        'Cannot set optional value to null if any of the following parameters (color) are not null.',
        'reference',
      );
    }
    final $streamId = _$streamIdCounter++;
    return (_$streamControllers[$streamId] = StreamController<String>(
      onListen: () async {
        try {
          await jsonRpcInstance.sendRequest(
            'positionalServer#listen',
            <dynamic>[
              $streamId,
              variant,
              user,
              if (levels != null) levels,
              if (permission != null) permission.name,
              if (reference != null) reference.toString(),
              if (color != null) color,
            ],
          );
        } catch ($error, $stackTrace) {
          final $controller = _$streamControllers.remove($streamId);
          if ($controller != null) {
            $controller
              ..addError(
                $error,
                $stackTrace,
              )
              ..close();
          } else {
            rethrow;
          }
        }
      },
      onCancel: () => Future.wait([
        if (!jsonRpcInstance.isClosed)
          jsonRpcInstance.sendRequest(
            'positionalServer#cancel',
            [$streamId],
          ),
        if (_$streamControllers.remove($streamId)
            case final StreamController $controller)
          $controller.close(),
      ]),
      onPause: () => jsonRpcInstance.sendNotification(
        'positionalServer#pause',
        [$streamId],
      ),
      onResume: () => jsonRpcInstance.sendNotification(
        'positionalServer#resume',
        [$streamId],
      ),
    ))
        .stream;
  }

  @override
  @visibleForOverriding
  @mustCallSuper
  void registerMethods() {
    super.registerMethods();
    jsonRpcInstance.registerMethod(
      'simple#data',
      (Parameters $params) =>
          (_$streamControllers[$params[0].asInt] as StreamController<int>?)
              ?.add(($params[1].value as int)),
    );
    jsonRpcInstance.registerMethod(
      'simple#error',
      (Parameters $params) {
        final $error = ($params[1].asMap as Map<String, dynamic>);
        _$streamControllers[$params[0].asInt]?.addError(RpcException(
          ($error['code'] as int),
          ($error['message'] as String),
          data: ($error['data'] as Object?),
        ));
      },
    );
    jsonRpcInstance.registerMethod(
      'simple#done',
      (Parameters $params) =>
          _$streamControllers.remove($params[0].asInt)?.close(),
    );
    jsonRpcInstance.registerMethod(
      'positionalServer#data',
      (Parameters $params) =>
          (_$streamControllers[$params[0].asInt] as StreamController<String>?)
              ?.add(($params[1].value as String)),
    );
    jsonRpcInstance.registerMethod(
      'positionalServer#error',
      (Parameters $params) {
        final $error = ($params[1].asMap as Map<String, dynamic>);
        _$streamControllers[$params[0].asInt]?.addError(RpcException(
          ($error['code'] as int),
          ($error['message'] as String),
          data: ($error['data'] as Object?),
        ));
      },
    );
    jsonRpcInstance.registerMethod(
      'positionalServer#done',
      (Parameters $params) =>
          _$streamControllers.remove($params[0].asInt)?.close(),
    );
    jsonRpcInstance.done.then((_) {
      for (final $controller in _$streamControllers.values) {
        unawaited($controller.close());
      }
      _$streamControllers.clear();
    });
  }
}
mixin StreamTestsServerMixin on PeerBase {
  final _$streamSubscriptions = <int, StreamSubscription>{};

  @protected
  Stream<int> simple();
  @protected
  Stream<String> positionalServer(
    String variant,
    User user,
    List<int> levels,
    Permission permission,
    Uri? reference,
    Color color,
  );
  @override
  @visibleForOverriding
  @mustCallSuper
  void registerMethods() {
    super.registerMethods();
    jsonRpcInstance.registerMethod(
      'simple#listen',
      (Parameters $params) {
        final $streamId = $params[0].asInt;
        _$streamSubscriptions.update(
          $streamId,
          (_) => throw RpcException(
            jsonRpc2ServerError,
            'streamId ${$streamId} is already in use',
          ),
          ifAbsent: () {
            return simple().listen(
              ($data) => jsonRpcInstance.sendNotification(
                'simple#data',
                <dynamic>[
                  $streamId,
                  $data,
                ],
              ),
              onError: (
                Object $error,
                StackTrace $stackTrace,
              ) =>
                  jsonRpcInstance.sendNotification(
                'simple#error',
                ($error is RpcException
                        ? $error
                        : RpcException(
                            jsonRpc2ServerError,
                            jsonRpc2GetErrorMessage($error),
                            data: {
                              'full': $error.toString(),
                              'stack': Chain.forTrace($stackTrace).toString(),
                            },
                          ))
                    .serialize('simple#${$streamId}')['error'],
              ),
              onDone: () {
                jsonRpcInstance.sendNotification(
                  'simple#done',
                  [$streamId],
                );
                _$streamSubscriptions.remove($streamId)?.cancel();
              },
              cancelOnError: false,
            );
          },
        );
      },
    );
    jsonRpcInstance.registerMethod(
      'simple#cancel',
      (Parameters $params) =>
          _$streamSubscriptions.remove($params[0].asInt)?.cancel(),
    );
    jsonRpcInstance.registerMethod(
      'simple#pause',
      (Parameters $params) => _$streamSubscriptions[$params[0].asInt]?.pause(),
    );
    jsonRpcInstance.registerMethod(
      'simple#resume',
      (Parameters $params) => _$streamSubscriptions[$params[0].asInt]?.resume(),
    );
    jsonRpcInstance.registerMethod(
      'positionalServer#listen',
      (Parameters $params) {
        final $streamId = $params[0].asInt;
        _$streamSubscriptions.update(
          $streamId,
          (_) => throw RpcException(
            jsonRpc2ServerError,
            'streamId ${$streamId} is already in use',
          ),
          ifAbsent: () {
            final $$variant = $params[1].asString;
            final $$user =
                User.fromJson(($params[2].value as Map<String, dynamic>));
            final $$levels = $params[3].$maybeOr(
              ($v) => $v.asList.map((dynamic $e) => ($e as int)).toList(),
              const [5, 75],
            );
            final $$permission = $params[4].$maybeOr(
              ($v) => Permission.values.byName($v.asString),
              Permission.readOnly,
            );
            final $$reference = $params[5].$maybeNullOr(($v) => $v.asUri);
            final $$color = $params[6].$maybeOr(
              ($v) => Color.fromJson(($v.value as String)),
              const Color(255, 255, 255),
            );
            return positionalServer(
              $$variant,
              $$user,
              $$levels,
              $$permission,
              $$reference,
              $$color,
            ).listen(
              ($data) => jsonRpcInstance.sendNotification(
                'positionalServer#data',
                <dynamic>[
                  $streamId,
                  $data,
                ],
              ),
              onError: (
                Object $error,
                StackTrace $stackTrace,
              ) =>
                  jsonRpcInstance.sendNotification(
                'positionalServer#error',
                ($error is RpcException
                        ? $error
                        : RpcException(
                            jsonRpc2ServerError,
                            jsonRpc2GetErrorMessage($error),
                            data: {
                              'full': $error.toString(),
                              'stack': Chain.forTrace($stackTrace).toString(),
                            },
                          ))
                    .serialize('positionalServer#${$streamId}')['error'],
              ),
              onDone: () {
                jsonRpcInstance.sendNotification(
                  'positionalServer#done',
                  [$streamId],
                );
                _$streamSubscriptions.remove($streamId)?.cancel();
              },
              cancelOnError: false,
            );
          },
        );
      },
    );
    jsonRpcInstance.registerMethod(
      'positionalServer#cancel',
      (Parameters $params) =>
          _$streamSubscriptions.remove($params[0].asInt)?.cancel(),
    );
    jsonRpcInstance.registerMethod(
      'positionalServer#pause',
      (Parameters $params) => _$streamSubscriptions[$params[0].asInt]?.pause(),
    );
    jsonRpcInstance.registerMethod(
      'positionalServer#resume',
      (Parameters $params) => _$streamSubscriptions[$params[0].asInt]?.resume(),
    );
    jsonRpcInstance.done.then((_) {
      for (final $subscription in _$streamSubscriptions.values) {
        unawaited($subscription.cancel());
      }
      _$streamSubscriptions.clear();
    });
  }
}

class StreamTestsClient extends PeerBase with StreamTestsClientMixin {
  StreamTestsClient(
    super.channel, {
    super.onUnhandledError,
    super.strictProtocolChecks,
  }) : super();

  StreamTestsClient.withoutJson(
    super.channel, {
    super.onUnhandledError,
    super.strictProtocolChecks,
  }) : super.withoutJson();

  StreamTestsClient.fromPeer(super.jsonRpcInstance) : super.fromPeer();
}

abstract class StreamTestsServer extends PeerBase with StreamTestsServerMixin {
  StreamTestsServer(
    super.channel, {
    super.onUnhandledError,
    super.strictProtocolChecks,
  }) : super();

  StreamTestsServer.withoutJson(
    super.channel, {
    super.onUnhandledError,
    super.strictProtocolChecks,
  }) : super.withoutJson();

  StreamTestsServer.fromPeer(super.jsonRpcInstance) : super.fromPeer();
}

@pragma('vm:prefer-inline')
TConverted _$map<TConverted extends Object, TJson extends Object>(
  TJson $value,
  TConverted Function(TJson) $convert,
) =>
    $convert($value);
@pragma('vm:prefer-inline')
TConverted? _$maybeMap<TConverted extends Object, TJson extends Object>(
  TJson? $value,
  TConverted Function(TJson) $convert,
) =>
    $value == null ? null : $convert($value);

extension _$JsonRpc2ParameterExtensions on Parameter {
  @pragma('vm:prefer-inline')
  T $maybeOr<T>(
    T Function(Parameter) getter,
    T defaultValue,
  ) =>
      exists ? getter(this) : defaultValue;
  @pragma('vm:prefer-inline')
  T? $nullOr<T>(T Function(Parameter) getter) =>
      value != null ? getter(this) : null;
  @pragma('vm:prefer-inline')
  T? $maybeNullOr<T>(T Function(Parameter) getter) =>
      exists && value != null ? getter(this) : null;
}
