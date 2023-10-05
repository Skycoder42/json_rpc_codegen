import 'package:json_rpc_codegen/json_rpc_codegen.dart';

import 'common.dart';

part 'return_tests.g.dart';

@jsonRpcMixins
abstract interface class ReturnTests {
  FutureOr<bool> boolRet();

  FutureOr<num?> numRet();

  FutureOr<int> intRet();

  FutureOr<double?> doubleRet();

  FutureOr<String> stringRet();

  FutureOr<List<int>> listRet();

  FutureOr<Iterable<bool>> iterableRet();

  FutureOr<Map<String, double>> mapRet();

  FutureOr<Map<List<String>, Iterable<Map<dynamic, List<num>>>>> deepRet();

  FutureOr<User> userRet();

  FutureOr<Color> colorRet();

  FutureOr<Permission> permissionRet();

  FutureOr<Iterable<User>> usersRet();

  FutureOr<Map<Color, List<Permission>>> colorPermissionsRet();
}
