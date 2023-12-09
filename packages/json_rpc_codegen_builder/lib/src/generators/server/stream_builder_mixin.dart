import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../../extensions/code_builder_extensions.dart';
import '../common/closure_builder_mixin.dart';
import '../common/method_mapper_mixin.dart';
import '../common/types.dart';

@internal
base mixin StreamBuilderMixin on MethodMapperMixin, ClosureBuilderMixin {
  static const _streamIdCounterRef = Reference(r'_$streamIdCounter');
  static const _subscriptionsMapRef = Reference(r'_$streamSubscriptions');
  static const _streamIdRef = Reference(r'$streamId');

  static bool hasStreams(ClassElement clazz) =>
      clazz.methods.any((m) => m.returnType.isDartAsyncStream);

  Iterable<Field> buildStreamFields(ClassElement clazz) sync* {
    if (!hasStreams(clazz)) {
      return;
    }

    yield Field(
      (b) => b
        ..name = _streamIdCounterRef.symbol
        ..assignment = literalNum(0).code,
    );

    yield Field(
      (b) => b
        ..name = _subscriptionsMapRef.symbol
        ..modifier = FieldModifier.final$
        ..assignment = literalMap(
          const {},
          Types.$int,
          Types.streamSubscription(),
        ).code,
    );
  }

  Code buildStreamInvocation(MethodElement method, Expression invocation) =>
      Block.of(_buildStreamInvocationImpl(method, invocation));

  Iterable<Code> _buildStreamInvocationImpl(
    MethodElement method,
    Expression invocation,
  ) sync* {
    yield declareFinal(_streamIdRef.symbol!)
        .assign(_streamIdCounterRef.postfixIncrement)
        .statement;
    yield _subscriptionsMapRef
        .index(_streamIdRef)
        .assign(
          invocation.property('listen').call([
            closure1('_', (p1) => Block.of([])),
          ]),
        )
        .statement;
    yield _streamIdRef.returned.statement;
  }
}
