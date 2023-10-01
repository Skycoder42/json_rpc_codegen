import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../common/closure_builder_mixin.dart';
import '../common/method_mapper_mixin.dart';
import '../common/serialization_mixin.dart';
import '../common/types.dart';
import '../proxy_spec.dart';

/// @nodoc
@internal
final class ClientMixinBuilder extends ProxySpec
    with MethodMapperMixin, ClosureBuilderMixin, SerializationMixin {
  static const _rpcGetterRef = Reference('jsonRpcInstance');

  final ClassElement _class;

  /// @nodoc
  const ClientMixinBuilder(this._class);

  /// @nodoc
  @override
  Mixin build() => Mixin(
        (b) => b
          ..name = '${_class.name}ClientMixin'
          ..on = Types.clientBase
          ..implements.add(Types.fromClass(_class))
          ..methods.addAll(_class.methods.map(_buildMethod)),
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
          ..body = _buildNotificationBody(method),
      );

  Method _buildRequestMethod(MethodElement method, DartType returnType) =>
      mapMethod(
        method,
        (b) => b
          ..returns = Types.future(Types.fromDartType(returnType))
          ..modifier = MethodModifier.async
          ..body = _buildRequestBody(method, returnType),
      );

  Code _buildNotificationBody(MethodElement method) => _buildMethodInvocation(
        _rpcGetterRef.property('sendNotification'),
        method,
      ).code;

  Code _buildRequestBody(MethodElement method, DartType returnType) {
    final invocation = _buildMethodInvocation(
      _rpcGetterRef.property('sendRequest'),
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
    final parameterMode = validateParameters(method);
    return target.call([
      literalString(method.name),
      if (parameterMode.hasPositional)
        literalList(
          [
            for (final p in method.parameters) toJson(p.type, refer(p.name)),
          ],
          Types.dynamic,
        ),
      if (parameterMode.hasNamed)
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
