import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import 'annotations.dart';
import 'closure_builder_mixin.dart';
import 'constants.dart';
import 'types.dart';

@internal
base mixin RegistrationBuilderMixin on ClosureBuilderMixin {
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

  Code buildRegisterMethodWithParams(
    String methodName,
    Code Function(Reference params) buildBody, {
    bool async = true,
  }) =>
      JsonRpcInstance.registerMethod.call([
        literalString(methodName),
        closure1(
          r'$params',
          type1: Types.jsonRpc2Parameters,
          modifier: async ? MethodModifier.async : null,
          buildBody,
        ),
      ]).statement;

  Code buildRegisterMethodWithoutParams(
    String methodName,
    Code Function() buildBody, {
    bool async = true,
  }) =>
      JsonRpcInstance.registerMethod.call([
        literalString(methodName),
        closure0(
          modifier: async ? MethodModifier.async : null,
          buildBody,
        ),
      ]).statement;
}
