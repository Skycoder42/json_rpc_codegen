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

mixin ParameterTestsClientMixin on ClientBase implements _ParameterTests {
  @override
  void simplePositionalServer(
    bool a,
    num? b, [
    int c = 42,
    double? d,
    String e = 'default',
  ]) => jsonRpcInstance.sendNotification('simplePositionalServer', <dynamic>[
    a,
    b,
    if (c != 42 || d != null || e != 'default') c,
    if (d != null || e != 'default') d,
    if (e != 'default') e,
  ]);

  @override
  void simpleNamedServer({
    required bool a,
    required num? b,
    int c = 42,
    double? d,
    String e = 'default',
  }) => jsonRpcInstance.sendNotification('simpleNamedServer', <String, dynamic>{
    'a': a,
    'b': b,
    if (c != 42) 'c': c,
    'd': ?d,
    if (e != 'default') 'e': e,
  });

  @override
  void simplePositionalClient(
    bool a,
    num? b, [
    int c = 42,
    double? d,
    String e = 'default',
  ]) => jsonRpcInstance.sendNotification('simplePositionalClient', <dynamic>[
    a,
    b,
    c,
    d,
    e,
  ]);

  @override
  void simpleNamedClient({
    required bool a,
    required num? b,
    int c = 42,
    double? d,
    String e = 'default',
  }) => jsonRpcInstance.sendNotification('simpleNamedClient', <String, dynamic>{
    'a': a,
    'b': b,
    'c': c,
    'd': d,
    'e': e,
  });

  @override
  void containers(
    Iterable<String> names,
    List<int> bytes,
    Map<String, bool> features,
    Map<List<String>, Iterable<Map<dynamic, List<num>>>> deep,
  ) => jsonRpcInstance.sendNotification('containers', <dynamic>[
    names.toList(growable: false),
    bytes,
    features,
    deep.map(($k, $v) => MapEntry($k, $v.toList(growable: false))),
  ]);

  @override
  void custom(
    User user, [
    Color color = const Color(255, 255, 255),
    Permission permission = Permission.readOnly,
  ]) => jsonRpcInstance.sendNotification('custom', <dynamic>[
    user,
    if (color != const Color(255, 255, 255) ||
        permission != Permission.readOnly)
      color,
    if (permission != Permission.readOnly) permission.name,
  ]);

  @override
  void dotShorthandsServer(
    User user, [
    Color color = const .new(255, 255, 255),
    Permission permission = .readOnly,
  ]) => jsonRpcInstance.sendNotification('dotShorthandsServer', <dynamic>[
    user,
    if (color != const .new(255, 255, 255) || permission != .readOnly) color,
    if (permission != .readOnly) permission.name,
  ]);

  @override
  void dotShorthandsClient(
    User user, [
    Color color = const .new(255, 255, 255),
    Permission permission = .readOnly,
  ]) => jsonRpcInstance.sendNotification('dotShorthandsClient', <dynamic>[
    user,
    color,
    permission.name,
  ]);

  @override
  void customContainers({
    required Iterable<User> users,
    Map<Color, List<Permission>> colorPermissions = const {
      Color(0, 0, 0): [Permission.readWrite],
    },
  }) => jsonRpcInstance.sendNotification('customContainers', <String, dynamic>{
    'users': users.toList(growable: false),
    if (colorPermissions !=
        const {
          Color(0, 0, 0): [Permission.readWrite],
        })
      'colorPermissions': colorPermissions.map(
        ($k, $v) =>
            MapEntry($k, $v.map(($e) => $e.name).toList(growable: false)),
      ),
  });

  @override
  void records(
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
  ) => jsonRpcInstance.sendNotification('records', <dynamic>[
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
mixin ParameterTestsServerMixin on ServerBase {
  @protected
  FutureOr<void> simplePositionalServer(
    bool a,
    num? b,
    int c,
    double? d,
    String e,
  );
  @protected
  FutureOr<void> simpleNamedServer(bool a, num? b, int c, double? d, String e);
  @protected
  FutureOr<void> simplePositionalClient(
    bool a,
    num? b,
    int c,
    double? d,
    String e,
  );
  @protected
  FutureOr<void> simpleNamedClient(bool a, num? b, int c, double? d, String e);
  @protected
  FutureOr<void> containers(
    Iterable<String> names,
    List<int> bytes,
    Map<String, bool> features,
    Map<List<String>, Iterable<Map<dynamic, List<num>>>> deep,
  );
  @protected
  FutureOr<void> custom(User user, Color color, Permission permission);
  @protected
  FutureOr<void> dotShorthandsServer(
    User user,
    Color color,
    Permission permission,
  );
  @protected
  FutureOr<void> dotShorthandsClient(
    User user,
    Color color,
    Permission permission,
  );
  @protected
  FutureOr<void> customContainers(
    Iterable<User> users,
    Map<Color, List<Permission>> colorPermissions,
  );
  @protected
  FutureOr<void> records(
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
  );
  @override
  @visibleForOverriding
  @mustCallSuper
  void registerMethods() {
    super.registerMethods();
    jsonRpcInstance.registerMethod('simplePositionalServer', (
      Parameters $params,
    ) async {
      final $$a = $params[0].asBool;
      final $$b = $params[1].$nullOr(($v) => $v.asNum);
      final $$c = $params[2].asIntOr(42);
      final $$d = $params[3].$maybeNullOr(($v) => $v.asNum)?.toDouble();
      final $$e = $params[4].asStringOr('default');
      await simplePositionalServer($$a, $$b, $$c, $$d, $$e);
    });
    jsonRpcInstance.registerMethod('simpleNamedServer', (
      Parameters $params,
    ) async {
      final $$a = $params['a'].asBool;
      final $$b = $params['b'].$nullOr(($v) => $v.asNum);
      final $$c = $params['c'].asIntOr(42);
      final $$d = $params['d'].$maybeNullOr(($v) => $v.asNum)?.toDouble();
      final $$e = $params['e'].asStringOr('default');
      await simpleNamedServer($$a, $$b, $$c, $$d, $$e);
    });
    jsonRpcInstance.registerMethod('simplePositionalClient', (
      Parameters $params,
    ) async {
      final $$a = $params[0].asBool;
      final $$b = $params[1].$nullOr(($v) => $v.asNum);
      final $$c = $params[2].asInt;
      final $$d = $params[3].$nullOr(($v) => $v.asNum)?.toDouble();
      final $$e = $params[4].asString;
      await simplePositionalClient($$a, $$b, $$c, $$d, $$e);
    });
    jsonRpcInstance.registerMethod('simpleNamedClient', (
      Parameters $params,
    ) async {
      final $$a = $params['a'].asBool;
      final $$b = $params['b'].$nullOr(($v) => $v.asNum);
      final $$c = $params['c'].asInt;
      final $$d = $params['d'].$nullOr(($v) => $v.asNum)?.toDouble();
      final $$e = $params['e'].asString;
      await simpleNamedClient($$a, $$b, $$c, $$d, $$e);
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
          ($k as List).map((dynamic $e) => ($e as String)).toList(),
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
      final $$user = User.fromJson(($params[0].value as Map<String, dynamic>));
      final $$color = $params[1].$maybeOr<Color>(
        ($v) => Color.fromJson(($v.value as String)),
        const Color(255, 255, 255),
      );
      final $$permission = $params[2].$maybeOr<Permission>(
        ($v) => Permission.values.byName($v.asString),
        Permission.readOnly,
      );
      await custom($$user, $$color, $$permission);
    });
    jsonRpcInstance.registerMethod('dotShorthandsServer', (
      Parameters $params,
    ) async {
      final $$user = User.fromJson(($params[0].value as Map<String, dynamic>));
      final $$color = $params[1].$maybeOr<Color>(
        ($v) => Color.fromJson(($v.value as String)),
        const .new(255, 255, 255),
      );
      final $$permission = $params[2].$maybeOr<Permission>(
        ($v) => Permission.values.byName($v.asString),
        .readOnly,
      );
      await dotShorthandsServer($$user, $$color, $$permission);
    });
    jsonRpcInstance.registerMethod('dotShorthandsClient', (
      Parameters $params,
    ) async {
      final $$user = User.fromJson(($params[0].value as Map<String, dynamic>));
      final $$color = Color.fromJson(($params[1].value as String));
      final $$permission = Permission.values.byName($params[2].asString);
      await dotShorthandsClient($$user, $$color, $$permission);
    });
    jsonRpcInstance.registerMethod('customContainers', (
      Parameters $params,
    ) async {
      final $$users = $params['users'].asList.map(
        (dynamic $e) => User.fromJson(($e as Map<String, dynamic>)),
      );
      final $$colorPermissions = $params['colorPermissions']
          .$maybeOr<Map<Color, List<Permission>>>(
            ($v) => $v.asMap.map(
              (dynamic $k, dynamic $v) => MapEntry(
                Color.fromJson(($k as String)),
                ($v as List)
                    .map(
                      (dynamic $e) => Permission.values.byName(($e as String)),
                    )
                    .toList(),
              ),
            ),
            const {
              Color(0, 0, 0): [Permission.readWrite],
            },
          );
      await customContainers($$users, $$colorPermissions);
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
TConverted _$map<TConverted extends Object, TJson extends Object>(
  TJson $value,
  TConverted Function(TJson) $convert,
) => $convert($value);
@pragma('vm:prefer-inline')
TConverted? _$maybeMap<TConverted extends Object, TJson extends Object>(
  TJson? $value,
  TConverted Function(TJson) $convert,
) => $value == null ? null : $convert($value);

extension _$JsonRpc2ParameterExtensions on Parameter {
  @pragma('vm:prefer-inline')
  T $maybeOr<T>(T Function(Parameter) getter, T defaultValue) =>
      exists ? getter(this) : defaultValue;

  @pragma('vm:prefer-inline')
  T? $nullOr<T>(T Function(Parameter) getter) =>
      value != null ? getter(this) : null;

  @pragma('vm:prefer-inline')
  T? $maybeNullOr<T>(T Function(Parameter) getter) =>
      exists && value != null ? getter(this) : null;
}
