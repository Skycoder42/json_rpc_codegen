import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_test_tools/code_gen.dart';
import 'package:meta/meta.dart';
import 'package:source_helper/source_helper.dart';

import '../../builders/if.dart';
import '../../builders/iterable_if.dart';
import '../../builders/try_catch.dart';
import '../../extensions/code_builder_extensions.dart';
import '../common/constants.dart';
import '../common/method_mapper_mixin.dart';
import '../common/parameter_builder_mixin.dart';
import '../common/registration_builder_mixin.dart';
import '../common/stream_support.dart';
import '../common/types.dart';
import 'invocation_builder_mixin.dart';

@internal
base mixin ClientStreamBuilderMixin
    on
        MethodMapperMixin,
        InvocationBuilderMixin,
        RegistrationBuilderMixin,
        StreamSupportMixin {
  static const _streamIdCounterRef = Reference(r'_$streamIdCounter');
  static const _controllerMapRef = Reference(r'_$streamControllers');
  static const _controllerRef = Reference(r'$controller');

  Iterable<Field> buildStreamFields(ClassElement clazz) sync* {
    if (!StreamRpc.hasStreams(clazz)) {
      return;
    }

    yield Field(
      (b) => b
        ..name = _streamIdCounterRef.symbol
        ..assignment = literalNum(0).code,
    );

    yield Field(
      (b) => b
        ..name = _controllerMapRef.symbol
        ..modifier = FieldModifier.final$
        ..assignment = literalMap(
          const {},
          CoreTypes.$int,
          Types.$StreamController(CoreTypes.$dynamic),
        ).code,
    );
  }

  Code buildStreamBody(MethodElement method, DartType streamType) =>
      Block.of(_buildStreamBodyImpl(method, streamType));

  Method? buildStreamListeners(ClassElement clazz) {
    if (!StreamRpc.hasStreams(clazz)) {
      return null;
    }

    return buildRegisterMethods(
      clazz.methods
          .where((m) => m.returnType.isDartAsyncStream)
          .map(_buildStreamListeners)
          .followedBy(
            buildStreamCleanup(
              clazz,
              map: _controllerMapRef,
              itemRef: _controllerRef,
              dispose: 'close',
            ),
          ),
    );
  }

  Iterable<Code> _buildStreamBodyImpl(
    MethodElement method,
    DartType streamType,
  ) sync* {
    late final Expression invocation;
    yield buildMethodInvocation(
      JsonRpcInstance.sendRequest,
      method,
      invocationSuffix: StreamSubMethod.listen.suffix,
      extraArgs: {StreamRpc.streamIdRef.symbol!: StreamRpc.streamIdRef},
      buildReturn: (i) {
        invocation = i;
        return [];
      },
    );

    yield declareFinal(
      StreamRpc.streamIdRef.symbol!,
    ).assign(_streamIdCounterRef.postfixIncrement).statement;

    yield _controllerMapRef
        .index(StreamRpc.streamIdRef)
        .assign(
          Types.$StreamController(
            streamType.toReference(),
          ).newInstance(const [], {
            'onListen': _buildOnListen(invocation),
            'onCancel': closure0(
              () => CoreTypes.$Future().property('wait').call([
                literalList([
                  IterableIf(
                    JsonRpcInstance.isClosed.negate(),
                    _buildStreamNotification(
                      method,
                      StreamSubMethod.cancel,
                      asRequest: true,
                    ).property('onError').call(
                      [closure2('_', '_', (_, _) => Block())],
                      {
                        'test': closure1(
                          '_',
                          (_) => JsonRpcInstance.isClosed.code,
                        ),
                      },
                      [CoreTypes.$StateError],
                    ),
                  ),
                  IterableIf(
                    _controllerMapRef
                        .property('remove')
                        .call(const [StreamRpc.streamIdRef])
                        .$case(
                          declareFinal(_controllerRef.symbol!).patternNonNull,
                        ),
                    _controllerRef.property('close').call(const []),
                  ),
                ]),
              ]).code,
            ),
            'onPause': closure0(
              () =>
                  _buildStreamNotification(method, StreamSubMethod.pause).code,
            ),
            'onResume': closure0(
              () =>
                  _buildStreamNotification(method, StreamSubMethod.resume).code,
            ),
          }),
        )
        .parenthesized
        .property('stream')
        .returned
        .statement;
  }

  Expression _buildOnListen(Expression invocation) => closure0(
    modifier: MethodModifier.async,
    () => try$([invocation.awaited.statement]).catch$(
      error: StreamRpc.errorRef,
      stackTrace: StreamRpc.stackTraceRef,
      body: [
        declareFinal(_controllerRef.symbol!)
            .assign(
              _controllerMapRef.property('remove').call(const [
                StreamRpc.streamIdRef,
              ]),
            )
            .statement,
        $if(_controllerRef.notEqualTo(literalNull), [
          _controllerRef.property('addError').call(const [
            StreamRpc.errorRef,
            StreamRpc.stackTraceRef,
          ]).statement,
          _controllerRef.property('close').call(const []).awaited.statement,
        ]).$else([const Reference('rethrow').statement]),
      ],
    ),
  );

  Expression _buildStreamNotification(
    MethodElement method,
    StreamSubMethod subMethod, {
    bool asRequest = false,
  }) =>
      (asRequest
              ? JsonRpcInstance.sendRequest
              : JsonRpcInstance.sendNotification)
          .call([
            literalString(rpcMethodName(method, subMethod.suffix)),
            literalList([StreamRpc.streamIdRef]),
          ]);

  Code _buildStreamListeners(MethodElement method) {
    final streamType = getReturnType(method).type;
    return Block.of([
      _buildAddMethod(method, streamType),
      _buildErrorMethod(method),
      _buildDoneMethod(method),
    ]);
  }

  Code _buildAddMethod(
    MethodElement method,
    DartType streamType,
  ) => buildRegisterMethodWithParams(
    rpcMethodName(method, StreamSubMethod.data.suffix),
    async: false,
    (params) => _controllerMapRef
        .index(streamIdFrom(params))
        .asA(Types.$StreamController(streamType.toReference()).asNullable(true))
        .nullSafeProperty('add')
        .call([
          methodFromJson(
            method,
            streamType,
            streamType.isNullableType
                ? params
                      .index(literalNum(1))
                      .property(ParameterBuilderMixin.nullCheckedName)
                      .call([
                        closure1(r'$v', (p1) => p1.property('value').code),
                      ])
                : params.index(literalNum(1)).property('value'),
          ),
        ])
        .code,
  );

  Code _buildErrorMethod(MethodElement method) => buildRegisterMethodWithParams(
    rpcMethodName(method, StreamSubMethod.error.suffix),
    async: false,
    (params) => Block.of([
      declareFinal(StreamRpc.errorRef.symbol!)
          .assign(
            params
                .index(literalNum(1))
                .property('asMap')
                .asA(
                  CoreTypes.$Map(
                    keyType: CoreTypes.$String,
                    valueType: CoreTypes.$dynamic,
                  ),
                ),
          )
          .statement,
      _controllerMapRef
          .index(streamIdFrom(params))
          .nullSafeProperty('addError')
          .call([
            Types.$RpcException.newInstance(
              [
                StreamRpc.errorRef
                    .index(literalString('code'))
                    .asA(CoreTypes.$int),
                StreamRpc.errorRef
                    .index(literalString('message'))
                    .asA(CoreTypes.$String),
              ],
              {
                'data': StreamRpc.errorRef
                    .index(literalString('data'))
                    .asA(CoreTypes.$Object.asNullable(true)),
              },
            ),
          ])
          .statement,
    ]),
  );

  Code _buildDoneMethod(MethodElement method) => buildRegisterMethodWithParams(
    rpcMethodName(method, StreamSubMethod.done.suffix),
    async: false,
    (params) => _controllerMapRef
        .property('remove')
        .call([streamIdFrom(params)])
        .nullSafeProperty('close')
        .call(const [])
        .code,
  );
}
