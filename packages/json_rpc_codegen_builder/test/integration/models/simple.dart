import 'package:json_rpc_codegen/json_rpc_codegen.dart';

part 'simple.g.dart';

enum Category { catA, catB, catC }

@jsonRpc
// ignore: unused_element for testing
abstract class _Simple {
  @clientDefaults
  void notify(String message, [int level = 10]);

  Future<double> request({
    required int id,
    Category? category,
    String user = 'self',
  });
}
