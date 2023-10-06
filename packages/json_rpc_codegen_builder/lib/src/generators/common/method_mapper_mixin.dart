import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import '../proxy_spec.dart';
import 'annotations.dart';
import 'types.dart';

/// @nodoc
@internal
enum ParameterMode {
  /// @nodoc
  none(false, false),

  /// @nodoc
  positional(true, false),

  /// @nodoc
  named(false, true);

  /// @nodoc
  final bool hasPositional;

  /// @nodoc
  final bool hasNamed;

  const ParameterMode(this.hasPositional, this.hasNamed);
}

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
  ParameterMode validateParameters(MethodElement method) {
    final hasPositional = method.parameters.any((e) => e.isPositional);
    final hasNamed = method.parameters.any((e) => e.isNamed);

    if (hasPositional && hasNamed) {
      throw InvalidGenerationSourceError(
        'An RPC method can have only either named or positional parameters, '
        'not both',
        element: method,
        todo: 'Make all parameters positional or named',
      );
    } else if (hasPositional) {
      return ParameterMode.positional;
    } else if (hasNamed) {
      return ParameterMode.named;
    } else {
      return ParameterMode.none;
    }
  }

  /// @nodoc
  @protected
  Method mapMethod(
    MethodElement method,
    MethodBuilder Function(MethodBuilder b) build, {
    Code? Function(ParameterElement param)? defaultValueBuilder,
  }) =>
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
          ..annotations.add(Annotations.override)
          ..requiredParameters.addAll(
            method.parameters
                .where((e) => e.isRequiredPositional)
                .map((e) => _buildParameter(e, true, defaultValueBuilder)),
          )
          ..optionalParameters.addAll(
            method.parameters
                .where((e) => !e.isRequiredPositional)
                .map((e) => _buildParameter(e, false, defaultValueBuilder)),
          );
        build(b);
      });

  Parameter _buildParameter(
    ParameterElement parameter,
    bool positional,
    Code? Function(ParameterElement param)? defaultValueBuilder,
  ) {
    if (parameter.hasDefaultValue) {
      throw InvalidGenerationSourceError(
        'Cannot use normal default values on RPC method parameters. '
        'Must be provided via @ClientDefault or @ServerDefault.',
        element: parameter,
        todo: 'Pass the default value vie @ClientDefault or @ServerDefault.',
      );
    }

    return Parameter(
      (b) => b
        ..name = parameter.name
        ..type = Types.fromDartType(parameter.type)
        ..named = parameter.isNamed
        ..required = parameter.isRequiredNamed
        ..covariant = parameter.isCovariant
        ..defaultTo = defaultValueBuilder?.call(parameter),
    );
  }
}
