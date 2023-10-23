import 'package:json_rpc_codegen/json_rpc_codegen.dart';

part 'simple.g.dart';

enum Category {
  catA,
  catB,
  catC,
}

@jsonRpc
// ignore: unused_element
abstract class _Simple {
  @clientDefaults
  void notify(String message, [int level = 10]);

  double request({
    required int id,
    Category? category,
    String user = 'self',
  });
}
