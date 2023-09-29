import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import '../proxy_spec.dart';
import 'types.dart';

/// @nodoc
@internal
base mixin MethodMapperMixin on ProxySpec {
  /// @nodoc
  @protected
  DartType getReturnType(MethodElement method) {
    if (!method.returnType.isDartAsyncFutureOr) {
      throw InvalidGenerationSourceError(
        'The return type of RPC methods must be FutureOr<T>',
        element: method,
        // ignore: missing_whitespace_between_adjacent_strings
        todo: 'Change return type to FutureOr'
            '<${method.returnType.getDisplayString(withNullability: true)}>',
      );
    }

    return (method.returnType as InterfaceType).typeArguments.single;
  }

  /// @nodoc
  @protected
  Method mapMethod(
    MethodElement method,
    MethodBuilder Function(MethodBuilder b) build,
  ) =>
      Method((b) {
        if (method.typeParameters.isNotEmpty) {
          throw InvalidGenerationSourceError(
            'An RPC method cannot have generic type parameters!',
            element: method,
            todo: 'Remove all generic parameters',
          );
        }

        b
          ..name = method.name
          ..returns = Types.fromDartType(method.returnType)
          ..requiredParameters.addAll(
            method.parameters
                .where((e) => e.isRequiredPositional)
                .map((e) => _buildParameter(e, true)),
          )
          ..optionalParameters.addAll(
            method.parameters
                .where((e) => !e.isRequiredPositional)
                .map((e) => _buildParameter(e, false)),
          );
        build(b);
      });

  Parameter _buildParameter(ParameterElement parameter, bool positional) =>
      Parameter(
        (b) => b
          ..name = parameter.name
          ..type = Types.fromDartType(parameter.type)
          ..named = parameter.isNamed
          ..required = parameter.isRequiredNamed
          ..covariant = parameter.isCovariant
          ..defaultTo = parameter.hasDefaultValue
              ? Code(parameter.defaultValueCode!)
              : null,
      );
}
