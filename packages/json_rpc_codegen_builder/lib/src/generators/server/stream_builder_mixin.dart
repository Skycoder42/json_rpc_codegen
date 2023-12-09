import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../common/closure_builder_mixin.dart';
import '../common/constants.dart';
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
        buildRegisterMethodWithParams(
          '${method.name}#listen',
          (params) => Block.of(_buildListenInvocation(method, params)),
        ),
        _buildSubscriptionRegistration(method, 'cancel', removeSub: true),
        _buildSubscriptionRegistration(method, 'pause'),
        _buildSubscriptionRegistration(method, 'resume'),
      ]);

  Iterable<Code> _buildListenInvocation(
    MethodElement method,
    Reference params,
  ) sync* {
    final parameterMode = validateParameters(method);
    final index = switch (parameterMode) {
      ParameterMode.named => _streamIdRef,
      _ => literalNum(0),
    };

    yield declareFinal(_streamIdRef.symbol!)
        .assign(params.index(index).property('asInt'))
        .statement;

    yield _subscriptionsMapRef.property('update').call([
      _streamIdRef,
      closure1(
        '_',
        (p1) => Types.jsonRpc2RpcException
            .newInstance([
              JsonRpcInstance.serverError,
              literalString(
                'streamId \${${_streamIdRef.symbol}} is already in use',
              ),
            ])
            .thrown
            .code,
      ),
    ], {
      'ifAbsent': closure0(
        () => Block.of(_buildStreamInvocation(method, parameterMode, params)),
      ),
    }).statement;
  }

  Iterable<Code> _buildStreamInvocation(
    MethodElement method,
    ParameterMode parameterMode,
    Reference params,
  ) sync* {
    if (parameterMode.hasPositional) {
      yield* method.parameters
          .mapIndexed((i, e) => buildPositional(params, i + 1, e));
    }
    if (parameterMode.hasNamed) {
      yield* method.parameters.map((e) => buildNamed(params, e));
    }
    yield refer(method.name)
        .call([
          for (final p in method.parameters) paramRefFor(p),
        ])
        .property('listen')
        .call([
          closure1('_', (p1) => Block.of([])), // TODO
        ])
        .returned
        .statement;
  }

  Code _buildSubscriptionRegistration(
    MethodElement method,
    String name, {
    bool removeSub = false,
  }) =>
      buildRegisterMethodWithParams(
        '${method.name}#$name',
        (params) =>
            Block.of(_buildSubscriptionInvocation(name, params, removeSub)),
      );

  Iterable<Code> _buildSubscriptionInvocation(
    String name,
    Reference params,
    bool removeSub,
  ) sync* {
    yield declareFinal(_streamIdRef.symbol!)
        .assign(params.index(literalNum(0)).property('asInt'))
        .statement;

    if (removeSub) {
      yield _subscriptionsMapRef
          .property('remove')
          .call(const [_streamIdRef])
          .nullSafeProperty(name)
          .call(const [])
          .returned
          .statement;
    } else {
      yield _subscriptionsMapRef
          .index(_streamIdRef)
          .nullSafeProperty(name)
          .call(const []).statement;
    }
  }
}
