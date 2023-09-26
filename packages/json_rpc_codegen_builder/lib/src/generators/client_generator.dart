import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import 'proxy_spec.dart';

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
                ..type = TypeReference(
                  (b) => b
                    ..symbol = 'Client'
                    ..url = 'package:json_rpc_2/json_rpc_2.dart',
                ),
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
          ..returns = TypeReference((b) => b..symbol = 'void')
          ..body = _buildNotificationBody(method),
      );

  Method _buildRequestMethod(MethodElement method) => Method(
        (b) => _buildMethodBase(method, b)
          ..returns = _buildType(method.returnType)
          ..modifier = MethodModifier.async
          ..body = _buildRequestBody(method),
      );

  MethodBuilder _buildMethodBase(MethodElement method, MethodBuilder builder) =>
      builder
        ..name = method.name
        ..types.addAll(method.typeParameters.map(_buildTypeParameter))
        ..requiredParameters.addAll(
          method.parameters
              .where((e) => e.isRequiredPositional)
              .map((e) => _buildParameter(e, true)),
        )
        ..optionalParameters.addAll(
          method.parameters
              .where((e) => !e.isRequiredPositional)
              .map((e) => _buildParameter(e, false)),
        )
        ..annotations.add(const Reference('override'));

  Parameter _buildParameter(ParameterElement parameter, bool positional) =>
      Parameter(
        (b) => b
          ..name = parameter.name
          ..type = _buildType(parameter.type)
          ..named = parameter.isNamed
          ..required = parameter.isRequiredNamed
          ..covariant = parameter.isCovariant
          ..defaultTo = parameter.hasDefaultValue
              ? Code(parameter.defaultValueCode!)
              : null,
      );

  TypeReference _buildType(DartType dartType) => TypeReference(
        (b) {
          b
            ..symbol = dartType.element!.name
            ..isNullable = dartType.nullabilitySuffix != NullabilitySuffix.none
            ..url = dartType.element?.library?.location?.components.firstOrNull;

          if (dartType is InterfaceType) {
            b.types.addAll(dartType.typeArguments.map(_buildType));
          }
        },
      );

  TypeReference _buildTypeParameter(TypeParameterElement typeParameter) =>
      TypeReference(
        (b) => b
          ..symbol = typeParameter.name
          ..bound = typeParameter.bound != null
              ? _buildType(typeParameter.bound!)
              : null,
      );

  Method _buildBatchMethod() => Method(
        (b) => b
          ..name = 'withBatch'
          ..returns = TypeReference((b) => b..symbol = 'void')
          ..requiredParameters.add(
            Parameter(
              (b) => b
                ..name = 'callback'
                ..type = TypeReference((b) => b..symbol = 'Function()'),
            ),
          )
          ..body = _clientRef.property('withBatch').call([
            refer('callback'),
          ]).code,
      );

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

    return Block.of([
      declareFinal('result', type: refer('dynamic'))
          .assign(invocation.awaited)
          .statement,
      _buildReturn(refer('result'), futureType).returned.statement,
    ]);
  }

  Expression _buildReturn(
    Expression value,
    DartType type,
  ) {
    if (type.isDartCoreIterable || type.isDartCoreList) {
      final interfaceType = type as InterfaceType;
      final listType = interfaceType.typeArguments.single;
      final iterable = value.asA(refer('List')).property('map').call([
        Method(
          (b) => b
            ..requiredParameters.add(
              Parameter(
                (b) => b
                  ..name = 'e'
                  ..type = refer('dynamic'),
              ),
            )
            ..body = _buildReturn(refer('e'), listType).code,
        ).closure,
      ]);

      return type.isDartCoreList
          ? iterable.property('toList').call(const [])
          : iterable;
    } else if (type.isDartCorePrimitive) {
      return value.asA(_buildType(type));
    } else {
      return _buildType(type).newInstanceNamed('fromJson', [
        value.asA(refer('Map<String, dynamic>')),
      ]);
    }
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
          TypeReference((b) => b..symbol = 'dynamic'),
        ),
      if (hasNamed)
        literalMap(
          {
            for (final p in method.parameters)
              literalString(p.name): refer(p.name),
          },
          TypeReference((b) => b..symbol = 'String'),
          TypeReference((b) => b..symbol = 'dynamic'),
        ),
    ]);
  }
}

extension DartTypeX on DartType {
  bool get isDartCorePrimitive =>
      isDartCoreBool ||
      isDartCoreDouble ||
      isDartCoreInt ||
      isDartCoreMap ||
      isDartCoreNull ||
      isDartCoreNum ||
      isDartCoreString;
}
