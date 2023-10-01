// ignore_for_file: unreachable_from_main

import 'package:json_rpc_codegen/json_rpc_codegen.dart';

part 'json_rpc_codegen_builder_example.g.dart';

enum Permission {
  read,
  write,
  administrate,
}

class User {
  final String firstName;
  final String lastName;

  const User(this.firstName, this.lastName);

  factory User.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError(json.toString());
}

@jsonRpc
abstract interface class SampleApi {
  FutureOr<void> hello(String name, [int times = 1]);

  FutureOr<void> notify({
    required int id,
    List<double>? measures,
  });

  FutureOr<String> echo(String message);

  FutureOr<User?> createUser(Map<String, List<Permission>?> permissions);

  FutureOr<List<List<User>?>> userMatrix([Permission? permission]);

  FutureOr<Map<String, List<Permission>>> permissions();

  FutureOr<void> setHomepage(Uri url, [DateTime? timestamp]);

  FutureOr<Uri> findForDates(Iterable<DateTime> times);

  FutureOr<void> log(String message, dynamic context);
}

void main() {}
