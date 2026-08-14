import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:dart_test_tools/code_gen.dart';
import 'package:json_rpc_codegen/json_rpc_codegen.dart'
    show RpcMethod, RpcParam;
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import '../../extensions/parameter_extensions.dart';
import '../../readers/rpc_method_reader.dart';
import '../../readers/rpc_param_reader.dart';
import 'annotations.dart';

@internal
enum ParameterMode {
  none(false, false),
  positional(true, false),
  named(false, true);

  final bool hasPositional;
  final bool hasNamed;

  // ignore: avoid_positional_boolean_parameters for enum
  new(this.hasPositional, this.hasNamed);
}

@internal
enum ReturnKind { notification, request, stream }

@internal
base mixin MethodMapperMixin {
  @protected
  String rpcMethodName(MethodElement method, [String invocationSuffix = '']) =>
      '${RpcMethodReader.read(method)?.name ?? method.name!}$invocationSuffix';

  @protected
  String rpcParamName(FormalParameterElement param) =>
      RpcParamReader.read(param)?.name ?? param.name!;

  @protected
  ({DartType type, ReturnKind kind}) getReturnType(MethodElement method) {
    final returnType = method.returnType;

    if (returnType is VoidType) {
      _validateNoConverters(method);
      return (type: returnType, kind: .notification);
    }

    if (returnType case InterfaceType(
      isDartAsyncFutureOr: true,
      typeArguments: [final futureType],
    )) {
      _throwNotAFuture(method, futureType);
    }

    if (returnType case InterfaceType(
      isDartAsyncStream: true,
      typeArguments: [final streamType],
    )) {
      return (type: streamType, kind: .stream);
    }

    if (!returnType.isDartAsyncFuture) {
      _throwNotAFuture(method, returnType);
    }

    final futureType = (returnType as InterfaceType).typeArguments.single;

    if (futureType is VoidType) {
      _validateNoConverters(method);
    }

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
    }

    for (final param in method.formalParameters.where((e) => e.isPositional)) {
      if (RpcParamReader.read(param)?.name != null) {
        throw InvalidGenerationSourceError(
          'The name of the $RpcParam annotation can only be used on named '
          'parameters, as positional parameters are transmitted as a list.',
          element: param,
          todo: 'Remove the name or make the parameter named.',
        );
      }
    }

    if (hasPositional) {
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

  /// Ensures [method] has no conversion functions, as it returns nothing.
  void _validateNoConverters(MethodElement method) {
    if (RpcMethodReader.read(method)?.hasConverters ?? false) {
      throw InvalidGenerationSourceError(
        'The conversion functions of the $RpcMethod annotation cannot be used '
        'on methods that do not return a value.',
        element: method,
        todo: 'Remove the fromJson and toJson functions.',
      );
    }
  }

  Never _throwNotAFuture(MethodElement method, DartType displayType) =>
      throw InvalidGenerationSourceError(
        'The return type of RPC methods must be a Future or void!',
        element: method,
        todo:
            'Change return type to '
            'Future<${displayType.getDisplayString()}>.',
      );

  Parameter _buildParameter(FormalParameterElement parameter) => Parameter(
    (b) => b
      ..name = parameter.name!
      ..type = parameter.type.toReference()
      ..named = parameter.isNamed
      ..required = parameter.isRequiredNamed
      ..covariant = parameter.isCovariant
      ..defaultTo = parameter.defaultValueCodeOrNull,
  );
}
