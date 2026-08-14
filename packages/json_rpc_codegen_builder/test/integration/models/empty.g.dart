// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'empty.dart';

// **************************************************************************
// JsonRpcGenerator
// **************************************************************************

// ignore_for_file: async_return_with_no_await, avoid_futureor_void
// ignore_for_file: avoid_positional_boolean_parameters, cascade_invocations
// ignore_for_file: cast_nullable_to_non_nullable, document_ignores
// ignore_for_file: empty_container_bodies, lines_longer_than_80_chars
// ignore_for_file: no_literal_bool_comparisons
// ignore_for_file: prefer_expression_function_bodies, unnecessary_parenthesis
// ignore_for_file: unnecessary_raw_strings
// ignore_for_file: unnecessary_type_name_in_constructor, unreachable_from_main
// ignore_for_file: unused_element

mixin TestEmpty1ClientMixin on ClientBase implements TestEmpty1 {}

mixin TestEmpty1ServerMixin on ServerBase implements TestEmpty1 {
  @override
  @visibleForOverriding
  @mustCallSuper
  void registerMethods() {
    super.registerMethods();
  }
}

class TestEmpty1Client extends ClientBase with TestEmpty1ClientMixin {
  TestEmpty1Client(super.channel, {super.idGenerator}) : super();

  TestEmpty1Client.withoutJson(super.channel, {super.idGenerator})
    : super.withoutJson();

  TestEmpty1Client.fromClient(super.jsonRpcInstance) : super.fromClient();
}

abstract class TestEmpty1Server extends ServerBase with TestEmpty1ServerMixin {
  TestEmpty1Server(
    super.channel, {
    super.onUnhandledError,
    super.strictProtocolChecks,
  }) : super();

  TestEmpty1Server.withoutJson(
    super.channel, {
    super.onUnhandledError,
    super.strictProtocolChecks,
  }) : super.withoutJson();

  TestEmpty1Server.fromServer(super.jsonRpcInstance) : super.fromServer();
}

mixin TestEmpty2ClientMixin on ClientBase implements TestEmpty2 {}

mixin TestEmpty2ServerMixin on ServerBase implements TestEmpty2 {
  @override
  @visibleForOverriding
  @mustCallSuper
  void registerMethods() {
    super.registerMethods();
  }
}

mixin TestEmpty5ServerMixin on ServerBase implements TestEmpty5 {
  @override
  @visibleForOverriding
  @mustCallSuper
  void registerMethods() {
    super.registerMethods();
  }
}

abstract class TestEmpty5Server extends ServerBase with TestEmpty5ServerMixin {
  TestEmpty5Server(
    super.channel, {
    super.onUnhandledError,
    super.strictProtocolChecks,
  }) : super();

  TestEmpty5Server.withoutJson(
    super.channel, {
    super.onUnhandledError,
    super.strictProtocolChecks,
  }) : super.withoutJson();

  TestEmpty5Server.fromServer(super.jsonRpcInstance) : super.fromServer();
}

mixin TestEmpty6ServerMixin on ServerBase implements TestEmpty6 {
  @override
  @visibleForOverriding
  @mustCallSuper
  void registerMethods() {
    super.registerMethods();
  }
}

mixin TestEmpty7ClientMixin on ClientBase implements TestEmpty7 {}

class TestEmpty7Client extends ClientBase with TestEmpty7ClientMixin {
  TestEmpty7Client(super.channel, {super.idGenerator}) : super();

  TestEmpty7Client.withoutJson(super.channel, {super.idGenerator})
    : super.withoutJson();

  TestEmpty7Client.fromClient(super.jsonRpcInstance) : super.fromClient();
}

mixin TestEmpty8ClientMixin on ClientBase implements TestEmpty8 {}

mixin TestEmpty9ClientMixin on ClientBase implements TestEmpty9 {}

mixin TestEmpty9ServerMixin on ServerBase implements TestEmpty9 {
  @override
  @visibleForOverriding
  @mustCallSuper
  void registerMethods() {
    super.registerMethods();
  }
}

class TestEmpty9Client extends ClientBase with TestEmpty9ClientMixin {
  TestEmpty9Client(super.channel, {super.idGenerator}) : super();

  TestEmpty9Client.withoutJson(super.channel, {super.idGenerator})
    : super.withoutJson();

  TestEmpty9Client.fromClient(super.jsonRpcInstance) : super.fromClient();
}

abstract class TestEmpty9Server extends ServerBase with TestEmpty9ServerMixin {
  TestEmpty9Server(
    super.channel, {
    super.onUnhandledError,
    super.strictProtocolChecks,
  }) : super();

  TestEmpty9Server.withoutJson(
    super.channel, {
    super.onUnhandledError,
    super.strictProtocolChecks,
  }) : super.withoutJson();

  TestEmpty9Server.fromServer(super.jsonRpcInstance) : super.fromServer();
}

mixin TestEmpty10ClientMixin on ClientBase implements TestEmpty10 {}

mixin TestEmpty10ServerMixin on ServerBase implements TestEmpty10 {
  @override
  @visibleForOverriding
  @mustCallSuper
  void registerMethods() {
    super.registerMethods();
  }
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
