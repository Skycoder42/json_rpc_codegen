import 'package:analyzer/dart/element/element.dart';
import 'package:json_rpc_codegen/json_rpc_codegen.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

@internal
abstract base class NameReader {
  static const _methodTypeChecker = TypeChecker.typeNamed(
    MethodName,
    inPackage: 'json_rpc_codegen',
  );
  static const _paramTypeChecker = TypeChecker.typeNamed(
    ParamName,
    inPackage: 'json_rpc_codegen',
  );

  NameReader._();

  /// The [MethodName] annotation of [method], or `null` if not annotated.
  static MethodName? methodName(MethodElement method) =>
      switch (_read(_methodTypeChecker, method)) {
        final name? => MethodName(name),
        _ => null,
      };

  /// The [ParamName] annotation of [param], or `null` if not annotated.
  static ParamName? paramName(FormalParameterElement param) =>
      switch (_read(_paramTypeChecker, param)) {
        final name? => ParamName(name),
        _ => null,
      };

  static String? _read(TypeChecker typeChecker, Element element) {
    final annotation = typeChecker.firstAnnotationOf(element);
    if (annotation == null) {
      return null;
    }

    return ConstantReader(annotation).read('name').stringValue;
  }
}
