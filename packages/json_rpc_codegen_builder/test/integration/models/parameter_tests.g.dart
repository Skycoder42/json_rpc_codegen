// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parameter_tests.dart';

// **************************************************************************
// JsonRpcGenerator
// **************************************************************************

// ignore_for_file: avoid_futureor_void, avoid_positional_boolean_parameters
// ignore_for_file: cascade_invocations, cast_nullable_to_non_nullable
// ignore_for_file: document_ignores, lines_longer_than_80_chars
// ignore_for_file: no_literal_bool_comparisons
// ignore_for_file: prefer_expression_function_bodies, unnecessary_parenthesis
// ignore_for_file: unreachable_from_main, unused_element

mixin ParameterTestsClientMixin on ClientBase implements ParameterTests {
  @override
  Future<void> simplePositionalServer(
    bool a,
    num? b, [
    int c = 42,
    double? d,
    String? e = 'default',
  ]) async {
    await jsonRpcInstance.sendRequest('simplePositionalServer', <dynamic>[
      a,
      b,
      if (c != 42 || d != null || e != 'default') c,
      if (d != null || e != 'default') d,
      if (e != 'default') e,
    ]);
  }

  @override
  Future<void> simpleNamedServer({
    required bool a,
    required num? b,
    int c = 42,
    double? d,
    String? e = 'default',
  }) async {
    await jsonRpcInstance.sendRequest('simpleNamedServer', <String, dynamic>{
      'a': a,
      'b': b,
      if (c != 42) 'c': c,
      'd': ?d,
      if (e != 'default') 'e': e,
    });
  }

  @override
  Future<void> simplePositionalClient(
    bool a,
    num? b, [
    int c = 42,
    double? d,
    String? e = 'default',
  ]) async {
    await jsonRpcInstance.sendRequest('simplePositionalClient', <dynamic>[
      a,
      b,
      c,
      d,
      e,
    ]);
  }

  @override
  Future<void> simpleNamedClient({
    required bool a,
    required num? b,
    int c = 42,
    double? d,
    String? e = 'default',
  }) async {
    await jsonRpcInstance.sendRequest('simpleNamedClient', <String, dynamic>{
      'a': a,
      'b': b,
      'c': c,
      'd': d,
      'e': e,
    });
  }

  @override
  Future<void> containers(
    Iterable<String> names,
    List<int> bytes,
    Map<String, bool> features,
    Map<String, Iterable<Map<dynamic, List<num>>>> deep,
  ) async {
    await jsonRpcInstance.sendRequest('containers', <dynamic>[
      names.toList(growable: false),
      bytes,
      features,
      deep.map(($k, $v) => MapEntry($k, $v.toList(growable: false))),
    ]);
  }

  @override
  Future<void> custom(
    User user, [
    Color color = const Color(255, 255, 255),
    Permission permission = Permission.readOnly,
  ]) async {
    await jsonRpcInstance.sendRequest('custom', <dynamic>[
      user,
      if (color != const Color(255, 255, 255) ||
          permission != Permission.readOnly)
        color,
      if (permission != Permission.readOnly) permission.name,
    ]);
  }

  @override
  Future<void> dotShorthands(
    User user, [
    Color color = const .new(255, 255, 255),
    Permission permission = .readOnly,
  ]) async {
    await jsonRpcInstance.sendRequest('dotShorthands', <dynamic>[
      user,
      if (color != const .new(255, 255, 255) || permission != .readOnly) color,
      if (permission != .readOnly) permission.name,
    ]);
  }

  @override
  Future<void> customContainers({
    required Iterable<User> users,
    Map<String, List<Permission>> colorPermissions = const {
      'black': [Permission.readWrite],
    },
    List<Set<User?>?>? nullables,
    Map<Object, bool?>? optionalsNullable = const {
      'readOnly': true,
      'readWrite': null,
    },
  }) async {
    await jsonRpcInstance.sendRequest('customContainers', <String, dynamic>{
      'users': users.toList(growable: false),
      if (colorPermissions !=
          const {
            'black': [Permission.readWrite],
          })
        'colorPermissions': colorPermissions.map(
          ($k, $v) =>
              MapEntry($k, $v.map(($e) => $e.name).toList(growable: false)),
        ),
      'nullables': ?nullables
          ?.map(($e) => $e?.toList(growable: false))
          .toList(growable: false),
      if (optionalsNullable != const {'readOnly': true, 'readWrite': null})
        'optionalsNullable': optionalsNullable,
    });
  }

  @override
  Future<void> records(
    () empty,
    ((int, int), String, Color?, User, List<Permission>?) positional,
    ({
      Color color,
      String name,
      Iterable<Permission?> permissions,
      ({int x, int y}) point,
      User? user,
    })
    named,
  ) async {
    await jsonRpcInstance.sendRequest('records', <dynamic>[
      <dynamic>[],
      <dynamic>[
        <dynamic>[positional.$1.$1, positional.$1.$2],
        positional.$2,
        positional.$3,
        positional.$4,
        positional.$5?.map(($e) => $e.name).toList(growable: false),
      ],
      <String, dynamic>{
        'color': named.color,
        'name': named.name,
        'permissions': named.permissions
            .map(($e) => $e?.name)
            .toList(growable: false),
        'point': <String, dynamic>{'x': named.point.x, 'y': named.point.y},
        'user': named.user,
      },
    ]);
  }
}
mixin ParameterTestsServerMixin on ServerBase implements ParameterTests {
  @override
  @visibleForOverriding
  @mustCallSuper
  void registerMethods() {
    super.registerMethods();
    jsonRpcInstance.registerMethod('simplePositionalServer', (
      Parameters $params,
    ) async {
      final $$a = $params[0].asBool;
      final $$b = $params[1].$nullChecked<num>(($v) => $v.asNum);
      final $$c = $params[2].asIntOr(42);
      final $$d = $params[3].$nullCheckedOr<double>(
        ($v) => $v.asNum.toDouble(),
        null,
      );
      final $$e = $params[4].$nullCheckedOr<String>(
        ($v) => $v.asString,
        'default',
      );
      await simplePositionalServer($$a, $$b, $$c, $$d, $$e);
    });
    jsonRpcInstance.registerMethod('simpleNamedServer', (
      Parameters $params,
    ) async {
      final $$a = $params['a'].asBool;
      final $$b = $params['b'].$nullChecked<num>(($v) => $v.asNum);
      final $$c = $params['c'].asIntOr(42);
      final $$d = $params['d'].$nullCheckedOr<double>(
        ($v) => $v.asNum.toDouble(),
        null,
      );
      final $$e = $params['e'].$nullCheckedOr<String>(
        ($v) => $v.asString,
        'default',
      );
      await simpleNamedServer(a: $$a, b: $$b, c: $$c, d: $$d, e: $$e);
    });
    jsonRpcInstance.registerMethod('simplePositionalClient', (
      Parameters $params,
    ) async {
      final $$a = $params[0].asBool;
      final $$b = $params[1].$nullChecked<num>(($v) => $v.asNum);
      final $$c = $params[2].asIntOr(42);
      final $$d = $params[3].$nullCheckedOr<double>(
        ($v) => $v.asNum.toDouble(),
        null,
      );
      final $$e = $params[4].$nullCheckedOr<String>(
        ($v) => $v.asString,
        'default',
      );
      await simplePositionalClient($$a, $$b, $$c, $$d, $$e);
    });
    jsonRpcInstance.registerMethod('simpleNamedClient', (
      Parameters $params,
    ) async {
      final $$a = $params['a'].asBool;
      final $$b = $params['b'].$nullChecked<num>(($v) => $v.asNum);
      final $$c = $params['c'].asIntOr(42);
      final $$d = $params['d'].$nullCheckedOr<double>(
        ($v) => $v.asNum.toDouble(),
        null,
      );
      final $$e = $params['e'].$nullCheckedOr<String>(
        ($v) => $v.asString,
        'default',
      );
      await simpleNamedClient(a: $$a, b: $$b, c: $$c, d: $$d, e: $$e);
    });
    jsonRpcInstance.registerMethod('containers', (Parameters $params) async {
      final $$names = $params[0].asList.map((dynamic $e) => ($e as String));
      final $$bytes = $params[1].asList
          .map((dynamic $e) => ($e as int))
          .toList();
      final $$features = $params[2].asMap.map(
        (dynamic $k, dynamic $v) => MapEntry(($k as String), ($v as bool)),
      );
      final $$deep = $params[3].asMap.map(
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
      await containers($$names, $$bytes, $$features, $$deep);
    });
    jsonRpcInstance.registerMethod('custom', (Parameters $params) async {
      final $$user = User.fromJson($params[0].asMap.cast());
      final $$color = $params[1].$existsOr<Color>(
        ($v) => Color.fromJson($v.asString),
        const Color(255, 255, 255),
      );
      final $$permission = $params[2].$existsOr<Permission>(
        ($v) => Permission.values.byName($v.asString),
        Permission.readOnly,
      );
      await custom($$user, $$color, $$permission);
    });
    jsonRpcInstance.registerMethod('dotShorthands', (Parameters $params) async {
      final $$user = User.fromJson($params[0].asMap.cast());
      final $$color = $params[1].$existsOr<Color>(
        ($v) => Color.fromJson($v.asString),
        const .new(255, 255, 255),
      );
      final $$permission = $params[2].$existsOr<Permission>(
        ($v) => Permission.values.byName($v.asString),
        .readOnly,
      );
      await dotShorthands($$user, $$color, $$permission);
    });
    jsonRpcInstance.registerMethod('customContainers', (
      Parameters $params,
    ) async {
      final $$users = $params['users'].asList.map(
        (dynamic $e) => User.fromJson(($e as Map<String, dynamic>)),
      );
      final $$colorPermissions = $params['colorPermissions']
          .$existsOr<Map<String, List<Permission>>>(
            ($v) => $v.asMap.map(
              (dynamic $k, dynamic $v) => MapEntry(
                ($k as String),
                ($v as List)
                    .map(
                      (dynamic $e) => Permission.values.byName(($e as String)),
                    )
                    .toList(),
              ),
            ),
            const {
              'black': [Permission.readWrite],
            },
          );
      final $$nullables = $params['nullables']
          .$nullCheckedOr<List<Set<User?>?>>(
            ($v) => $v.asList
                .map(
                  (dynamic $e) => ($e as List?)
                      ?.map(
                        (dynamic $e) => _$maybeMap(
                          $e,
                          ($v) => User.fromJson(($v as Map<String, dynamic>)),
                        ),
                      )
                      .toSet(),
                )
                .toList(),
            null,
          );
      final $$optionalsNullable = $params['optionalsNullable']
          .$nullCheckedOr<Map<Object, bool?>>(
            ($v) => $v.asMap.map(
              (dynamic $k, dynamic $v) =>
                  MapEntry(($k as Object), ($v as bool?)),
            ),
            const {'readOnly': true, 'readWrite': null},
          );
      await customContainers(
        users: $$users,
        colorPermissions: $$colorPermissions,
        nullables: $$nullables,
        optionalsNullable: $$optionalsNullable,
      );
    });
    jsonRpcInstance.registerMethod('records', (Parameters $params) async {
      final $$empty = _$map($params[0].asList, ($v) => ());
      final $$positional = _$map(
        $params[1].asList,
        ($v) => (
          _$map(($v[0] as List), ($v) => (($v[0] as int), ($v[1] as int))),
          ($v[1] as String),
          _$maybeMap($v[2], ($v) => Color.fromJson(($v as String))),
          User.fromJson(($v[3] as Map<String, dynamic>)),
          ($v[4] as List?)
              ?.map((dynamic $e) => Permission.values.byName(($e as String)))
              .toList(),
        ),
      );
      final $$named = _$map(
        $params[2].asMap,
        ($v) => (
          color: Color.fromJson(($v['color'] as String)),
          name: ($v['name'] as String),
          permissions: ($v['permissions'] as List).map(
            (dynamic $e) => _$maybeMap(
              $e,
              ($v) => Permission.values.byName(($v as String)),
            ),
          ),
          point: _$map(
            ($v['point'] as Map),
            ($v) => (x: ($v['x'] as int), y: ($v['y'] as int)),
          ),
          user: _$maybeMap(
            $v['user'],
            ($v) => User.fromJson(($v as Map<String, dynamic>)),
          ),
        ),
      );
      await records($$empty, $$positional, $$named);
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
