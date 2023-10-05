import 'package:json_rpc_codegen/json_rpc_codegen.dart';

part 'empty.g.dart';

@jsonRpc
abstract interface class TestEmpty1 {}

@jsonRpcMixins
abstract interface class TestEmpty2 {}

@JsonRpc(client: false, server: false, mixinsOnly: false)
abstract interface class TestEmpty3 {}

@JsonRpc(client: false, server: false, mixinsOnly: true)
abstract interface class TestEmpty4 {}

@JsonRpc(client: false, server: true, mixinsOnly: false)
abstract interface class TestEmpty5 {}

@JsonRpc(client: false, server: true, mixinsOnly: true)
abstract interface class TestEmpty6 {}

@JsonRpc(client: true, server: false, mixinsOnly: false)
abstract interface class TestEmpty7 {}

@JsonRpc(client: true, server: false, mixinsOnly: true)
abstract interface class TestEmpty8 {}

@JsonRpc(client: true, server: true, mixinsOnly: false)
abstract interface class TestEmpty9 {}

@JsonRpc(client: true, server: true, mixinsOnly: true)
abstract interface class TestEmpty10 {}
