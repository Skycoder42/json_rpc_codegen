import 'package:json_rpc_codegen/json_rpc_codegen.dart';

import 'common.dart';

part 'return_tests.g.dart';

@jsonRpcMixins
abstract interface class ReturnTests {
  Future<bool> boolRet();

  Future<num?> numRet();

  Future<int> intRet();

  Future<double?> doubleRet();

  Future<String> stringRet();

  Future<DateTime> dateTimeRet();

  Future<Uri> uriRet();

  Future<dynamic> dynamicRet();

  Future<List<int>> listRet();

  Future<Iterable<bool>> iterableRet();

  Future<Set<String>> setRet();

  Future<Map<String, double>> mapRet();

  Future<Map<String, Iterable<Map<dynamic, List<num>>>>> deepRet();

  Future<User> userRet();

  Future<Color?> colorRet();

  Future<Permission> permissionRet();

  Future<Iterable<User>> usersRet();

  Future<Map<dynamic, List<Permission>>> colorPermissionsRet();

  Future<(int?, Permission, Iterable<User?>, ({int x, int y}))> posRecordRet();

  Future<({double r, Color c, Map<String, String?>? d, (int, int) p})>
  namedRecordRet();

  @RpcMethod(fromJson: colorFromRgb, toJson: colorToRgb)
  Future<Color> customRet();

  @RpcMethod(
    name: 'custom-nullable-ret',
    fromJson: colorFromRgb,
    toJson: colorToRgb,
  )
  Future<Color?> customNullableRet();

  @RpcMethod(fromJson: PermissionCodec.fromCode, toJson: PermissionCodec.toCode)
  Future<Permission> customPermissionRet();

  @RpcMethod(fromJson: doubleFromFixed, toJson: doubleToFixed)
  Future<double> customPrimitiveRet();
}
