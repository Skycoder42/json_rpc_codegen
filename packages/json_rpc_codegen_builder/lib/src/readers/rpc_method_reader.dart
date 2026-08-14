import 'package:analyzer/dart/element/element.dart';
import 'package:json_rpc_codegen/json_rpc_codegen.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import 'rpc_converter.dart';

@internal
abstract base class RpcMethodReader {
  static const _typeChecker = TypeChecker.typeNamed(
    RpcMethod,
    inPackage: 'json_rpc_codegen',
  );

  new _();

  /// The [RpcMethod] annotation of [method], or `null` if not annotated.
  ///
  /// The conversion functions of the annotation cannot be revived and are
  /// exposed via [RpcMethodConvertersX] instead.
  static RpcMethod? read(MethodElement method) {
    final annotation = _typeChecker.firstAnnotationOf(method);
    if (annotation == null) {
      return null;
    }

    final reader = ConstantReader(annotation);
    final name = reader.read('name');
    // must never be const - the instance identity keys the converter expando
    final rpcMethod = RpcMethod(name: name.isNull ? null : name.stringValue);
    RpcMethodConvertersX._expando[rpcMethod] = (
      fromJson: readRpcConverter(reader, 'fromJson', method, isFromJson: true),
      toJson: readRpcConverter(reader, 'toJson', method, isFromJson: false),
    );
    return rpcMethod;
  }
}

/// Provides the conversion functions of an [RpcMethod] read by
/// [RpcMethodReader].
@internal
extension RpcMethodConvertersX on RpcMethod {
  static final _expando = Expando<RpcConverters>();

  /// The custom deserialization function, or `null` if not set.
  RpcConverter? get fromJsonConverter => _expando[this]?.fromJson;

  /// The custom serialization function, or `null` if not set.
  RpcConverter? get toJsonConverter => _expando[this]?.toJson;

  /// Whether any custom conversion function was set.
  bool get hasConverters =>
      fromJsonConverter != null || toJsonConverter != null;
}
