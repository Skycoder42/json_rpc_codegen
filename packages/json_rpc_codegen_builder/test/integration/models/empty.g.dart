// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'empty.dart';

// **************************************************************************
// JsonRpcGenerator
// **************************************************************************

// ignore_for_file: type=lint, unused_element

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
  TestEmpty1Client(super.channel) : super();

  TestEmpty1Client.withoutJson(super.channel) : super.withoutJson();

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
  TestEmpty7Client(super.channel) : super();

  TestEmpty7Client.withoutJson(super.channel) : super.withoutJson();

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
  TestEmpty9Client(super.channel) : super();

  TestEmpty9Client.withoutJson(super.channel) : super.withoutJson();

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
TConverted? _$maybeMap<TConverted extends Object, TJson extends Object>(
  TJson? $value,
  TConverted Function(TJson) $convert,
) =>
    $value == null ? null : $convert($value);

extension _$JsonRpc2ParameterExtensions on Parameter {
  T? $nullOr<T>(T Function(Parameter) getter) =>
      value == null ? null : getter(this);
  T? $maybeNullOr<T>(
    T Function(Parameter) getter,
    T? defaultValue,
  ) =>
      exists ? $nullOr<T>(getter) : defaultValue;
}
