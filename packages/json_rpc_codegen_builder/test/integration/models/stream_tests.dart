import 'package:json_rpc_codegen/json_rpc_codegen.dart';

import 'common.dart';

part 'stream_tests.g.dart';

@jsonRpc
// ignore: unused_element
abstract class _StreamTests {
  Stream<int> simple();

  Stream<String> positionalServer(
    String variant,
    User user, [
    List<int> levels = const [5, 75],
    Permission permission = Permission.readOnly,
    Uri? reference,
    Color color = const Color(255, 255, 255),
  ]);
}
