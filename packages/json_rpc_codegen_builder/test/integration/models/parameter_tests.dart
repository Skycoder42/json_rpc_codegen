import 'package:json_rpc_codegen/json_rpc_codegen.dart';

import 'common.dart';

part 'parameter_tests.g.dart';

@jsonRpcMixins
// ignore: unused_element
abstract class _ParameterTests {
  // test all supported parameter types
  void simplePositionalServer(
    bool a,
    num? b, [
    int c = 42,
    double? d,
    String e = 'default',
  ]);

  void simpleNamedServer({
    required bool a,
    required num? b,
    int c = 42,
    double? d,
    String e = 'default',
  });

  @clientDefaults
  void simplePositionalClient(
    bool a,
    num? b, [
    int c = 42,
    double? d,
    String e = 'default',
  ]);

  @clientDefaults
  void simpleNamedClient({
    required bool a,
    required num? b,
    int c = 42,
    double? d,
    String e = 'default',
  });

  void containers(
    Iterable<String> names,
    List<int> bytes,
    Map<String, bool> features,
    Map<List<String>, Iterable<Map<dynamic, List<num>>>> deep,
  );

  void custom(
    User user, [
    Color color = const Color(255, 255, 255),
    Permission permission = Permission.readOnly,
  ]);

  void customContainers({
    required Iterable<User> users,
    Map<Color, List<Permission>> colorPermissions = const {
      Color(0, 0, 0): [Permission.readWrite],
    },
  });

  void records(
    () empty,
    ((int, int), String, Color?, User, List<Permission>?) positional,
    ({
      ({int x, int y}) point,
      String name,
      Color color,
      User? user,
      Iterable<Permission?> permissions
    }) named,
  );
}
