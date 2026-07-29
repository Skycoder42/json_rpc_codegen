// ignore_for_file: unused_element for testing

import 'package:json_rpc_codegen/json_rpc_codegen.dart';

part 'empty.g.dart';

@jsonRpc
abstract class _TestEmpty1 {}

@jsonRpcMixins
abstract class _TestEmpty2 {}

@JsonRpc(client: false, server: false)
abstract class _TestEmpty3 {}

@JsonRpc(client: false, server: false, mixinsOnly: true)
abstract class _TestEmpty4 {}

@JsonRpc(client: false)
abstract class _TestEmpty5 {}

@JsonRpc(client: false, mixinsOnly: true)
abstract class _TestEmpty6 {}

@JsonRpc(server: false)
abstract class _TestEmpty7 {}

@JsonRpc(server: false, mixinsOnly: true)
abstract class _TestEmpty8 {}

@JsonRpc()
abstract class _TestEmpty9 {}

@JsonRpc(mixinsOnly: true)
abstract class _TestEmpty10 {}
