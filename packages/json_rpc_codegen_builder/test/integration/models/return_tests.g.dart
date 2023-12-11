// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'return_tests.dart';

// **************************************************************************
// JsonRpcGenerator
// **************************************************************************

// ignore_for_file: type=lint, unused_element

mixin ReturnTestsClientMixin on ClientBase {
  Future<bool> boolRet() async {
    final dynamic $result = await jsonRpcInstance.sendRequest(
      'boolRet',
      <dynamic>[],
    );
    return ($result as bool);
  }

  Future<num?> numRet() async {
    final dynamic $result = await jsonRpcInstance.sendRequest(
      'numRet',
      <dynamic>[],
    );
    return ($result as num?);
  }

  Future<int> intRet() async {
    final dynamic $result = await jsonRpcInstance.sendRequest(
      'intRet',
      <dynamic>[],
    );
    return ($result as int);
  }

  Future<double?> doubleRet() async {
    final dynamic $result = await jsonRpcInstance.sendRequest(
      'doubleRet',
      <dynamic>[],
    );
    return ($result as double?);
  }

  Future<String> stringRet() async {
    final dynamic $result = await jsonRpcInstance.sendRequest(
      'stringRet',
      <dynamic>[],
    );
    return ($result as String);
  }

  Future<DateTime> dateTimeRet() async {
    final dynamic $result = await jsonRpcInstance.sendRequest(
      'dateTimeRet',
      <dynamic>[],
    );
    return DateTime.parse(($result as String));
  }

  Future<Uri> uriRet() async {
    final dynamic $result = await jsonRpcInstance.sendRequest(
      'uriRet',
      <dynamic>[],
    );
    return Uri.parse(($result as String));
  }

  Future<dynamic> dynamicRet() async {
    final dynamic $result = await jsonRpcInstance.sendRequest(
      'dynamicRet',
      <dynamic>[],
    );
    return $result;
  }

  Future<List<int>> listRet() async {
    final dynamic $result = await jsonRpcInstance.sendRequest(
      'listRet',
      <dynamic>[],
    );
    return ($result as List).map((dynamic $e) => ($e as int)).toList();
  }

  Future<Iterable<bool>> iterableRet() async {
    final dynamic $result = await jsonRpcInstance.sendRequest(
      'iterableRet',
      <dynamic>[],
    );
    return ($result as List).map((dynamic $e) => ($e as bool));
  }

  Future<Set<String>> setRet() async {
    final dynamic $result = await jsonRpcInstance.sendRequest(
      'setRet',
      <dynamic>[],
    );
    return ($result as List).map((dynamic $e) => ($e as String)).toSet();
  }

  Future<Map<String, double>> mapRet() async {
    final dynamic $result = await jsonRpcInstance.sendRequest(
      'mapRet',
      <dynamic>[],
    );
    return ($result as Map).map((
      dynamic $k,
      dynamic $v,
    ) =>
        MapEntry(
          ($k as String),
          ($v as double),
        ));
  }

  Future<Map<List<String>, Iterable<Map<dynamic, List<num>>>>> deepRet() async {
    final dynamic $result = await jsonRpcInstance.sendRequest(
      'deepRet',
      <dynamic>[],
    );
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

  Future<User> userRet() async {
    final dynamic $result = await jsonRpcInstance.sendRequest(
      'userRet',
      <dynamic>[],
    );
    return User.fromJson(($result as Map<String, dynamic>));
  }

  Future<Color> colorRet() async {
    final dynamic $result = await jsonRpcInstance.sendRequest(
      'colorRet',
      <dynamic>[],
    );
    return Color.fromJson(($result as String));
  }

  Future<Permission> permissionRet() async {
    final dynamic $result = await jsonRpcInstance.sendRequest(
      'permissionRet',
      <dynamic>[],
    );
    return Permission.values.byName(($result as String));
  }

  Future<Iterable<User>> usersRet() async {
    final dynamic $result = await jsonRpcInstance.sendRequest(
      'usersRet',
      <dynamic>[],
    );
    return ($result as List)
        .map((dynamic $e) => User.fromJson(($e as Map<String, dynamic>)));
  }

  Future<Map<Color, List<Permission>>> colorPermissionsRet() async {
    final dynamic $result = await jsonRpcInstance.sendRequest(
      'colorPermissionsRet',
      <dynamic>[],
    );
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

  Future<(int?, Permission, Iterable<User?>, ({int x, int y}))>
      posRecordRet() async {
    final dynamic $result = await jsonRpcInstance.sendRequest(
      'posRecordRet',
      <dynamic>[],
    );
    return _$map(
      ($result as List),
      ($v) => (
        ($v[0] as int?),
        Permission.values.byName(($v[1] as String)),
        ($v[2] as List).map((dynamic $e) => _$maybeMap(
              $e,
              ($v) => User.fromJson(($v as Map<String, dynamic>)),
            )),
        _$map(
          ($v[3] as Map),
          ($v) => (x: ($v['x'] as int), y: ($v['y'] as int)),
        )
      ),
    );
  }

  Future<({Color c, Map<String, String?>? d, (int, int) p, double r})>
      namedRecordRet() async {
    final dynamic $result = await jsonRpcInstance.sendRequest(
      'namedRecordRet',
      <dynamic>[],
    );
    return _$map(
      ($result as Map),
      ($v) => (
        c: Color.fromJson(($v['c'] as String)),
        d: ($v['d'] as Map?)?.map((
          dynamic $k,
          dynamic $v,
        ) =>
            MapEntry(
              ($k as String),
              ($v as String?),
            )),
        p: _$map(
          ($v['p'] as List),
          ($v) => (($v[0] as int), ($v[1] as int)),
        ),
        r: ($v['r'] as double)
      ),
    );
  }
}
mixin ReturnTestsServerMixin on ServerBase {
  @protected
  FutureOr<bool> boolRet();
  @protected
  FutureOr<num?> numRet();
  @protected
  FutureOr<int> intRet();
  @protected
  FutureOr<double?> doubleRet();
  @protected
  FutureOr<String> stringRet();
  @protected
  FutureOr<DateTime> dateTimeRet();
  @protected
  FutureOr<Uri> uriRet();
  @protected
  FutureOr<dynamic> dynamicRet();
  @protected
  FutureOr<List<int>> listRet();
  @protected
  FutureOr<Iterable<bool>> iterableRet();
  @protected
  FutureOr<Set<String>> setRet();
  @protected
  FutureOr<Map<String, double>> mapRet();
  @protected
  FutureOr<Map<List<String>, Iterable<Map<dynamic, List<num>>>>> deepRet();
  @protected
  FutureOr<User> userRet();
  @protected
  FutureOr<Color> colorRet();
  @protected
  FutureOr<Permission> permissionRet();
  @protected
  FutureOr<Iterable<User>> usersRet();
  @protected
  FutureOr<Map<Color, List<Permission>>> colorPermissionsRet();
  @protected
  FutureOr<(int?, Permission, Iterable<User?>, ({int x, int y}))>
      posRecordRet();
  @protected
  FutureOr<({Color c, Map<String, String?>? d, (int, int) p, double r})>
      namedRecordRet();
  @override
  @visibleForOverriding
  @mustCallSuper
  void registerMethods() {
    super.registerMethods();
    jsonRpcInstance.registerMethod(
      'boolRet',
      () async {
        return (await boolRet());
      },
    );
    jsonRpcInstance.registerMethod(
      'numRet',
      () async {
        return (await numRet());
      },
    );
    jsonRpcInstance.registerMethod(
      'intRet',
      () async {
        return (await intRet());
      },
    );
    jsonRpcInstance.registerMethod(
      'doubleRet',
      () async {
        return (await doubleRet());
      },
    );
    jsonRpcInstance.registerMethod(
      'stringRet',
      () async {
        return (await stringRet());
      },
    );
    jsonRpcInstance.registerMethod(
      'dateTimeRet',
      () async {
        return (await dateTimeRet()).toIso8601String();
      },
    );
    jsonRpcInstance.registerMethod(
      'uriRet',
      () async {
        return (await uriRet()).toString();
      },
    );
    jsonRpcInstance.registerMethod(
      'dynamicRet',
      () async {
        return (await dynamicRet());
      },
    );
    jsonRpcInstance.registerMethod(
      'listRet',
      () async {
        return (await listRet());
      },
    );
    jsonRpcInstance.registerMethod(
      'iterableRet',
      () async {
        return (await iterableRet()).toList(growable: false);
      },
    );
    jsonRpcInstance.registerMethod(
      'setRet',
      () async {
        return (await setRet()).toList(growable: false);
      },
    );
    jsonRpcInstance.registerMethod(
      'mapRet',
      () async {
        return (await mapRet());
      },
    );
    jsonRpcInstance.registerMethod(
      'deepRet',
      () async {
        return (await deepRet()).map((
          $k,
          $v,
        ) =>
            MapEntry(
              $k,
              $v.toList(growable: false),
            ));
      },
    );
    jsonRpcInstance.registerMethod(
      'userRet',
      () async {
        return (await userRet());
      },
    );
    jsonRpcInstance.registerMethod(
      'colorRet',
      () async {
        return (await colorRet());
      },
    );
    jsonRpcInstance.registerMethod(
      'permissionRet',
      () async {
        return (await permissionRet()).name;
      },
    );
    jsonRpcInstance.registerMethod(
      'usersRet',
      () async {
        return (await usersRet()).toList(growable: false);
      },
    );
    jsonRpcInstance.registerMethod(
      'colorPermissionsRet',
      () async {
        return (await colorPermissionsRet()).map((
          $k,
          $v,
        ) =>
            MapEntry(
              $k,
              $v.map(($e) => $e.name).toList(growable: false),
            ));
      },
    );
    jsonRpcInstance.registerMethod(
      'posRecordRet',
      () async {
        final $result = await posRecordRet();
        return <dynamic>[
          $result.$1,
          $result.$2.name,
          $result.$3.toList(growable: false),
          <String, dynamic>{
            'x': $result.$4.x,
            'y': $result.$4.y,
          },
        ];
      },
    );
    jsonRpcInstance.registerMethod(
      'namedRecordRet',
      () async {
        final $result = await namedRecordRet();
        return <String, dynamic>{
          'c': $result.c,
          'd': $result.d,
          'p': <dynamic>[
            $result.p.$1,
            $result.p.$2,
          ],
          'r': $result.r,
        };
      },
    );
  }
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
