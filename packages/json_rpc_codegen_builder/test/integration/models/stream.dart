import 'package:json_rpc_codegen/json_rpc_codegen.dart';

import 'common.dart';

part 'stream.g.dart';

@jsonRpc
// ignore: unused_element
abstract class _Stream {
  Stream<int> simple();

  Stream<String> positional(
    String variant,
    User user, [
    List<int> levels = const [5, 75],
    Permission permission = Permission.readOnly,
    Uri? reference,
    Color color = const Color(255, 255, 255),
  ]);

  Stream<(User, Permission)> named({
    required String variant,
    required User user,
    List<int> levels = const [5, 75],
    Permission permission = Permission.readOnly,
    Uri? reference,
    Color color = const Color(255, 255, 255),
  });
}
