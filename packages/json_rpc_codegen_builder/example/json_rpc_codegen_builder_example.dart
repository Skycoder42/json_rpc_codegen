// ignore_for_file: unreachable_from_main

import 'package:json_rpc_codegen/json_rpc_codegen.dart';

part 'json_rpc_codegen_builder_example.g.dart';

enum Permission {
  read,
  write,
  administrate,
}

enum Stage { all, pre, post }

class User {
  final String firstName;
  final String lastName;

  const User(this.firstName, this.lastName);

  factory User.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError(json.toString());
}

@jsonRpc
// ignore: unused_element
abstract class _SampleApi {
  void hello(
    String name, [
    int times = 5,
    double? interval,
    int delay = 100,
  ]);

  @clientDefaults
  void notify({
    required int id,
    List<double> measures = const [1, 2],
  });

  String echo(String message);

  User? createUser(Map<String, Set<Permission>?> permissions);

  List<List<User>?> userMatrix([Permission? permission]);

  Map<String, List<Permission>> permissions();

  // ignore: prefer_void_to_null
  Null setHomepage({required Uri url, DateTime? timestamp});

  Uri findForDates(Iterable<DateTime> times);

  @clientDefaults
  void log(
    String message,
    dynamic context, [
    User user = const User('admin', 'admin'),
  ]);

  bool validate({
    User user = const User('admin', 'admin'),
    required User? authorizeFor,
    Permission permission = Permission.administrate,
    List<Uri>? resources,
  });

  Map merge(Set keys, Iterable values);

  (int, List<User>?, Permission, (int, int)) flip(
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
  double getProgress(int id, [Stage stage = Stage.all]);

  Stream<User> streamUsers(
    Permission permission, [
    int limit = 10,
    int offset = 0,
  ]);
}

void main() {}
