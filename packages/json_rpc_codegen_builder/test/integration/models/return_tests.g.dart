// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'return_tests.dart';

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

mixin ReturnTestsClientMixin on ClientBase implements ReturnTests {
  @override
  Future<bool> boolRet() async {
    final $result = await jsonRpcInstance.sendRequest('boolRet');
    return ($result as bool);
  }

  @override
  Future<num?> numRet() async {
    final $result = await jsonRpcInstance.sendRequest('numRet');
    return ($result as num?);
  }

  @override
  Future<int> intRet() async {
    final $result = await jsonRpcInstance.sendRequest('intRet');
    return ($result as int);
  }

  @override
  Future<double?> doubleRet() async {
    final $result = await jsonRpcInstance.sendRequest('doubleRet');
    return ($result as double?);
  }

  @override
  Future<String> stringRet() async {
    final $result = await jsonRpcInstance.sendRequest('stringRet');
    return ($result as String);
  }

  @override
  Future<DateTime> dateTimeRet() async {
    final $result = await jsonRpcInstance.sendRequest('dateTimeRet');
    return DateTime.parse(($result as String));
  }

  @override
  Future<Uri> uriRet() async {
    final $result = await jsonRpcInstance.sendRequest('uriRet');
    return Uri.parse(($result as String));
  }

  @override
  Future<dynamic> dynamicRet() async {
    return await jsonRpcInstance.sendRequest('dynamicRet');
  }

  @override
  Future<List<int>> listRet() async {
    final $result = await jsonRpcInstance.sendRequest('listRet');
    return ($result as List).map((dynamic $e) => ($e as int)).toList();
  }

  @override
  Future<Iterable<bool>> iterableRet() async {
    final $result = await jsonRpcInstance.sendRequest('iterableRet');
    return ($result as List).map((dynamic $e) => ($e as bool));
  }

  @override
  Future<Set<String>> setRet() async {
    final $result = await jsonRpcInstance.sendRequest('setRet');
    return ($result as List).map((dynamic $e) => ($e as String)).toSet();
  }

  @override
  Future<Map<String, double>> mapRet() async {
    final $result = await jsonRpcInstance.sendRequest('mapRet');
    return ($result as Map).map(
      (dynamic $k, dynamic $v) => MapEntry(($k as String), ($v as double)),
    );
  }

  @override
  Future<Map<String, Iterable<Map<dynamic, List<num>>>>> deepRet() async {
    final $result = await jsonRpcInstance.sendRequest('deepRet');
    return ($result as Map).map(
      (dynamic $k, dynamic $v) => MapEntry(
        ($k as String),
        ($v as List).map(
          (dynamic $e) => ($e as Map).map(
            (dynamic $k, dynamic $v) => MapEntry(
              $k,
              ($v as List).map((dynamic $e) => ($e as num)).toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Future<User> userRet() async {
    final $result = await jsonRpcInstance.sendRequest('userRet');
    return User.fromJson(($result as Map<String, dynamic>));
  }

  @override
  Future<Color?> colorRet() async {
    final $result = await jsonRpcInstance.sendRequest('colorRet');
    return _$maybeMap($result, ($v) => Color.fromJson(($v as String)));
  }

  @override
  Future<Permission> permissionRet() async {
    final $result = await jsonRpcInstance.sendRequest('permissionRet');
    return Permission.values.byName(($result as String));
  }

  @override
  Future<Iterable<User>> usersRet() async {
    final $result = await jsonRpcInstance.sendRequest('usersRet');
    return ($result as List).map(
      (dynamic $e) => User.fromJson(($e as Map<String, dynamic>)),
    );
  }

  @override
  Future<Map<dynamic, List<Permission>>> colorPermissionsRet() async {
    final $result = await jsonRpcInstance.sendRequest('colorPermissionsRet');
    return ($result as Map).map(
      (dynamic $k, dynamic $v) => MapEntry(
        $k,
        ($v as List)
            .map((dynamic $e) => Permission.values.byName(($e as String)))
            .toList(),
      ),
    );
  }

  @override
  Future<(int?, Permission, Iterable<User?>, ({int x, int y}))>
  posRecordRet() async {
    final $result = await jsonRpcInstance.sendRequest('posRecordRet');
    return _$map(
      ($result as List),
      ($v) => (
        ($v[0] as int?),
        Permission.values.byName(($v[1] as String)),
        ($v[2] as List).map(
          (dynamic $e) => _$maybeMap(
            $e,
            ($v) => User.fromJson(($v as Map<String, dynamic>)),
          ),
        ),
        _$map(
          ($v[3] as Map),
          ($v) => (x: ($v['x'] as int), y: ($v['y'] as int)),
        ),
      ),
    );
  }

  @override
  Future<({Color c, Map<String, String?>? d, (int, int) p, double r})>
  namedRecordRet() async {
    final $result = await jsonRpcInstance.sendRequest('namedRecordRet');
    return _$map(
      ($result as Map),
      ($v) => (
        c: Color.fromJson(($v['c'] as String)),
        d: ($v['d'] as Map?)?.map(
          (dynamic $k, dynamic $v) => MapEntry(($k as String), ($v as String?)),
        ),
        p: _$map(($v['p'] as List), ($v) => (($v[0] as int), ($v[1] as int))),
        r: ($v['r'] as double),
      ),
    );
  }

  @override
  Future<Color> customRet() async {
    final $result = await jsonRpcInstance.sendRequest('customRet');
    return colorFromRgb(($result as List<dynamic>));
  }

  @override
  Future<Color?> customNullableRet() async {
    final $result = await jsonRpcInstance.sendRequest('custom-nullable-ret');
    return _$maybeMap($result, ($v) => colorFromRgb(($v as List<dynamic>)));
  }

  @override
  Future<Permission> customPermissionRet() async {
    final $result = await jsonRpcInstance.sendRequest('customPermissionRet');
    return PermissionCodec.fromCode(($result as int));
  }

  @override
  Future<double> customPrimitiveRet() async {
    final $result = await jsonRpcInstance.sendRequest('customPrimitiveRet');
    return doubleFromFixed(($result as String));
  }
}
mixin ReturnTestsServerMixin on ServerBase implements ReturnTests {
  @override
  @visibleForOverriding
  @mustCallSuper
  void registerMethods() {
    super.registerMethods();
    jsonRpcInstance.registerMethod('boolRet', () async {
      return await boolRet();
    });
    jsonRpcInstance.registerMethod('numRet', () async {
      return await numRet();
    });
    jsonRpcInstance.registerMethod('intRet', () async {
      return await intRet();
    });
    jsonRpcInstance.registerMethod('doubleRet', () async {
      return await doubleRet();
    });
    jsonRpcInstance.registerMethod('stringRet', () async {
      return await stringRet();
    });
    jsonRpcInstance.registerMethod('dateTimeRet', () async {
      final $result = await dateTimeRet();
      return $result.toIso8601String();
    });
    jsonRpcInstance.registerMethod('uriRet', () async {
      final $result = await uriRet();
      return $result.toString();
    });
    jsonRpcInstance.registerMethod('dynamicRet', () async {
      return await dynamicRet();
    });
    jsonRpcInstance.registerMethod('listRet', () async {
      return await listRet();
    });
    jsonRpcInstance.registerMethod('iterableRet', () async {
      final $result = await iterableRet();
      return $result.toList(growable: false);
    });
    jsonRpcInstance.registerMethod('setRet', () async {
      final $result = await setRet();
      return $result.toList(growable: false);
    });
    jsonRpcInstance.registerMethod('mapRet', () async {
      return await mapRet();
    });
    jsonRpcInstance.registerMethod('deepRet', () async {
      final $result = await deepRet();
      return $result.map(($k, $v) => MapEntry($k, $v.toList(growable: false)));
    });
    jsonRpcInstance.registerMethod('userRet', () async {
      return await userRet();
    });
    jsonRpcInstance.registerMethod('colorRet', () async {
      return await colorRet();
    });
    jsonRpcInstance.registerMethod('permissionRet', () async {
      final $result = await permissionRet();
      return $result.name;
    });
    jsonRpcInstance.registerMethod('usersRet', () async {
      final $result = await usersRet();
      return $result.toList(growable: false);
    });
    jsonRpcInstance.registerMethod('colorPermissionsRet', () async {
      final $result = await colorPermissionsRet();
      return $result.map(
        ($k, $v) =>
            MapEntry($k, $v.map(($e) => $e.name).toList(growable: false)),
      );
    });
    jsonRpcInstance.registerMethod('posRecordRet', () async {
      final $result = await posRecordRet();
      return <dynamic>[
        $result.$1,
        $result.$2.name,
        $result.$3.toList(growable: false),
        <String, dynamic>{'x': $result.$4.x, 'y': $result.$4.y},
      ];
    });
    jsonRpcInstance.registerMethod('namedRecordRet', () async {
      final $result = await namedRecordRet();
      return <String, dynamic>{
        'c': $result.c,
        'd': $result.d,
        'p': <dynamic>[$result.p.$1, $result.p.$2],
        'r': $result.r,
      };
    });
    jsonRpcInstance.registerMethod('customRet', () async {
      final $result = await customRet();
      return colorToRgb($result);
    });
    jsonRpcInstance.registerMethod('custom-nullable-ret', () async {
      final $result = await customNullableRet();
      return _$maybeMap($result, colorToRgb);
    });
    jsonRpcInstance.registerMethod('customPermissionRet', () async {
      final $result = await customPermissionRet();
      return PermissionCodec.toCode($result);
    });
    jsonRpcInstance.registerMethod('customPrimitiveRet', () async {
      final $result = await customPrimitiveRet();
      return doubleToFixed($result);
    });
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
