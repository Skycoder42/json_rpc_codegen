// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parameter_tests.dart';

// **************************************************************************
// JsonRpcGenerator
// **************************************************************************

// ignore_for_file: type=lint, unused_element

mixin ParameterTestsClientMixin on ClientBase {
  void simplePositionalServer(
    bool a,
    num? b, [
    int? c,
    double? d,
    String? e,
  ]) {
    if (c == null && (d != null || e != null)) {
      throw ArgumentError(
        'Cannot set optional value to null if any of the following parameters (e, d) are not null.',
        'c',
      );
    }
    if (d == null && (e != null)) {
      throw ArgumentError(
        'Cannot set optional value to null if any of the following parameters (e) are not null.',
        'd',
      );
    }
    jsonRpcInstance.sendNotification(
      'simplePositionalServer',
      <dynamic>[
        a,
        b,
        if (c != null) c,
        if (d != null) d,
        if (e != null) e,
      ],
    );
  }

  void simpleNamedServer({
    required bool a,
    required num? b,
    int? c,
    double? d,
    String? e,
  }) =>
      jsonRpcInstance.sendNotification(
        'simpleNamedServer',
        <String, dynamic>{
          'a': a,
          'b': b,
          if (c != null) 'c': c,
          if (d != null) 'd': d,
          if (e != null) 'e': e,
        },
      );
  void simplePositionalClient(
    bool a,
    num? b, [
    int c = 42,
    double? d,
    String e = 'default',
  ]) =>
      jsonRpcInstance.sendNotification(
        'simplePositionalClient',
        <dynamic>[
          a,
          b,
          c,
          d,
          e,
        ],
      );
  void simpleNamedClient({
    required bool a,
    required num? b,
    int c = 42,
    double? d,
    String e = 'default',
  }) =>
      jsonRpcInstance.sendNotification(
        'simpleNamedClient',
        <String, dynamic>{
          'a': a,
          'b': b,
          'c': c,
          'd': d,
          'e': e,
        },
      );
  void containers(
    Iterable<String> names,
    List<int> bytes,
    Map<String, bool> features,
    Map<List<String>, Iterable<Map<dynamic, List<num>>>> deep,
  ) =>
      jsonRpcInstance.sendNotification(
        'containers',
        <dynamic>[
          names.toList(growable: false),
          bytes,
          features,
          deep.map((
            $k,
            $v,
          ) =>
              MapEntry(
                $k,
                $v.toList(growable: false),
              )),
        ],
      );
  void custom(
    User user, [
    Color? color,
    Permission? permission,
  ]) {
    if (color == null && (permission != null)) {
      throw ArgumentError(
        'Cannot set optional value to null if any of the following parameters (permission) are not null.',
        'color',
      );
    }
    jsonRpcInstance.sendNotification(
      'custom',
      <dynamic>[
        user,
        if (color != null) color,
        if (permission != null) permission.name,
      ],
    );
  }

  void customContainers({
    required Iterable<User> users,
    Map<Color, List<Permission>>? colorPermissions,
  }) =>
      jsonRpcInstance.sendNotification(
        'customContainers',
        <String, dynamic>{
          'users': users.toList(growable: false),
          if (colorPermissions != null)
            'colorPermissions': colorPermissions.map((
              $k,
              $v,
            ) =>
                MapEntry(
                  $k,
                  $v.map(($e) => $e.name).toList(growable: false),
                )),
        },
      );
  void records(
    () empty,
    ((int, int), String, Color?, User, List<Permission>?) positional,
    ({
      Color color,
      String name,
      Iterable<Permission?> permissions,
      ({int x, int y}) point,
      User? user
    }) named,
  ) =>
      jsonRpcInstance.sendNotification(
        'records',
        <dynamic>[
          <dynamic>[],
          <dynamic>[
            <dynamic>[
              positional.$1.$1,
              positional.$1.$2,
            ],
            positional.$2,
            positional.$3,
            positional.$4,
            positional.$5?.map(($e) => $e.name).toList(growable: false),
          ],
          <String, dynamic>{
            'color': named.color,
            'name': named.name,
            'permissions':
                named.permissions.map(($e) => $e?.name).toList(growable: false),
            'point': <String, dynamic>{
              'x': named.point.x,
              'y': named.point.y,
            },
            'user': named.user,
          },
        ],
      );
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
  FutureOr<void> simpleNamedServer(
    bool a,
    num? b,
    int c,
    double? d,
    String e,
  );
  @protected
  FutureOr<void> simplePositionalClient(
    bool a,
    num? b,
    int c,
    double? d,
    String e,
  );
  @protected
  FutureOr<void> simpleNamedClient(
    bool a,
    num? b,
    int c,
    double? d,
    String e,
  );
  @protected
  FutureOr<void> containers(
    Iterable<String> names,
    List<int> bytes,
    Map<String, bool> features,
    Map<List<String>, Iterable<Map<dynamic, List<num>>>> deep,
  );
  @protected
  FutureOr<void> custom(
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
      User? user
    }) named,
  );
  @override
  @visibleForOverriding
  @mustCallSuper
  void registerMethods() {
    super.registerMethods();
    jsonRpcInstance.registerMethod(
      'simplePositionalServer',
      (Parameters $params) async {
        final $$a = $params[0].asBool;
        final $$b = $params[1].$nullOr(($v) => $v.asNum);
        final $$c = $params[2].asIntOr(42);
        final $$d = $params[3].$maybeNullOr(($v) => $v.asNum)?.toDouble();
        final $$e = $params[4].asStringOr('default');
        await simplePositionalServer(
          $$a,
          $$b,
          $$c,
          $$d,
          $$e,
        );
      },
    );
    jsonRpcInstance.registerMethod(
      'simpleNamedServer',
      (Parameters $params) async {
        final $$a = $params['a'].asBool;
        final $$b = $params['b'].$nullOr(($v) => $v.asNum);
        final $$c = $params['c'].asIntOr(42);
        final $$d = $params['d'].$maybeNullOr(($v) => $v.asNum)?.toDouble();
        final $$e = $params['e'].asStringOr('default');
        await simpleNamedServer(
          $$a,
          $$b,
          $$c,
          $$d,
          $$e,
        );
      },
    );
    jsonRpcInstance.registerMethod(
      'simplePositionalClient',
      (Parameters $params) async {
        final $$a = $params[0].asBool;
        final $$b = $params[1].$nullOr(($v) => $v.asNum);
        final $$c = $params[2].asInt;
        final $$d = $params[3].$nullOr(($v) => $v.asNum)?.toDouble();
        final $$e = $params[4].asString;
        await simplePositionalClient(
          $$a,
          $$b,
          $$c,
          $$d,
          $$e,
        );
      },
    );
    jsonRpcInstance.registerMethod(
      'simpleNamedClient',
      (Parameters $params) async {
        final $$a = $params['a'].asBool;
        final $$b = $params['b'].$nullOr(($v) => $v.asNum);
        final $$c = $params['c'].asInt;
        final $$d = $params['d'].$nullOr(($v) => $v.asNum)?.toDouble();
        final $$e = $params['e'].asString;
        await simpleNamedClient(
          $$a,
          $$b,
          $$c,
          $$d,
          $$e,
        );
      },
    );
    jsonRpcInstance.registerMethod(
      'containers',
      (Parameters $params) async {
        final $$names = $params[0].asList.map((dynamic $e) => ($e as String));
        final $$bytes =
            $params[1].asList.map((dynamic $e) => ($e as int)).toList();
        final $$features = $params[2].asMap.map((
              dynamic $k,
              dynamic $v,
            ) =>
                MapEntry(
                  ($k as String),
                  ($v as bool),
                ));
        final $$deep = $params[3].asMap.map((
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
                            ($v as List)
                                .map((dynamic $e) => ($e as num))
                                .toList(),
                          ))),
                ));
        await containers(
          $$names,
          $$bytes,
          $$features,
          $$deep,
        );
      },
    );
    jsonRpcInstance.registerMethod(
      'custom',
      (Parameters $params) async {
        final $$user =
            User.fromJson(($params[0].value as Map<String, dynamic>));
        final $$color = $params[1].$maybeOr(
          ($v) => Color.fromJson(($v.value as String)),
          const Color(255, 255, 255),
        );
        final $$permission = $params[2].$maybeOr(
          ($v) => Permission.values.byName($v.asString),
          Permission.readOnly,
        );
        await custom(
          $$user,
          $$color,
          $$permission,
        );
      },
    );
    jsonRpcInstance.registerMethod(
      'customContainers',
      (Parameters $params) async {
        final $$users = $params['users']
            .asList
            .map((dynamic $e) => User.fromJson(($e as Map<String, dynamic>)));
        final $$colorPermissions = $params['colorPermissions'].$maybeOr(
          ($v) => $v.asMap.map((
            dynamic $k,
            dynamic $v,
          ) =>
              MapEntry(
                Color.fromJson(($k as String)),
                ($v as List)
                    .map((dynamic $e) =>
                        Permission.values.byName(($e as String)))
                    .toList(),
              )),
          const {
            Color(0, 0, 0): [Permission.readWrite]
          },
        );
        await customContainers(
          $$users,
          $$colorPermissions,
        );
      },
    );
    jsonRpcInstance.registerMethod(
      'records',
      (Parameters $params) async {
        final $$empty = _$map(
          $params[0].asList,
          ($v) => (),
        );
        final $$positional = _$map(
          $params[1].asList,
          ($v) => (
            _$map(
              ($v[0] as List),
              ($v) => (($v[0] as int), ($v[1] as int)),
            ),
            ($v[1] as String),
            _$maybeMap(
              $v[2],
              ($v) => Color.fromJson(($v as String)),
            ),
            User.fromJson(($v[3] as Map<String, dynamic>)),
            ($v[4] as List?)
                ?.map((dynamic $e) => Permission.values.byName(($e as String)))
                .toList()
          ),
        );
        final $$named = _$map(
          $params[2].asMap,
          ($v) => (
            color: Color.fromJson(($v['color'] as String)),
            name: ($v['name'] as String),
            permissions:
                ($v['permissions'] as List).map((dynamic $e) => _$maybeMap(
                      $e,
                      ($v) => Permission.values.byName(($v as String)),
                    )),
            point: _$map(
              ($v['point'] as Map),
              ($v) => (x: ($v['x'] as int), y: ($v['y'] as int)),
            ),
            user: _$maybeMap(
              $v['user'],
              ($v) => User.fromJson(($v as Map<String, dynamic>)),
            )
          ),
        );
        await records(
          $$empty,
          $$positional,
          $$named,
        );
      },
    );
  }
}
TConverted _$map<TConverted extends Object, TJson extends Object>(
  TJson $value,
  TConverted Function(TJson) $convert,
) =>
    $convert($value);
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
