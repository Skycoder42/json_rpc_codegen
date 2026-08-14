import 'package:analyzer/dart/element/element.dart';
import 'package:json_rpc_codegen/json_rpc_codegen.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

@internal
class JsonRpcReader {
  static const typeChecker = TypeChecker.typeNamed(
    JsonRpc,
    inPackage: 'json_rpc_codegen',
  );

  final ConstantReader _reader;

  const new(this._reader);

  factory from(Element element) =>
      JsonRpcReader(ConstantReader(typeChecker.firstAnnotationOf(element)));

  bool get client => _reader.read('client').boolValue;

  bool get server => _reader.read('server').boolValue;

  bool get mixinsOnly => _reader.read('mixinsOnly').boolValue;
}
