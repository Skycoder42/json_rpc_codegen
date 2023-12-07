import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../../builders/try_catch.dart';
import '../../extensions/code_builder_extensions.dart';
import '../common/method_mapper_mixin.dart';
import '../common/registration_builder_mixin.dart';
import '../common/types.dart';
import '../proxy_spec.dart';
import 'invocation_builder_mixin.dart';

/// @nodoc
@internal
base mixin StreamBuilderMixin
    on
        ProxySpec,
        MethodMapperMixin,
        InvocationBuilderMixin,
        RegistrationBuilderMixin {
  // TODO reuse somehow
  static const _rpcGetterRef = Reference('jsonRpcInstance');
  static const _streamCounterRef = Reference(r'_$streamCounter');
  static const _controllerMapRef = Reference(r'_$streamControllers');
  static const _streamIdRef = Reference(r'$streamId');
  static const _paramsRef = Reference(r'$params');
  static const _errorRef = Reference(r'$error');
  static const _stackTraceRef = Reference(r'$stackTrace');

  bool hasStreams(ClassElement clazz) =>
      clazz.methods.any((m) => m.returnType.isDartAsyncStream);

  Iterable<Field> buildStreamFields(ClassElement clazz) sync* {
    if (!hasStreams(clazz)) {
      return;
    }

    yield Field(
      (b) => b
        ..name = _streamCounterRef.symbol
        ..modifier = FieldModifier.var$
        ..assignment = literalNum(0).code,
    );
    yield Field(
      (b) => b
        ..name = _controllerMapRef.symbol
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

  Method? buildStreamListeners(ClassElement clazz) {
    if (!hasStreams(clazz)) {
      return null;
    }

    return buildRegisterMethods(
      clazz.methods
          .where((m) => m.returnType.isDartAsyncStream)
          .map(_buildStreamListeners),
    );
  }

  Iterable<Code> _buildStreamBodyImpl(MethodElement method) sync* {
    final streamType = Types.fromDartType(_streamType(method));

    yield declareFinal(_streamIdRef.symbol!)
        .assign(_streamCounterRef.postfixIncrement)
        .statement;
    yield _controllerMapRef
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
  }) {
    var invocation = _buildNotificationInvocation(
      method,
      command,
      withArgs,
    );

    if (withTryCatch) {
      if (invocation case ToCodeExpression(isStatement: false)) {
        invocation = invocation.code.statement;
      }
      invocation = try$([invocation]).catch$(
        error: _errorRef,
        stackTrace: _stackTraceRef,
        body: [
          _controllerMapRef
              .index(_streamIdRef)
              .nullSafeProperty('addError')
              .call(const [_errorRef, _stackTraceRef]).statement,
          if (closeOnError)
            _controllerMapRef
                .property('remove')
                .call(const [_streamIdRef])
                .nullSafeProperty('close')
                .call(const [])
                .statement,
        ],
      );
    }

    return closure0(() => invocation);
  }

  Code _buildNotificationInvocation(
    MethodElement method,
    String command,
    bool withArgs,
  ) {
    if (withArgs) {
      return buildMethodInvocation(
        _rpcGetterRef.property('sendNotification'),
        method,
        isAsync: false,
        invocationSuffix: '#$command',
        extraArgs: {
          _streamIdRef.symbol!: _streamIdRef,
        },
      );
    } else {
      return _rpcGetterRef.property('sendNotification').call([
        literalString('${method.name}#$command'),
        literalList(const [_streamIdRef], Types.dynamic),
      ]).code;
    }
  }

  Code _buildStreamListeners(MethodElement method) {
    final streamType = _streamType(method);

    return Block.of([
      _rpcGetterRef.property('registerMethod').call([
        literalString('${method.name}#add'),
        closure1(
          r'$params',
          type1: Types.jsonRpc2Parameters,
          (p1) => _controllerMapRef
              .index(_paramsRef.index(literalNum(0)).property('asInt'))
              .asA(
                Types.streamController(Types.fromDartType(streamType))
                    .asNullable(true),
              )
              .nullSafeProperty('add')
              .call([
            //TODO convert parameter
            _paramsRef.index(literalNum(1)),
          ]).code,
        ),
      ]).statement,
      _rpcGetterRef.property('registerMethod').call([
        literalString('${method.name}#error'),
        closure1(
          r'$params',
          type1: Types.jsonRpc2Parameters,
          (p1) => _controllerMapRef
              .index(_paramsRef.index(literalNum(0)).property('asInt'))
              .asA(
                Types.streamController(Types.fromDartType(streamType))
                    .asNullable(true),
              )
              .nullSafeProperty('addError')
              .call([
            _paramsRef.index(literalNum(1)).property('value'),
            _paramsRef.index(literalNum(2)).property('asString'),
          ]).code,
        ),
      ]).statement,
      _rpcGetterRef.property('registerMethod').call([
        literalString('${method.name}#done'),
        closure1(
          r'$params',
          type1: Types.jsonRpc2Parameters,
          (p1) => _controllerMapRef
              .property('remove')
              .call([_paramsRef.index(literalNum(0)).property('asInt')])
              .asA(
                Types.streamController(Types.fromDartType(streamType))
                    .asNullable(true),
              )
              .nullSafeProperty('close')
              .call(const [])
              .code,
        ),
      ]).statement,
    ]);
  }

  // Method(
  //       (b) => b
  //         ..requiredParameters.add(
  //           Parameter(
  //             (b) => b
  //               ..name = _paramsRef.symbol!
  //               ..type = Types.jsonRpc2Parameters,
  //           ),
  //         )
  //         ..body = Block.of([
  //           declareFinal(r'$eventStreamId')
  //               .assign(
  //                 _paramsRef.index(literalString('id')).property('asInt'),
  //               )
  //               .statement,
  //           declareFinal('event')
  //               .assign(
  //                 Types.streamEvent.property('values').property('byName').call([
  //                   _paramsRef
  //                       .index(literalString('event'))
  //                       .property('asString'),
  //                 ]),
  //               )
  //               .statement,
  //           // TODO switch/case etc
  //         ]),
  //     ).closure;
}
