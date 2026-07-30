// ignore_for_file: avoid_positional_boolean_parameters for testing

import 'package:json_rpc_codegen/json_rpc_codegen.dart';

import 'common.dart';

part 'parameter_tests.g.dart';

@jsonRpcMixins
abstract interface class ParameterTests {
  // test all supported parameter types
  Future<void> simplePositionalServer(
    bool a,
    num? b, [
    int c = 42,
    double? d,
    String? e = 'default',
  ]);

  Future<void> simpleNamedServer({
    required bool a,
    required num? b,
    int c = 42,
    double? d,
    String? e = 'default',
  });

  @clientDefaults
  Future<void> simplePositionalClient(
    bool a,
    num? b, [
    int c = 42,
    double? d,
    String? e = 'default',
  ]);

  @clientDefaults
  Future<void> simpleNamedClient({
    required bool a,
    required num? b,
    int c = 42,
    double? d,
    String? e = 'default',
  });

  Future<void> containers(
    Iterable<String> names,
    List<int> bytes,
    Map<String, bool> features,
    Map<String, Iterable<Map<dynamic, List<num>>>> deep,
  );

  Future<void> custom(
    User user, [
    Color color = const Color(255, 255, 255),
    Permission permission = Permission.readOnly,
  ]);

  Future<void> dotShorthands(
    User user, [
    Color color = const .new(255, 255, 255),
    Permission permission = .readOnly,
  ]);

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
  });

  Future<void> records(
    () empty,
    ((int, int), String, Color?, User, List<Permission>?) positional,
    ({
      ({int x, int y}) point,
      String name,
      Color color,
      User? user,
      Iterable<Permission?> permissions,
    })
    named,
  );
}
