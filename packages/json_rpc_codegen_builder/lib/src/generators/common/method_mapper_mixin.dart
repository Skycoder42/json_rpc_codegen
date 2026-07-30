import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:dart_test_tools/code_gen.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import '../proxy_spec.dart';
import 'annotations.dart';

@internal
enum ParameterMode {
  none(false, false),
  positional(true, false),
  named(false, true);

  final bool hasPositional;
  final bool hasNamed;

  // ignore: avoid_positional_boolean_parameters for enum
  const ParameterMode(this.hasPositional, this.hasNamed);
}

@internal
enum ReturnKind { notification, request, stream }

@internal
base mixin MethodMapperMixin on ProxySpec {
  @protected
  ({DartType type, ReturnKind kind}) getReturnType(
    MethodElement method, [
    DartType? returnType,
  ]) {
    final actualReturnType = returnType ?? method.returnType;

    if (actualReturnType is VoidType) {
      return (type: actualReturnType, kind: .notification);
    }

    if (actualReturnType case InterfaceType(
      isDartAsyncFutureOr: true,
      typeArguments: [final futureType],
    )) {
      throw InvalidGenerationSourceError(
        'The return type of RPC methods must be a Future or void!',
        element: method,
        todo:
            'Change return type to '
            'Future<${futureType.getDisplayString()}>.',
      );
    }

    if (actualReturnType case InterfaceType(
      isDartAsyncStream: true,
      typeArguments: [final streamType],
    )) {
      return (type: streamType, kind: .stream);
    }

    if (!actualReturnType.isDartAsyncFuture) {
      throw InvalidGenerationSourceError(
        'The return type of RPC methods must be a Future or void!',
        element: method,
        todo:
            'Change return type to '
            'Future<${actualReturnType.getDisplayString()}>.',
      );
    }

    final futureType = (actualReturnType as InterfaceType).typeArguments.single;

    if (futureType.isDartCoreType ||
        futureType.isDartCoreSymbol ||
        futureType.isDartCoreFunction ||
        futureType.isDartCoreNull ||
        futureType.isDartAsyncFuture ||
        futureType.isDartAsyncStream ||
        futureType.isDartAsyncFutureOr) {
      throw InvalidGenerationSourceError(
        'The return type of RPC methods cannot be a '
        '${futureType.getDisplayString()}',
        element: method,
      );
    }

    return (type: futureType, kind: .request);
  }

  @protected
  ParameterMode validateParameters(MethodElement method) {
    final hasPositional = method.formalParameters.any((e) => e.isPositional);
    final hasNamed = method.formalParameters.any((e) => e.isNamed);

    if (hasPositional && hasNamed) {
      throw InvalidGenerationSourceError(
        'An RPC method can have only either named or positional parameters, '
        'not both',
        element: method,
        todo: 'Make all parameters positional or named',
      );
    } else if (hasPositional) {
      return .positional;
    } else if (hasNamed) {
      return .named;
    } else {
      return .none;
    }
  }

  @protected
  Method mapMethod(
    MethodElement method, {
    required void Function(MethodBuilder b) buildMethod,
  }) => Method((b) {
    if (method.typeParameters.isNotEmpty) {
      throw InvalidGenerationSourceError(
        'An RPC method cannot have generic type parameters!',
        element: method,
        todo: 'Remove all generic parameters',
      );
    }

    b
      ..name = method.name
      ..returns = method.returnType.toReference()
      ..annotations.add(Annotations.override)
      ..requiredParameters.addAll(
        method.formalParameters
            .where((p) => p.isRequiredPositional)
            .map(_buildParameter),
      )
      ..optionalParameters.addAll(
        method.formalParameters
            .whereNot((p) => p.isRequiredPositional)
            .map(_buildParameter),
      );
    buildMethod(b);
  });

  Parameter _buildParameter(FormalParameterElement parameter) => Parameter(
    (b) => b
      ..name = parameter.name!
      ..type = parameter.type.toReference()
      ..named = parameter.isNamed
      ..required = parameter.isRequiredNamed
      ..covariant = parameter.isCovariant
      ..defaultTo = parameter.hasDefaultValue
          ? Code(parameter.defaultValueCode!)
          : null,
  );
}
