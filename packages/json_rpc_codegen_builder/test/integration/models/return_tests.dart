import 'package:json_rpc_codegen/json_rpc_codegen.dart';

import 'common.dart';

part 'return_tests.g.dart';

@jsonRpcMixins
abstract class _ReturnTests {
  bool boolRet();

  num? numRet();

  int intRet();

  double? doubleRet();

  String stringRet();

  DateTime dateTimeRet();

  Uri uriRet();

  dynamic dynamicRet();

  List<int> listRet();

  Iterable<bool> iterableRet();

  Set<String> setRet();

  Map<String, double> mapRet();

  Map<List<String>, Iterable<Map<dynamic, List<num>>>> deepRet();

  User userRet();

  Color colorRet();

  Permission permissionRet();

  Iterable<User> usersRet();

  Map<Color, List<Permission>> colorPermissionsRet();

  (int?, Permission, Iterable<User?>, ({int x, int y})) posRecordRet();

  ({double r, Color c, Map<String, String?>? d, (int, int) p}) namedRecordRet();
}
