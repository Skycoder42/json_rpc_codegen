import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../../builders/if.dart';
import '../../extensions/code_builder_extensions.dart';
import '../common/closure_builder_mixin.dart';
import '../common/method_mapper_mixin.dart';
import '../common/parameter_builder_mixin.dart';
import '../common/registration_builder_mixin.dart';
import '../common/types.dart';

@internal
base mixin StreamBuilderMixin
    on
        MethodMapperMixin,
        ClosureBuilderMixin,
        RegistrationBuilderMixin,
        ParameterBuilderMixin {
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
        ..name = _subscriptionsMapRef.symbol
        ..modifier = FieldModifier.final$
        ..assignment = literalMap(
          const {},
          Types.$int,
          Types.streamSubscription(),
        ).code,
    );
  }

  Code buildStreamRegistrations(MethodElement method) => Block.of([
        _buildStreamInvocationImpl(method),
      ]);

  Code _buildStreamInvocationImpl(MethodElement method) {
    final parameterMode = validateParameters(method);
    final index = switch (parameterMode) {
      ParameterMode.named => _streamIdRef,
      _ => literalNum(0),
    };

    return buildRegisterMethodWithParams(
      method.name,
      (params) => Block.of([
        declareFinal(_streamIdRef.symbol!)
            .assign(params.index(index).property('asInt'))
            .statement,
        if (parameterMode.hasPositional)
          ...method.parameters
              .mapIndexed((i, e) => buildPositional(params, i + 1, e)),
        if (parameterMode.hasNamed)
          ...method.parameters.map((e) => buildNamed(params, e)),
        ..._buildListenInvocation(method),
      ]),
    );
  }

  Iterable<Code> _buildListenInvocation(MethodElement method) sync* {
    yield _subscriptionsMapRef.property('update').call([
      _streamIdRef,
      closure1(
        '_',
        (p1) => Types.jsonRpc2RpcException
            .newInstance([
              literalNum(0), // TODO use error code
              literalString(
                'streamId \${${_streamIdRef.symbol}} is already in use!',
              ),
            ])
            .thrown
            .code,
      ),
    ], {
      'ifAbsent': closure0(() => Block.of(_buildStreamInvocation(method))),
    }).statement;
  }

  Iterable<Code> _buildStreamInvocation(MethodElement method) sync* {
    yield refer(method.name)
        .call([
          for (final p in method.parameters) paramRefFor(p),
        ])
        .property('listen')
        .call([
          closure1('_', (p1) => Block.of([])),
        ])
        .returned
        .statement;
  }
}
