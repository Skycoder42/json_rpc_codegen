import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import '../proxy_spec.dart';
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
    if (method.returnType.isDartAsyncFuture ||
        method.returnType.isDartAsyncFutureOr) {
      final futureType =
          (method.returnType as InterfaceType).typeArguments.single;
      throw InvalidGenerationSourceError(
        'The return type of RPC methods must be not be a Future or FutureOr!',
        element: method,
        todo: 'Change return type to '
            '${futureType.getDisplayString(withNullability: true)}.',
      );
    }

    if (method.returnType.isDartCoreFunction) {
      throw InvalidGenerationSourceError(
        'The return type of RPC methods cannot be a function!',
        element: method,
      );
    }

    if (method.returnType.isDartCoreType ||
        method.returnType.isDartCoreSymbol) {
      throw InvalidGenerationSourceError(
        'The return type of RPC methods cannot be a '
        '${method.returnType.getDisplayString(withNullability: false)}',
        element: method,
      );
    }

    return method.returnType;
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
    MethodElement method, {
    required void Function(MethodBuilder b) buildMethod,
    required void Function(ParameterElement param, ParameterBuilder b)
        buildParam,
    bool Function(ParameterElement param) checkRequired = _defaultCheckRequired,
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
          ..requiredParameters.addAll(
            method.parameters
                .where(checkRequired)
                .map((e) => _buildParameter(e, buildParam)),
          )
          ..optionalParameters.addAll(
            method.parameters
                .whereNot(checkRequired)
                .map((e) => _buildParameter(e, buildParam)),
          );
        buildMethod(b);
      });

  Parameter _buildParameter(
    ParameterElement parameter,
    void Function(ParameterElement param, ParameterBuilder b) buildParam,
  ) =>
      Parameter(
        (b) {
          b
            ..name = parameter.name
            ..type = Types.fromDartType(parameter.type)
            ..named = parameter.isNamed
            ..required = parameter.isRequiredNamed
            ..covariant = parameter.isCovariant;

          buildParam(parameter, b);
        },
      );

  static bool _defaultCheckRequired(ParameterElement param) =>
      param.isRequiredPositional;
}
