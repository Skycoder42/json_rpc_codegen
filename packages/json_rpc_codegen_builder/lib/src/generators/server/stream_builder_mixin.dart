import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../../builders/for_in.dart';
import '../common/closure_builder_mixin.dart';
import '../common/constants.dart';
import '../common/method_mapper_mixin.dart';
import '../common/parameter_builder_mixin.dart';
import '../common/registration_builder_mixin.dart';
import '../common/serialization_mixin.dart';
import '../common/types.dart';

@internal
base mixin StreamBuilderMixin
    on
        MethodMapperMixin,
        ClosureBuilderMixin,
        SerializationMixin,
        RegistrationBuilderMixin,
        ParameterBuilderMixin {
  static const _subscriptionsMapRef = Reference(r'_$streamSubscriptions');
  static const _streamIdRef = Reference(r'$streamId');
  static const _subscriptionRef = Reference(r'$subscription');

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
          async: false,
          (params) => Block.of(_buildListenInvocation(method, params)),
        ),
        _buildSubscriptionRegistration(method, 'cancel', remove: true),
        _buildSubscriptionRegistration(method, 'pause'),
        _buildSubscriptionRegistration(method, 'resume'),
      ]);

  Iterable<Code> buildStreamCleanupMethod(ClassElement clazz) sync* {
    if (!hasStreams(clazz)) {
      return;
    }

    yield JsonRpcInstance.ref.property('done').property('then').call([
      closure1(
        '_',
        (_) => Block.of([
          ForIn(
            _subscriptionRef.symbol!,
            _subscriptionsMapRef.property('values'),
            Globals.unawaitedRef.call([
              _subscriptionRef.property('cancel').call(const []),
            ]).statement,
          ),
          _subscriptionsMapRef.property('clear').call(const []).statement,
        ]),
      ),
    ]).statement;
  }

  DartType _streamType(MethodElement method) => getReturnType(
        method,
        (method.returnType as InterfaceType).typeArguments.single,
      );

  Iterable<Code> _buildListenInvocation(
    MethodElement method,
    Reference params,
  ) sync* {
    final parameterMode = validateParameters(method);
    final index = switch (parameterMode) {
      ParameterMode.named => literalString(_streamIdRef.symbol!, raw: true),
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
          _buildOnData(method),
        ], {
          'onError': _buildOnError(method),
          'onDone': _buildOnDone(method),
          'cancelOnError': literalFalse,
        })
        .returned
        .statement;
  }

  Code _buildSubscriptionRegistration(
    MethodElement method,
    String name, {
    bool remove = false,
  }) =>
      buildRegisterMethodWithParams(
        '${method.name}#$name',
        async: false,
        (params) => _buildSubscriptionInvocation(name, params, remove).code,
      );

  Expression _buildSubscriptionInvocation(
    String name,
    Reference params,
    bool remove,
  ) {
    final streamIdRef = params.index(literalNum(0)).property('asInt');
    if (remove) {
      return _subscriptionsMapRef
          .property('remove')
          .call([streamIdRef])
          .nullSafeProperty(name)
          .call(const []);
    } else {
      return _subscriptionsMapRef
          .index(streamIdRef)
          .nullSafeProperty(name)
          .call(const []);
    }
  }

  Expression _buildOnData(MethodElement method) => closure1(
        r'$data',
        (dataRef) => JsonRpcInstance.sendNotification.call([
          literalString('${method.name}#data'),
          literalList(
            [
              _streamIdRef,
              toJson(_streamType(method), dataRef),
            ],
            Types.dynamic,
          ),
        ]).code,
      );

  Expression _buildOnError(MethodElement method) => closure2(
        type1: Types.object,
        r'$error',
        type2: Types.stackTrace,
        r'$stackTrace',
        (errorRef, stackTraceRef) => JsonRpcInstance.sendNotification.call([
          literalString('${method.name}#error'),
          errorRef
              .isA(Types.jsonRpc2RpcException)
              .conditional(
                errorRef,
                Types.jsonRpc2RpcException.newInstance(
                  [
                    JsonRpcInstance.serverError,
                    JsonRpcInstance.getErrorMessage.call([errorRef]),
                  ],
                  {
                    'data': literalMap({
                      'full': errorRef.property('toString').call(const []),
                      'stack': Types.stackTraceChain
                          .newInstanceNamed('forTrace', [stackTraceRef])
                          .property('toString')
                          .call(const []),
                    }),
                  },
                ),
              )
              .parenthesized
              .property('serialize')
              .call([
            literalString('${method.name}#\${${_streamIdRef.symbol}}'),
          ]).index(
            literalString('error'),
          ),
        ]).code,
      );

  Expression _buildOnDone(MethodElement method) => closure0(
        () => Block.of([
          JsonRpcInstance.sendNotification.call([
            literalString('${method.name}#done'),
            literalList([_streamIdRef]),
          ]).statement,
          _subscriptionsMapRef
              .property('remove')
              .call([_streamIdRef])
              .nullSafeProperty('cancel')
              .call(const [])
              .statement,
        ]),
      );
}
