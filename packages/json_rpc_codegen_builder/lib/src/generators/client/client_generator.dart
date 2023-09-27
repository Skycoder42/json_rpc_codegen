import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import '../common/annotations.dart';
import '../common/serialization_builder.dart';
import '../common/types.dart';
import '../proxy_spec.dart';

/// @nodoc
@internal
final class ClientGenerator extends ProxySpec {
  static const _clientName = '_jsonRpcClient';
  static const _clientRef = Reference(_clientName);

  final ClassElement _class;

  /// @nodoc
  const ClientGenerator(this._class);

  /// @nodoc
  @override
  Class build() => Class(
        (b) => b
          ..name = '${_class.name}Client'
          ..implements.add(refer(_class.name))
          ..fields.add(
            Field(
              (b) => b
                ..name = _clientName
                ..modifier = FieldModifier.final$
                ..type = Types.jsonRpc2Client,
            ),
          )
          ..constructors.add(
            Constructor(
              (b) => b
                ..constant = true
                ..requiredParameters.add(
                  Parameter(
                    (b) => b
                      ..name = _clientName
                      ..toThis = true,
                  ),
                ),
            ),
          )
          ..methods.addAll(_class.methods.map(_buildMethod))
          ..methods.add(_buildBatchMethod()),
      );

  Method _buildMethod(MethodElement method) {
    if (method.returnType is VoidType) {
      return _buildNotificationMethod(method);
    } else if (method.returnType.isDartAsyncFuture ||
        method.returnType.isDartAsyncFutureOr) {
      return _buildRequestMethod(method);
    } else {
      throw InvalidGenerationSourceError(
        'The return type of RPC methods must be either '
        'void or Future<T> or FutureOr<T>',
        element: method,
        // ignore: missing_whitespace_between_adjacent_strings
        todo: 'Change the return type to void or to Future'
            '<${method.returnType.getDisplayString(withNullability: true)}>',
      );
    }
  }

  Method _buildNotificationMethod(MethodElement method) => Method(
        (b) => _buildMethodBase(method, b)
          ..returns = Types.$void
          ..body = _buildNotificationBody(method),
      );

  Method _buildRequestMethod(MethodElement method) => Method(
        (b) => _buildMethodBase(method, b)
          ..returns = Types.fromDartType(method.returnType)
          ..modifier = MethodModifier.async
          ..body = _buildRequestBody(method),
      );

  MethodBuilder _buildMethodBase(MethodElement method, MethodBuilder builder) =>
      builder
        ..name = method.name
        ..annotations.add(Annotations.override)
        ..types.addAll(method.typeParameters.map(Types.fromTypeParameter))
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

  Method _buildBatchMethod() {
    const callbackRef = Reference('callback');
    return Method(
      (b) => b
        ..name = 'withBatch'
        ..returns = Types.$void
        ..requiredParameters.add(
          Parameter(
            (b) => b
              ..name = callbackRef.symbol!
              ..type = Types.function0,
          ),
        )
        ..body = _clientRef.property('withBatch').call([
          callbackRef,
        ]).code,
    );
  }

  Code _buildNotificationBody(MethodElement method) => _buildMethodInvocation(
        _clientRef.property('sendNotification'),
        method,
      ).code;

  Code _buildRequestBody(MethodElement method) {
    final returnType = method.returnType as InterfaceType;
    final futureType = returnType.typeArguments.single;

    final invocation = _buildMethodInvocation(
      _clientRef.property('sendRequest'),
      method,
    );

    const resultVarRef = Reference('result');
    return Block.of([
      declareFinal(resultVarRef.symbol!, type: Types.dynamic)
          .assign(invocation.awaited)
          .statement,
      SerializationBuilder.fromJson(futureType, resultVarRef)
          .returned
          .statement,
    ]);
  }

  Expression _buildMethodInvocation(Expression target, MethodElement method) {
    final hasPositional = method.parameters.any((e) => e.isPositional);
    final hasNamed = method.parameters.any((e) => e.isNamed);
    if (hasPositional && hasNamed) {
      throw InvalidGenerationSourceError(
        'An RPC method can have only either named or positional parameters, '
        'not both',
        element: method,
        // ignore: missing_whitespace_between_adjacent_strings
        todo: 'Make all parameters positional or named',
      );
    }

    return target.call([
      literalString(method.name),
      if (hasPositional)
        literalList(
          [
            for (final p in method.parameters) refer(p.name),
          ],
          Types.dynamic,
        ),
      if (hasNamed)
        literalMap(
          {
            for (final p in method.parameters)
              literalString(p.name): refer(p.name),
          },
          Types.string,
          Types.dynamic,
        ),
    ]);
  }
}
