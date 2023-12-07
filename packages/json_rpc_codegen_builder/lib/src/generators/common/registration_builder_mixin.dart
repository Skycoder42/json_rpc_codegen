import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart' hide RecordType;
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'annotations.dart';
import 'closure_builder_mixin.dart';
import 'method_mapper_mixin.dart';
import 'parameter_builder_mixin.dart';
import 'types.dart';

@internal
base mixin RegistrationBuilderMixin
    on MethodMapperMixin, ClosureBuilderMixin, ParameterBuilderMixin {
  Method buildRegisterMethods(Iterable<Code> methods) => Method(
        (b) => b
          ..name = 'registerMethods'
          ..returns = Types.$void
          ..annotations.add(Annotations.override)
          ..annotations.add(Annotations.visibleForOverriding)
          ..annotations.add(Annotations.mustCallSuper)
          ..body = Block.of([
            refer('super').property('registerMethods').call(const []).statement,
            ...methods,
          ]),
      );

  Code buildRegisterMethod(
    Reference jsonRpcInstance,
    MethodElement method, {
    String invocationSuffix = '',
  }) {
    final parameterMode = validateParameters(method);

    return jsonRpcInstance.property('registerMethod').call([
      literalString('${method.name}$invocationSuffix'),
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
