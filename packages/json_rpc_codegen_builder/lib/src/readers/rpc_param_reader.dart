import 'package:analyzer/dart/element/element.dart';
import 'package:json_rpc_codegen/json_rpc_codegen.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import 'rpc_converter.dart';

@internal
abstract base class RpcParamReader {
  static const _typeChecker = TypeChecker.typeNamed(
    RpcParam,
    inPackage: 'json_rpc_codegen',
  );

  new _();

  /// The [RpcParam] annotation of [param], or `null` if not annotated.
  ///
  /// The conversion functions of the annotation cannot be revived and are
  /// exposed via [RpcParamConvertersX] instead.
  static RpcParam? read(FormalParameterElement param) {
    final annotation = _typeChecker.firstAnnotationOf(param);
    if (annotation == null) {
      return null;
    }

    final reader = ConstantReader(annotation);
    final name = reader.read('name');
    // must never be const - the instance identity keys the converter expando
    final rpcParam = RpcParam(name: name.isNull ? null : name.stringValue);
    RpcParamConvertersX._expando[rpcParam] = (
      fromJson: readRpcConverter(reader, 'fromJson', param, isFromJson: true),
      toJson: readRpcConverter(reader, 'toJson', param, isFromJson: false),
    );
    return rpcParam;
  }
}

/// Provides the conversion functions of an [RpcParam] read by [RpcParamReader].
@internal
extension RpcParamConvertersX on RpcParam {
  static final _expando = Expando<RpcConverters>();

  /// The custom deserialization function, or `null` if not set.
  RpcConverter? get fromJsonConverter => _expando[this]?.fromJson;

  /// The custom serialization function, or `null` if not set.
  RpcConverter? get toJsonConverter => _expando[this]?.toJson;
}
