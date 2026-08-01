import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_test_tools/code_gen.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

/// A custom conversion function declared via an annotation.
@internal
final class RpcConverter {
  /// The expression referencing the conversion function.
  final Expression function;

  /// The JSON side type of the conversion.
  final DartType jsonType;

  /// Default constructor.
  const RpcConverter({required this.function, required this.jsonType});
}

/// The custom conversion functions declared by an annotation.
@internal
typedef RpcConverters = ({RpcConverter? fromJson, RpcConverter? toJson});

/// Reads the [field] of [annotation] as [RpcConverter], or `null` if unset.
///
/// The JSON side type of the converter is the type of it's single parameter for
/// [isFromJson] converters and it's return type for the others. [element] is
/// only used to report errors.
@internal
RpcConverter? readRpcConverter(
  ConstantReader annotation,
  String field,
  Element element, {
  required bool isFromJson,
}) {
  final reader = annotation.read(field);
  if (reader.isNull) {
    return null;
  }

  final function = reader.objectValue.toFunctionValue();
  if (function == null) {
    throw InvalidGenerationSourceError(
      'The $field of the annotation must be a reference to a top level '
      'function, a static method or a constructor.',
      element: element,
      todo: 'Replace the value with a function reference.',
    );
  }

  final parameters = function.formalParameters;
  if (parameters.isEmpty ||
      !parameters.first.isRequiredPositional ||
      parameters.skip(1).any((p) => p.isRequired)) {
    final name = switch (function) {
      ConstructorElement(:final Element enclosingElement) ||
      MethodElement(
        enclosingElement: final Element enclosingElement?,
      ) => '${enclosingElement.name}.${function.name}',
      _ => function.name,
    };
    throw InvalidGenerationSourceError(
      'The $field function must accept at least one required, positional '
      'parameter and only optional parameters, but $name does not.',
      element: element,
      todo: 'Change the signature of $name.',
    );
  }

  return RpcConverter(
    function: function.toExpression(),
    jsonType: isFromJson ? parameters.first.type : function.returnType,
  );
}
