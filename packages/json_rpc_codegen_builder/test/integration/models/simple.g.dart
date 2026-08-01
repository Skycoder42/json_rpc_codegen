// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simple.dart';

// **************************************************************************
// JsonRpcGenerator
// **************************************************************************

// ignore_for_file: avoid_futureor_void, avoid_positional_boolean_parameters
// ignore_for_file: cascade_invocations, cast_nullable_to_non_nullable
// ignore_for_file: document_ignores, lines_longer_than_80_chars
// ignore_for_file: no_literal_bool_comparisons
// ignore_for_file: prefer_expression_function_bodies, unnecessary_parenthesis
// ignore_for_file: unnecessary_raw_strings, unreachable_from_main
// ignore_for_file: unused_element

mixin SimpleClientMixin on ClientBase implements Simple {
  @override
  void notify(String message, [int level = 10]) =>
      jsonRpcInstance.sendNotification('notify', <dynamic>[message, level]);

  @override
  Future<double> request({
    required int id,
    Category? category,
    String user = 'self',
  }) async {
    final $result = await jsonRpcInstance.sendRequest(
      'request',
      <String, dynamic>{
        r'id': id,
        r'category': ?category?.name,
        if (user != 'self') r'user': user,
      },
    );
    return ($result as double);
  }
}
mixin SimpleServerMixin on ServerBase implements Simple {
  @override
  FutureOr<void> notify(String message, [int level = 10]);
  @override
  @visibleForOverriding
  @mustCallSuper
  void registerMethods() {
    super.registerMethods();
    jsonRpcInstance.registerMethod('notify', (Parameters $params) async {
      final $$message = $params[0].asString;
      final $$level = $params[1].asIntOr(10);
      await notify($$message, $$level);
    });
    jsonRpcInstance.registerMethod('request', (Parameters $params) async {
      final $$id = $params[r'id'].asInt;
      final $$category = $params[r'category'].$nullCheckedOr<Category>(
        ($v) => Category.values.byName($v.asString),
        null,
      );
      final $$user = $params[r'user'].asStringOr('self');
      return await request(id: $$id, category: $$category, user: $$user);
    });
  }
}

class SimpleClient extends ClientBase with SimpleClientMixin {
  SimpleClient(super.channel, {super.idGenerator}) : super();

  SimpleClient.withoutJson(super.channel, {super.idGenerator})
    : super.withoutJson();

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
@pragma('dart2js:tryInline')
@pragma('wasm:prefer-inline')
TConverted _$map<TConverted extends Object, TJson extends Object>(
  TJson $value,
  TConverted Function(TJson) $convert,
) => $convert($value);
@pragma('vm:prefer-inline')
@pragma('dart2js:tryInline')
@pragma('wasm:prefer-inline')
TConverted? _$maybeMap<TConverted extends Object, TJson extends Object>(
  TJson? $value,
  TConverted Function(TJson) $convert,
) => $value == null ? null : $convert($value);

extension _$JsonRpc2ParameterExtensions on Parameter {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @pragma('wasm:prefer-inline')
  T? $nullChecked<T extends Object>(T Function(Parameter) getter) =>
      value != null ? getter(this) : null;

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @pragma('wasm:prefer-inline')
  T? $nullCheckedOr<T extends Object>(
    T Function(Parameter) getter,
    T? defaultValue,
  ) => exists ? $nullChecked(getter) : defaultValue;

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @pragma('wasm:prefer-inline')
  T $existsOr<T>(T Function(Parameter) getter, T defaultValue) =>
      exists ? getter(this) : defaultValue;
}
