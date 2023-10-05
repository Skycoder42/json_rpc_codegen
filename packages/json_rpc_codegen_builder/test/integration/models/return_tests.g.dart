// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'return_tests.dart';

// **************************************************************************
// JsonRpcGenerator
// **************************************************************************

// ignore_for_file: type=lint, unused_element

mixin ReturnTestsClientMixin on ClientBase implements ReturnTests {
  @override
  Future<bool> boolRet() async {
    final dynamic $result = await jsonRpcInstance.sendRequest('boolRet');
    return ($result as bool);
  }

  @override
  Future<num?> numRet() async {
    final dynamic $result = await jsonRpcInstance.sendRequest('numRet');
    return ($result as num?);
  }

  @override
  Future<int> intRet() async {
    final dynamic $result = await jsonRpcInstance.sendRequest('intRet');
    return ($result as int);
  }

  @override
  Future<double?> doubleRet() async {
    final dynamic $result = await jsonRpcInstance.sendRequest('doubleRet');
    return ($result as double?);
  }

  @override
  Future<String> stringRet() async {
    final dynamic $result = await jsonRpcInstance.sendRequest('stringRet');
    return ($result as String);
  }

  @override
  Future<List<int>> listRet() async {
    final dynamic $result = await jsonRpcInstance.sendRequest('listRet');
    return ($result as List).map((dynamic $e) => ($e as int)).toList();
  }

  @override
  Future<Iterable<bool>> iterableRet() async {
    final dynamic $result = await jsonRpcInstance.sendRequest('iterableRet');
    return ($result as List).map((dynamic $e) => ($e as bool));
  }

  @override
  Future<Map<String, double>> mapRet() async {
    final dynamic $result = await jsonRpcInstance.sendRequest('mapRet');
    return ($result as Map).map((
      dynamic $k,
      dynamic $v,
    ) =>
        MapEntry(
          ($k as String),
          ($v as double),
        ));
  }

  @override
  Future<Map<List<String>, Iterable<Map<dynamic, List<num>>>>> deepRet() async {
    final dynamic $result = await jsonRpcInstance.sendRequest('deepRet');
    return ($result as Map).map((
      dynamic $k,
      dynamic $v,
    ) =>
        MapEntry(
          ($k as List).map((dynamic $e) => ($e as String)).toList(),
          ($v as List).map((dynamic $e) => ($e as Map).map((
                dynamic $k,
                dynamic $v,
              ) =>
                  MapEntry(
                    $k,
                    ($v as List).map((dynamic $e) => ($e as num)).toList(),
                  ))),
        ));
  }

  @override
  Future<User> userRet() async {
    final dynamic $result = await jsonRpcInstance.sendRequest('userRet');
    return User.fromJson(($result as Map<String, dynamic>));
  }

  @override
  Future<Color> colorRet() async {
    final dynamic $result = await jsonRpcInstance.sendRequest('colorRet');
    return Color.fromJson(($result as String));
  }

  @override
  Future<Permission> permissionRet() async {
    final dynamic $result = await jsonRpcInstance.sendRequest('permissionRet');
    return Permission.values.byName(($result as String));
  }

  @override
  Future<Iterable<User>> usersRet() async {
    final dynamic $result = await jsonRpcInstance.sendRequest('usersRet');
    return ($result as List)
        .map((dynamic $e) => User.fromJson(($e as Map<String, dynamic>)));
  }

  @override
  Future<Map<Color, List<Permission>>> colorPermissionsRet() async {
    final dynamic $result =
        await jsonRpcInstance.sendRequest('colorPermissionsRet');
    return ($result as Map).map((
      dynamic $k,
      dynamic $v,
    ) =>
        MapEntry(
          Color.fromJson(($k as String)),
          ($v as List)
              .map((dynamic $e) => Permission.values.byName(($e as String)))
              .toList(),
        ));
  }
}
mixin ReturnTestsServerMixin on ServerBase implements ReturnTests {
  @override
  @protected
  FutureOr<bool> boolRet();
  @override
  @protected
  FutureOr<num?> numRet();
  @override
  @protected
  FutureOr<int> intRet();
  @override
  @protected
  FutureOr<double?> doubleRet();
  @override
  @protected
  FutureOr<String> stringRet();
  @override
  @protected
  FutureOr<List<int>> listRet();
  @override
  @protected
  FutureOr<Iterable<bool>> iterableRet();
  @override
  @protected
  FutureOr<Map<String, double>> mapRet();
  @override
  @protected
  FutureOr<Map<List<String>, Iterable<Map<dynamic, List<num>>>>> deepRet();
  @override
  @protected
  FutureOr<User> userRet();
  @override
  @protected
  FutureOr<Color> colorRet();
  @override
  @protected
  FutureOr<Permission> permissionRet();
  @override
  @protected
  FutureOr<Iterable<User>> usersRet();
  @override
  @protected
  FutureOr<Map<Color, List<Permission>>> colorPermissionsRet();
  @override
  @visibleForOverriding
  @mustCallSuper
  void registerMethods() {
    super.registerMethods();
    jsonRpcInstance.registerMethod(
      'boolRet',
      () async => (await boolRet()),
    );
    jsonRpcInstance.registerMethod(
      'numRet',
      () async => (await numRet()),
    );
    jsonRpcInstance.registerMethod(
      'intRet',
      () async => (await intRet()),
    );
    jsonRpcInstance.registerMethod(
      'doubleRet',
      () async => (await doubleRet()),
    );
    jsonRpcInstance.registerMethod(
      'stringRet',
      () async => (await stringRet()),
    );
    jsonRpcInstance.registerMethod(
      'listRet',
      () async => (await listRet()),
    );
    jsonRpcInstance.registerMethod(
      'iterableRet',
      () async => (await iterableRet()).toList(growable: false),
    );
    jsonRpcInstance.registerMethod(
      'mapRet',
      () async => (await mapRet()),
    );
    jsonRpcInstance.registerMethod(
      'deepRet',
      () async => (await deepRet()).map((
        $k,
        $v,
      ) =>
          MapEntry(
            $k,
            $v.toList(growable: false),
          )),
    );
    jsonRpcInstance.registerMethod(
      'userRet',
      () async => (await userRet()),
    );
    jsonRpcInstance.registerMethod(
      'colorRet',
      () async => (await colorRet()),
    );
    jsonRpcInstance.registerMethod(
      'permissionRet',
      () async => (await permissionRet()).name,
    );
    jsonRpcInstance.registerMethod(
      'usersRet',
      () async => (await usersRet()).toList(growable: false),
    );
    jsonRpcInstance.registerMethod(
      'colorPermissionsRet',
      () async => (await colorPermissionsRet()).map((
        $k,
        $v,
      ) =>
          MapEntry(
            $k,
            $v.map(($e) => $e.name).toList(growable: false),
          )),
    );
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
