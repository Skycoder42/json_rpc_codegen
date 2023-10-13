import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart' hide RecordType;
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../../extensions/analyzer_extensions.dart';
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
          ..name = '${_class.publicName}ServerMixin'
          ..on = Types.serverBase
          ..methods.addAll(
            _class.methods.map(
              (method) => mapMethod(
                method,
                buildMethod: (b) => b
                  ..annotations.add(Annotations.protected)
                  ..returns = Types.futureOr(b.returns),
                buildParam: (_, builder) => builder
                  ..named = false
                  ..required = false,
                checkRequired: (_) => true,
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
          () => Block.of(_buildInvocation(method)),
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
            ..._buildInvocation(method),
          ]),
        ),
    ]).statement;
  }

  Iterable<Code> _buildInvocation(
    MethodElement method,
  ) sync* {
    final invocation = refer(method.name).call([
      for (final p in method.parameters) paramRefFor(p),
    ]);

    if (method.returnType is VoidType || method.returnType.isDartCoreNull) {
      yield invocation.awaited.statement;
      return;
    }

    final returnType = getReturnType(method);
    if (returnType is RecordType) {
      const resultRef = Reference(r'$result');
      yield declareFinal(resultRef.symbol!)
          .assign(invocation.awaited)
          .statement;
      yield toJson(returnType, resultRef).returned.statement;
    } else {
      yield toJson(
        returnType,
        invocation.awaited.parenthesized,
      ).returned.statement;
    }
  }
}
