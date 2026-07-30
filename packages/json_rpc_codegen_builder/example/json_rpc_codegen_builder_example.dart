// ignore_for_file: unreachable_from_main for testing

import 'package:json_rpc_codegen/json_rpc_codegen.dart';

part 'json_rpc_codegen_builder_example.g.dart';

enum Permission { read, write, administrate }

enum Stage { all, pre, post }

class User {
  final String firstName;
  final String lastName;

  const User(this.firstName, this.lastName);

  factory User.fromJson(Map<String, dynamic> json) =>
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

  // ignore: strict_raw_type to test type defaults
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
}

void main() {}
