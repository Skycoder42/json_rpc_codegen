import 'package:json_rpc_codegen/json_rpc_codegen.dart';

part 'json_rpc_codegen_builder_example.g.dart';

class User {
  final String firstName;
  final String lastName;

  const User(this.firstName, this.lastName);

  factory User.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError(json.toString());
}

@jsonRpc
abstract interface class SampleApi {
  void hello(String name, [int times = 1]);

  void notifyGeneric<T1, T2 extends num>({
    required T1 data,
    List<T2>? measures,
  });

  Future<String> echo(String message);

  Future<User> createUser();

  Future<List<List<User>>> userMatric();

  Future<Map<String, User>> userGroups();
}

void main() {}
