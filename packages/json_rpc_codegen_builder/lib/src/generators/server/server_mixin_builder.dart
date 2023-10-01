import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart' hide ParameterBuilder;
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../common/annotations.dart';
import '../common/closure_builder_mixin.dart';
import '../common/method_mapper_mixin.dart';
import '../common/serialization_mixin.dart';
import '../common/types.dart';
import '../proxy_spec.dart';
import 'parameter_builder_mixin.dart';

/// @nodoc
@internal
final class ServerMixinBuilder extends ProxySpec
    with
        MethodMapperMixin,
        ClosureBuilderMixin,
        SerializationMixin,
        ParameterBuilderMixin {
  static const _rpcGetterRef = Reference('jsonRpcInstance');

  final ClassElement _class;

  /// @nodoc
  const ServerMixinBuilder(this._class);

  @override
  Mixin build() => Mixin(
        (b) => b
          ..name = '${_class.name}ServerMixin'
          ..on = Types.serverBase
          ..implements.add(TypeReference((b) => b..symbol = _class.name))
          ..methods.addAll(
            _class.methods.map(
              (method) => mapMethod(
                method,
                (b) => b..annotations.add(Annotations.protected),
              ),
            ),
          )
          ..methods.add(_buildRegisterMethod()),
      );

  Method _buildRegisterMethod() => Method(
        (b) => b
          ..name = 'registerMethods'
          ..returns = Types.$void
          ..annotations.add(Annotations.override)
          ..annotations.add(Annotations.visibleForOverriding)
          ..annotations.add(Annotations.mustCallSuper)
          ..body = Block.of([
            refer('super').property('registerMethods').call(const []).statement,
            ..._class.methods.map(_buildRegisterFor),
          ]),
      );

  Code _buildRegisterFor(MethodElement method) {
    final parameterMode = validateParameters(method);

    return _rpcGetterRef.property('registerMethod').call([
      literalString(method.name),
      if (parameterMode == ParameterMode.none)
        closure0(
          modifier: MethodModifier.async,
          () => _buildInvocation(method).code,
        )
      else
        closure1(
          r'$params',
          type1: Types.jsonRpc2Parameters,
          modifier: MethodModifier.async,
          (p1) => Block.of([
            if (parameterMode.hasPositional)
              ...method.parameters
                  .mapIndexed((i, e) => buildPositional(p1, i, e)),
            if (parameterMode.hasNamed)
              ...method.parameters.map((e) => buildNamed(p1, e)),
            _buildInvocation(method).returned.statement,
          ]),
        ),
    ]).statement;
  }

  Expression _buildInvocation(MethodElement method) {
    final invocation = refer(method.name).call(
      [
        for (final p in method.parameters.where((p) => p.isPositional))
          paramRefFor(p),
      ],
      {
        for (final p in method.parameters.where((p) => p.isNamed))
          p.name: paramRefFor(p),
      },
    );

    return toJson(
      getReturnType(method),
      invocation.awaited.parenthesized,
    );
  }
}
