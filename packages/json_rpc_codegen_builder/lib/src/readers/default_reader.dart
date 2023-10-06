import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:json_rpc_codegen/json_rpc_codegen.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

/// @nodoc
@internal
class DefaultReader {
  final Code valueCode;

  const DefaultReader._(this.valueCode);

  static DefaultReader? client(ParameterElement param) => _find(
        param,
        const TypeChecker.fromRuntime(ClientDefault),
        '$ClientDefault'.length,
      );

  static DefaultReader? server(ParameterElement param) => _find(
        param,
        const TypeChecker.fromRuntime(ServerDefault),
        '$ServerDefault'.length,
      );

  static DefaultReader? _find(
    ParameterElement param,
    TypeChecker typeChecker,
    int offset,
  ) {
    for (final annotation in param.metadata) {
      final computed = annotation.computeConstantValue();
      if (annotation.constantEvaluationErrors?.isNotEmpty ?? false) {
        throw InvalidGenerationSourceError(
          annotation.constantEvaluationErrors!.first.toString(),
          element: param,
          todo: annotation.constantEvaluationErrors!.first.correction ?? '',
        );
      }
      if (!typeChecker.isExactlyType(computed!.type!)) {
        continue;
      }

      computed.hasKnownValue;

      var source = annotation.toSource();
      source = source.substring(offset + 2, source.length - 1);

      final valueReader = ConstantReader(computed).read('value');
      final needsConstModifier = valueReader.isList ||
          valueReader.isMap ||
          valueReader.isSet ||
          valueReader.isSymbol ||
          !valueReader.isLiteral;
      if (needsConstModifier && !source.trimLeft().startsWith('const')) {
        source = 'const $source';
      }

      return DefaultReader._(Code(source));
    }

    return null;
  }
}
