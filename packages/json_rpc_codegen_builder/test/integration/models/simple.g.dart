// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simple.dart';

// **************************************************************************
// JsonRpcGenerator
// **************************************************************************

// ignore_for_file: type=lint, unused_element

mixin SimpleClientMixin on ClientBase {
  void notify(
    String message, [
    int level = 10,
  ]) =>
      jsonRpcInstance.sendNotification(
        'notify',
        <dynamic>[
          message,
          level,
        ],
      );
  Future<double> request({
    required int id,
    Category? category,
    String? user,
  }) async {
    final dynamic $result = await jsonRpcInstance.sendRequest(
      'request',
      <String, dynamic>{
        'id': id,
        if (category != null) 'category': category.name,
        if (user != null) 'user': user,
      },
    );
    return ($result as double);
  }
}
mixin SimpleServerMixin on ServerBase {
  @protected
  FutureOr<void> notify(
    String message,
    int level,
  );
  @protected
  FutureOr<double> request(
    int id,
    Category? category,
    String user,
  );
  @override
  @visibleForOverriding
  @mustCallSuper
  void registerMethods() {
    super.registerMethods();
    jsonRpcInstance.registerMethod(
      'notify',
      (Parameters $params) async {
        final $$message = $params[0].asString;
        final $$level = $params[1].asInt;
        await notify(
          $$message,
          $$level,
        );
      },
    );
    jsonRpcInstance.registerMethod(
      'request',
      (Parameters $params) async {
        final $$id = $params['id'].asInt;
        final $$category = $params['category']
            .$maybeNullOr(($v) => Category.values.byName($v.asString));
        final $$user = $params['user'].asStringOr('self');
        return (await request(
          $$id,
          $$category,
          $$user,
        ));
      },
    );
  }
}

class SimpleClient extends ClientBase with SimpleClientMixin {
  SimpleClient(super.channel) : super();

  SimpleClient.withoutJson(super.channel) : super.withoutJson();

  SimpleClient.fromClient(super.jsonRpcInstance) : super.fromClient();
}

abstract class SimpleServer extends ServerBase with SimpleServerMixin {
  SimpleServer(
    super.channel, {
    super.onUnhandledError,
    super.strictProtocolChecks,
  }) : super();

  SimpleServer.withoutJson(
    super.channel, {
    super.onUnhandledError,
    super.strictProtocolChecks,
  }) : super.withoutJson();

  SimpleServer.fromServer(super.jsonRpcInstance) : super.fromServer();
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
