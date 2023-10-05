import 'package:json_rpc_codegen/json_rpc_codegen.dart';

import 'common.dart';

part 'parameter_tests.g.dart';

@jsonRpcMixins
abstract interface class ParameterTests {
  // test all supported parameter types
  FutureOr<void> simplePositional(
    bool a,
    num? b, [
    int c = 42,
    double? d,
    String? e = 'default',
  ]);

  FutureOr<void> simpleNamed({
    required bool a,
    required num? b,
    int c = 42,
    double? d,
    String? e = 'default',
  });

  FutureOr<void> containers(
    Iterable<String> names,
    List<int> bytes,
    Map<String, bool> features,
    Map<List<String>, Iterable<Map<dynamic, List<num>>>> deep,
  );

  FutureOr<void> custom(
    User user, [
    Color color = const Color(255, 255, 255),
    Permission permission = Permission.readOnly,
  ]);

  FutureOr<void> customContainers({
    required Iterable<User> users,
    Map<Color, List<Permission>> colorPermissions = const {
      Color(0, 0, 0): [Permission.readWrite],
    },
  });
}

// TODO fix defaults
