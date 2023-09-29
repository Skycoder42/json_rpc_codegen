import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import '../common/annotations.dart';
import '../common/method_mapper_mixin.dart';
import '../common/serialization_mixin.dart';
import '../common/types.dart';
import '../proxy_spec.dart';
import 'wrapper_builder_mixin.dart';

/// @nodoc
@internal
final class ClientGenerator extends ProxySpec
    with MethodMapperMixin, SerializationMixin, WrapperBuilderMixin {
  static const _clientName = 'jsonRpcClient';

  final ClassElement _class;

  /// @nodoc
  const ClientGenerator(this._class);

  @override
  @visibleForOverriding
  Reference get clientRef => const Reference(_clientName);

  /// @nodoc
  @override
  Class build() => Class(
        (b) => b
          ..name = '${_class.name}Client'
          ..implements.add(TypeReference((b) => b..symbol = _class.name))
          ..fields.add(
            Field(
              (b) => b
                ..name = _clientName
                ..modifier = FieldModifier.final$
                ..type = Types.jsonRpc2Client,
            ),
          )
          ..constructors.addAll(buildConstructors())
          ..methods.addAll(_class.methods.map(_buildMethod))
          ..methods.addAll(buildWrapperMethods()),
      );

  Method _buildMethod(MethodElement method) {
    final returnType = getReturnType(method);
    if (returnType is VoidType) {
      return _buildNotificationMethod(method);
    } else {
      return _buildRequestMethod(method, returnType);
    }
  }

  Method _buildNotificationMethod(MethodElement method) => mapMethod(
        method,
        (b) => b
          ..returns = Types.$void
          ..annotations.add(Annotations.override)
          ..body = _buildNotificationBody(method),
      );

  Method _buildRequestMethod(MethodElement method, DartType returnType) =>
      mapMethod(
        method,
        (b) => b
          ..returns = Types.future(Types.fromDartType(returnType))
          ..modifier = MethodModifier.async
          ..annotations.add(Annotations.override)
          ..body = _buildRequestBody(method, returnType),
      );

  Code _buildNotificationBody(MethodElement method) => _buildMethodInvocation(
        clientRef.property('sendNotification'),
        method,
      ).code;

  Code _buildRequestBody(MethodElement method, DartType returnType) {
    final invocation = _buildMethodInvocation(
      clientRef.property('sendRequest'),
      method,
    );

    const resultVarRef = Reference(r'$result');
    return Block.of([
      declareFinal(resultVarRef.symbol!, type: Types.dynamic)
          .assign(invocation.awaited)
          .statement,
      fromJson(returnType, resultVarRef).returned.statement,
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
            for (final p in method.parameters) toJson(p.type, refer(p.name)),
          ],
          Types.dynamic,
        ),
      if (hasNamed)
        literalMap(
          {
            for (final p in method.parameters)
              literalString(p.name): toJson(p.type, refer(p.name)),
          },
          Types.string,
          Types.dynamic,
        ),
    ]);
  }
}
