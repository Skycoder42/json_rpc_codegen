// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parameter_tests.dart';

// **************************************************************************
// JsonRpcGenerator
// **************************************************************************

// ignore_for_file: type=lint, unused_element

mixin ParameterTestsClientMixin on ClientBase implements ParameterTests {
  @override
  void simplePositional(
    bool a,
    num? b, [
    int c = 42,
    double? d,
    String? e = 'default',
  ]) =>
      jsonRpcInstance.sendNotification(
        'simplePositional',
        <dynamic>[
          a,
          b,
          c,
          d,
          e,
        ],
      );
  @override
  void simpleNamed({
    required bool a,
    required num? b,
    int c = 42,
    double? d,
    String? e = 'default',
  }) =>
      jsonRpcInstance.sendNotification(
        'simpleNamed',
        <String, dynamic>{
          'a': a,
          'b': b,
          'c': c,
          'd': d,
          'e': e,
        },
      );
  @override
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
  @override
  void custom(
    User user, [
    Color color = const Color(255, 255, 255),
    Permission permission = Permission.readOnly,
  ]) =>
      jsonRpcInstance.sendNotification(
        'custom',
        <dynamic>[
          user,
          color,
          permission.name,
        ],
      );
  @override
  void customContainers({
    required Iterable<User> users,
    Map<Color, List<Permission>> colorPermissions = const {
      Color(0, 0, 0): [Permission.readWrite]
    },
  }) =>
      jsonRpcInstance.sendNotification(
        'customContainers',
        <String, dynamic>{
          'users': users.toList(growable: false),
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
}
mixin ParameterTestsServerMixin on ServerBase implements ParameterTests {
  @override
  @protected
  FutureOr<void> simplePositional(
    bool a,
    num? b, [
    int c = 42,
    double? d,
    String? e = 'default',
  ]);
  @override
  @protected
  FutureOr<void> simpleNamed({
    required bool a,
    required num? b,
    int c = 42,
    double? d,
    String? e = 'default',
  });
  @override
  @protected
  FutureOr<void> containers(
    Iterable<String> names,
    List<int> bytes,
    Map<String, bool> features,
    Map<List<String>, Iterable<Map<dynamic, List<num>>>> deep,
  );
  @override
  @protected
  FutureOr<void> custom(
    User user, [
    Color color = const Color(255, 255, 255),
    Permission permission = Permission.readOnly,
  ]);
  @override
  @protected
  FutureOr<void> customContainers({
    required Iterable<User> users,
    Map<Color, List<Permission>> colorPermissions = const {
      Color(0, 0, 0): [Permission.readWrite]
    },
  });
  @override
  @visibleForOverriding
  @mustCallSuper
  void registerMethods() {
    super.registerMethods();
    jsonRpcInstance.registerMethod(
      'simplePositional',
      (Parameters $params) async {
        final $$a = $params[0].asBool;
        final $$b = $params[1].$nullOr(($v) => $v.asNum);
        final $$c = $params[2].asIntOr(42);
        final $$d = $params[3]
            .$maybeNullOr(
              ($v) => $v.asNum,
              null,
            )
            ?.toDouble();
        final $$e = $params[4].$maybeNullOr(
          ($v) => $v.asString,
          'default',
        );
        return (await simplePositional(
          $$a,
          $$b,
          $$c,
          $$d,
          $$e,
        ));
      },
    );
    jsonRpcInstance.registerMethod(
      'simpleNamed',
      (Parameters $params) async {
        final $$a = $params['a'].asBool;
        final $$b = $params['b'].$nullOr(($v) => $v.asNum);
        final $$c = $params['c'].asIntOr(42);
        final $$d = $params['d']
            .$maybeNullOr(
              ($v) => $v.asNum,
              null,
            )
            ?.toDouble();
        final $$e = $params['e'].$maybeNullOr(
          ($v) => $v.asString,
          'default',
        );
        return (await simpleNamed(
          a: $$a,
          b: $$b,
          c: $$c,
          d: $$d,
          e: $$e,
        ));
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
        return (await containers(
          $$names,
          $$bytes,
          $$features,
          $$deep,
        ));
      },
    );
    jsonRpcInstance.registerMethod(
      'custom',
      (Parameters $params) async {
        final $$user =
            User.fromJson(($params[0].value as Map<String, dynamic>));
        final $$color = Color.fromJson(
            ($params[1].valueOr(const Color(255, 255, 255)) as String));
        final $$permission = Permission.values
            .byName($params[2].asStringOr(Permission.readOnly));
        return (await custom(
          $$user,
          $$color,
          $$permission,
        ));
      },
    );
    jsonRpcInstance.registerMethod(
      'customContainers',
      (Parameters $params) async {
        final $$users = $params['users']
            .asList
            .map((dynamic $e) => User.fromJson(($e as Map<String, dynamic>)));
        final $$colorPermissions = $params['colorPermissions'].asMapOr(const {
          Color(0, 0, 0): [Permission.readWrite]
        }).map((
          dynamic $k,
          dynamic $v,
        ) =>
            MapEntry(
              Color.fromJson(($k as String)),
              ($v as List)
                  .map((dynamic $e) => Permission.values.byName(($e as String)))
                  .toList(),
            ));
        return (await customContainers(
          users: $$users,
          colorPermissions: $$colorPermissions,
        ));
      },
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
