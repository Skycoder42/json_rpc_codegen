import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../../builders/try_catch.dart';
import '../../extensions/code_builder_extensions.dart';
import '../common/method_mapper_mixin.dart';
import '../common/types.dart';
import '../proxy_spec.dart';

/// @nodoc
@internal
base mixin StreamBuilderMixin on ProxySpec, MethodMapperMixin {
  // TODO reuse somehow
  static const _rpcGetterRef = Reference('jsonRpcInstance');
  static const _streamCounter = Reference(r'_$streamCounter');
  static const _controllerMap = Reference(r'_$streamControllers');
  static const _streamIdRef = Reference(r'$streamId');
  static const _paramsRef = Reference(r'$params');
  static const _errorRef = Reference(r'$error');
  static const _stackTraceRef = Reference(r'$stackTrace');

  Iterable<Field> buildStreamFields(ClassElement clazz) sync* {
    if (!clazz.methods.any((m) => m.returnType.isDartAsyncStream)) {
      return;
    }

    yield Field(
      (b) => b
        ..name = _streamCounter.symbol
        ..modifier = FieldModifier.var$
        ..assignment = literalNum(0).code,
    );
    yield Field(
      (b) => b
        ..name = _controllerMap.symbol
        ..modifier = FieldModifier.final$
        ..assignment = literalMap(
          const {},
          Types.$int,
          Types.streamController(),
        ).code,
    );
  }

  Code buildStreamBody(MethodElement method) =>
      Block.of(_buildStreamBodyImpl(method));

  Iterable<Code> _buildStreamBodyImpl(MethodElement method) sync* {
    final streamType = Types.fromDartType(_streamType(method));

    yield declareFinal(_streamIdRef.symbol!)
        .assign(_streamCounter.postfixIncrement)
        .statement;
    yield _controllerMap
        .index(_streamIdRef)
        .assign(
          Types.streamController(streamType).newInstance(
            const [],
            {
              'onListen': _buildStreamNotification(
                method,
                'listen',
                withArgs: true,
                closeOnError: true,
              ),
              'onCancel': _buildStreamNotification(
                method,
                'cancel',
                withTryCatch: false,
              ),
              'onPause': _buildStreamNotification(method, 'pause'),
              'onResume': _buildStreamNotification(method, 'resume'),
            },
          ),
        )
        .parenthesized
        .property('stream')
        .returned
        .statement;

    // // TODO move away, cannot be called multiple times
    // yield _rpcGetterRef.property('registerMethod').call([
    //   literalString(method.name),
    //   _buildStreamListener(),
    // ]).statement;
  }

  DartType _streamType(MethodElement method) => getReturnType(
        method,
        (method.returnType as InterfaceType).typeArguments.single,
      );

  Expression _buildStreamNotification(
    MethodElement method,
    String command, {
    bool withArgs = false,
    bool withTryCatch = true,
    bool closeOnError = false,
  }) =>
      Method(
        (b) => b
          ..body = withTryCatch
              ? Block.of([
                  try$([
                    _buildNotificationInvocation(method, command, withArgs)
                        .statement,
                  ]).catch$(
                    error: _errorRef,
                    stackTrace: _stackTraceRef,
                    body: [
                      _controllerMap
                          .index(_streamIdRef)
                          .nullSafeProperty('addError')
                          .call(const [_errorRef, _stackTraceRef]).statement,
                      if (closeOnError)
                        _controllerMap
                            .property('remove')
                            .call(const [_streamIdRef])
                            .nullSafeProperty('close')
                            .call(const [])
                            .statement,
                    ],
                  ),
                ])
              : _buildNotificationInvocation(method, command, withArgs).code,
      ).closure;

  Expression _buildNotificationInvocation(
    MethodElement method,
    String command,
    bool withArgs,
  ) =>
      _rpcGetterRef.property('sendNotification').call([
        literalString('${method.name}#$command'),
        literalList(
          withArgs
              ? [
                  // TODO map parameters with stream id
                  _streamIdRef,
                ]
              : [_streamIdRef],
          Types.dynamic,
        ),
      ]);

  Expression _buildStreamListener() => Method(
        (b) => b
          ..requiredParameters.add(
            Parameter(
              (b) => b
                ..name = _paramsRef.symbol!
                ..type = Types.jsonRpc2Parameters,
            ),
          )
          ..body = Block.of([
            declareFinal(r'$eventStreamId')
                .assign(
                  _paramsRef.index(literalString('id')).property('asInt'),
                )
                .statement,
            declareFinal('event')
                .assign(
                  Types.streamEvent.property('values').property('byName').call([
                    _paramsRef
                        .index(literalString('event'))
                        .property('asString'),
                  ]),
                )
                .statement,
            // TODO switch/case etc
          ]),
      ).closure;
}
