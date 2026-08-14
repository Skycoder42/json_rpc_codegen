// ignore_for_file: unreachable_from_main for testing

import 'package:json_rpc_codegen/json_rpc_codegen.dart';

part 'json_rpc_codegen_builder_example.g.dart';

enum Permission { read, write, administrate }

enum Stage { all, pre, post }

class User {
  final String firstName;
  final String lastName;

  const new(this.firstName, this.lastName);

  factory fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError(json.toString());
}

@jsonRpc
abstract interface class SampleApi {
  void hello(String name, [int times = 5, double? interval, int delay = 100]);

  @clientDefaults
  void notify({required int id, List<double> measures = const [1, 2]});

  Future<String> echo(String message);

  Future<User?> createUser(Map<String, Set<Permission>?> permissions);

  Future<List<List<User>?>> userMatrix([Permission? permission]);

  Future<Map<String, List<Permission>>> permissions();

  Future<void> setHomepage({required Uri url, DateTime? timestamp});

  Future<Uri> findForDates(Iterable<DateTime> times);

  @clientDefaults
  void log(
    String message,
    dynamic context, [
    User user = const User('admin', 'admin'),
  ]);

  Future<bool> validate({
    User user = const .new('admin', 'admin'),
    required User? authorizeFor,
    Permission permission = .administrate,
    List<Uri>? resources = const <Uri>[],
  });

  // ignore: no_raw_types, strict_raw_type to test type defaults
  Future<Map> merge(Set keys, Iterable values);

  Future<(int, List<User>?, Permission, ({int x, int y}))> flip(
    ({int am, List<User>? ul, Permission pm, (int, int) pt}) record,
    () control,
  );

  void startServerTask({
    required int id,
    required String taskName,
    bool verbose = false,
    double? scale,
  });

  @clientDefaults
  Future<double> getProgress(int id, [Stage stage = .all]);

  Stream<User> streamUsers(
    Permission permission, [
    int limit = 10,
    int offset = 0,
  ]);

  @RpcMethod(name: 'user.rename')
  Future<void> renameUser({
    @RpcParam(name: 'user-id') required int id,
    @RpcParam(name: 'new-name') required String name,
  });

  // custom conversion via a constructor tear off and top level functions
  @RpcMethod(name: 'user.load', fromJson: User.fromJson, toJson: userToJson)
  Future<User> loadUser(
    @RpcParam(fromJson: stageFromCode, toJson: stageToCode) Stage stage, [
    @RpcParam(fromJson: permissionsFromMask, toJson: permissionsToMask)
    Set<Permission> permissions = const <Permission>{},
  ]);

  @RpcMethod(fromJson: User.fromJson, toJson: userToJson)
  Stream<User> streamAdmins({
    @RpcParam(name: 'min-level', fromJson: stageFromCode, toJson: stageToCode)
    Stage stage = .all,
  });
}

Map<String, dynamic> userToJson(User user) => {
  'firstName': user.firstName,
  'lastName': user.lastName,
};

int stageToCode(Stage stage) => stage.index;

Stage stageFromCode(int code) => Stage.values[code];

int permissionsToMask(Set<Permission> permissions) =>
    permissions.fold(0, (mask, permission) => mask | (1 << permission.index));

Set<Permission> permissionsFromMask(int mask) => Permission.values
    .where((permission) => mask & (1 << permission.index) != 0)
    .toSet();

void main() {}
