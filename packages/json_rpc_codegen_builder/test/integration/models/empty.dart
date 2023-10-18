// ignore_for_file: unused_element

import 'package:json_rpc_codegen/json_rpc_codegen.dart';

part 'empty.g.dart';

@jsonRpc
abstract class _TestEmpty1 {}

@jsonRpcMixins
abstract class _TestEmpty2 {}

@JsonRpc(client: false, server: false, mixinsOnly: false)
abstract class _TestEmpty3 {}

@JsonRpc(client: false, server: false, mixinsOnly: true)
abstract class _TestEmpty4 {}

@JsonRpc(client: false, server: true, mixinsOnly: false)
abstract class _TestEmpty5 {}

@JsonRpc(client: false, server: true, mixinsOnly: true)
abstract class _TestEmpty6 {}

@JsonRpc(client: true, server: false, mixinsOnly: false)
abstract class _TestEmpty7 {}

@JsonRpc(client: true, server: false, mixinsOnly: true)
abstract class _TestEmpty8 {}

@JsonRpc(client: true, server: true, mixinsOnly: false)
abstract class _TestEmpty9 {}

@JsonRpc(client: true, server: true, mixinsOnly: true)
abstract class _TestEmpty10 {}
