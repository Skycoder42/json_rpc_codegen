import 'package:json_rpc_codegen/json_rpc_codegen.dart';

part 'json_rpc_codegen_builder_example.g.dart';

@jsonRpc
abstract interface class SampleApi {
  void hello(String name, [int times = 1]);

  void notifyGeneric<T1, T2 extends num>(T1 data, List<T2> measures);
}

void main() {}
