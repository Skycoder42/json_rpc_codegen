import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:dart_test_tools/code_gen.dart';
import 'package:meta/meta.dart';

import '../common/closure_builder_mixin.dart';
import '../common/constants.dart';
import '../common/method_mapper_mixin.dart';
import '../common/parameter_builder_mixin.dart';
import '../common/registration_builder_mixin.dart';
import '../common/serialization_mixin.dart';
import '../common/stream_support.dart';
import '../common/types.dart';

@internal
base mixin ServerStreamBuilderMixin
    on
        MethodMapperMixin,
        ClosureBuilderMixin,
        SerializationMixin,
        RegistrationBuilderMixin,
        ParameterBuilderMixin,
        StreamSupportMixin {
  static const _subscriptionsMapRef = Reference(r'_$streamSubscriptions');
  static const _subscriptionRef = Reference(r'$subscription');

  Iterable<Field> buildStreamFields(ClassElement clazz) sync* {
    if (!StreamRpc.hasStreams(clazz)) {
      return;
    }

    yield Field(
      (b) => b
        ..name = _subscriptionsMapRef.symbol
        ..modifier = FieldModifier.final$
        ..assignment = literalMap(
          const {},
          CoreTypes.$int,
          Types.$StreamSubscription(CoreTypes.$dynamic),
        ).code,
    );
  }

  Code buildStreamRegistrations(MethodElement method, DartType streamType) =>
      Block.of([
        buildRegisterMethodWithParams(
          StreamRpc.methodName(method, StreamSubMethod.listen),
          async: false,
          (params) =>
              Block.of(_buildListenInvocation(method, streamType, params)),
        ),
        _buildSubscriptionRegistration(
          method,
          StreamSubMethod.cancel,
          remove: true,
        ),
        _buildSubscriptionRegistration(method, StreamSubMethod.pause),
        _buildSubscriptionRegistration(method, StreamSubMethod.resume),
      ]);

  Iterable<Code> buildStreamCleanupMethod(ClassElement clazz) =>
      buildStreamCleanup(
        clazz,
        map: _subscriptionsMapRef,
        itemRef: _subscriptionRef,
        dispose: 'cancel',
      );

  Iterable<Code> _buildListenInvocation(
    MethodElement method,
    DartType streamType,
    Reference params,
  ) sync* {
    final parameterMode = validateParameters(method);
    final index = switch (parameterMode) {
      ParameterMode.named => literalString(
        StreamRpc.streamIdRef.symbol!,
        raw: true,
      ),
      _ => literalNum(0),
    };

    yield declareFinal(
      StreamRpc.streamIdRef.symbol!,
    ).assign(streamIdFrom(params, index)).statement;

    yield _subscriptionsMapRef
        .property('update')
        .call(
          [
            StreamRpc.streamIdRef,
            closure1(
              '_',
              (p1) => Types.$RpcException
                  .newInstance([
                    JsonRpcInstance.serverError,
                    literalString(
                      'streamId \${${StreamRpc.streamIdRef.symbol}} '
                      'is already in use',
                    ),
                  ])
                  .thrown
                  .code,
            ),
          ],
          {
            'ifAbsent': closure0(
              () => Block.of(
                _buildStreamInvocation(
                  method,
                  streamType,
                  parameterMode,
                  params,
                ),
              ),
            ),
          },
        )
        .statement;
  }

  Iterable<Code> _buildStreamInvocation(
    MethodElement method,
    DartType streamType,
    ParameterMode parameterMode,
    Reference params,
  ) sync* {
    if (parameterMode.hasPositional) {
      yield* method.formalParameters.mapIndexed(
        (i, e) => buildPositional(params, i + 1, e),
      );
    }
    if (parameterMode.hasNamed) {
      yield* method.formalParameters.map((e) => buildNamed(params, e));
    }
    yield refer(method.name!)
        .call(
          [
            for (final p in method.formalParameters.where(
              (p) => p.isPositional,
            ))
              paramRefFor(p),
          ],
          {
            for (final p in method.formalParameters.where((p) => p.isNamed))
              p.name!: paramRefFor(p),
          },
        )
        .property('listen')
        .call(
          [_buildOnData(method, streamType)],
          {
            'onError': _buildOnError(method),
            'onDone': _buildOnDone(method),
            'cancelOnError': literalFalse,
          },
        )
        .returned
        .statement;
  }

  Code _buildSubscriptionRegistration(
    MethodElement method,
    StreamSubMethod subMethod, {
    bool remove = false,
  }) => buildRegisterMethodWithParams(
    StreamRpc.methodName(method, subMethod),
    async: false,
    (params) => _buildSubscriptionInvocation(subMethod, params, remove).code,
  );

  Expression _buildSubscriptionInvocation(
    StreamSubMethod subMethod,
    Reference params,
    bool remove,
  ) {
    final streamIdRef = streamIdFrom(params);
    if (remove) {
      return _subscriptionsMapRef
          .property('remove')
          .call([streamIdRef])
          .nullSafeProperty(subMethod.name)
          .call(const []);
    } else {
      return _subscriptionsMapRef
          .index(streamIdRef)
          .nullSafeProperty(subMethod.name)
          .call(const []);
    }
  }

  Expression _buildOnData(MethodElement method, DartType streamType) =>
      closure1(
        r'$data',
        (dataRef) => JsonRpcInstance.sendNotification.call([
          literalString(StreamRpc.methodName(method, StreamSubMethod.data)),
          literalList([
            StreamRpc.streamIdRef,
            toJson(streamType, dataRef),
          ], CoreTypes.$dynamic),
        ]).code,
      );

  Expression _buildOnError(MethodElement method) => closure2(
    type1: CoreTypes.$Object,
    StreamRpc.errorRef.symbol!,
    type2: CoreTypes.$StackTrace,
    StreamRpc.stackTraceRef.symbol!,
    (errorRef, stackTraceRef) => JsonRpcInstance.sendNotification.call([
      literalString(StreamRpc.methodName(method, StreamSubMethod.error)),
      literalList([
        StreamRpc.streamIdRef,
        errorRef
            .isA(Types.$RpcException)
            .conditional(
              errorRef,
              Types.$RpcException.newInstance(
                [
                  JsonRpcInstance.serverError,
                  JsonRpcInstance.getErrorMessage.call([errorRef]),
                ],
                {
                  'data': literalMap({
                    'full': errorRef.property('toString').call(const []),
                    'stack': Types.$Chain
                        .newInstanceNamed('forTrace', [stackTraceRef])
                        .property('toString')
                        .call(const []),
                  }),
                },
              ),
            )
            .parenthesized
            .property('serialize')
            // this is the request id of the failed request, not a sub method
            .call([
              literalString(
                '${method.name}#\${${StreamRpc.streamIdRef.symbol}}',
              ),
            ])
            .index(literalString('error')),
      ], CoreTypes.$dynamic),
    ]).code,
  );

  Expression _buildOnDone(MethodElement method) => closure0(
    () => Block.of([
      JsonRpcInstance.sendNotification.call([
        literalString(StreamRpc.methodName(method, StreamSubMethod.done)),
        literalList([StreamRpc.streamIdRef]),
      ]).statement,
      Globals.unawaitedRef.call([
        _subscriptionsMapRef
            .property('remove')
            .call([StreamRpc.streamIdRef])
            .nullSafeProperty('cancel')
            .call(const []),
      ]).statement,
    ]),
  );
}
