import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';
import 'package:source_helper/source_helper.dart';

import '../../builders/for_in.dart';
import '../../extensions/code_builder_extensions.dart';
import '../common/constants.dart';
import '../common/method_mapper_mixin.dart';
import '../common/parameter_builder_mixin.dart';
import '../common/registration_builder_mixin.dart';
import '../common/types.dart';
import '../proxy_spec.dart';
import 'invocation_builder_mixin.dart';

@internal
base mixin StreamBuilderMixin
    on
        ProxySpec,
        MethodMapperMixin,
        InvocationBuilderMixin,
        RegistrationBuilderMixin {
  static const _controllerMapRef = Reference(r'_$streamControllers');
  static const _streamIdRef = Reference(r'$streamId');
  static const _controllerRef = Reference(r'$controller');
  static const _errorRef = Reference(r'$error');
  static const _stackTraceRef = Reference(r'$stackTrace');

  static bool hasStreams(ClassElement clazz) =>
      clazz.methods.any((m) => m.returnType.isDartAsyncStream);

  Iterable<Field> buildStreamFields(ClassElement clazz) sync* {
    if (!hasStreams(clazz)) {
      return;
    }

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
          .map(_buildStreamListeners)
          .followedBy([_buildCleanupMethod()]),
    );
  }

  Iterable<Code> _buildStreamBodyImpl(MethodElement method) sync* {
    final streamType = Types.fromDartType(_streamType(method));

    yield buildMethodInvocation(
      JsonRpcInstance.sendRequest,
      method,
      isAsync: false,
      buildReturn: (invocation) sync* {
        yield declareFinal(_streamIdRef.symbol!)
            .assign(
              invocation
                  .property('then')
                  .call([closure1(r'$id', (id) => id.asA(Types.$int).code)]),
            )
            .statement;
      },
    );

    yield declareFinal(_controllerRef.symbol!)
        .assign(
          Types.streamController(streamType).newInstance(
            const [],
            {
              'onListen': _buildStreamNotification(method, 'listen'),
              'onCancel': _buildStreamNotification(
                method,
                'cancel',
                asRequest: true,
              ),
              'onPause': _buildStreamNotification(method, 'pause'),
              'onResume': _buildStreamNotification(method, 'resume'),
            },
          ),
        )
        .statement;

    yield _streamIdRef.property('then').call(
      [
        closure1(
          r'$id',
          (id) => JsonRpcInstance.isClosed
              .conditional(
                _controllerRef.property('close').call(const []),
                _controllerMapRef.index(id).assign(_controllerRef),
              )
              .code,
        ),
      ],
      {
        'onError': closure2(
          type1: Types.object,
          _errorRef.symbol!,
          type2: Types.stackTrace,
          _stackTraceRef.symbol!,
          (p1, p2) => _controllerRef
              .cascade('addError')
              .call([p1, p2])
              .cascade('close')
              .call(const [])
              .code,
        ),
      },
    ).statement;

    yield _controllerRef.property('stream').returned.statement;
  }

  DartType _streamType(MethodElement method) => getReturnType(
        method,
        (method.returnType as InterfaceType).typeArguments.single,
      );

  Expression _buildStreamNotification(
    MethodElement method,
    String command, {
    bool asRequest = false,
  }) =>
      closure0(
        modifier: MethodModifier.async,
        () => (asRequest
                ? JsonRpcInstance.sendRequest
                : JsonRpcInstance.sendNotification)
            .call([
          literalString('${method.name}#$command'),
          literalList([StreamBuilderMixin._streamIdRef.awaited]),
        ]).code,
      );

  Code _buildStreamListeners(MethodElement method) {
    final streamType = _streamType(method);

    return Block.of([
      _buildAddMethod(method, streamType),
      _buildErrorMethod(method, streamType),
      _buildDoneMethod(method, streamType),
    ]);
  }

  Code _buildAddMethod(MethodElement method, DartType streamType) =>
      buildRegisterMethodWithParams(
        '${method.name}#add',
        async: false,
        (params) => _controllerMapRef
            .index(params.index(literalNum(0)).property('asInt'))
            .asA(
              Types.streamController(Types.fromDartType(streamType))
                  .asNullable(true),
            )
            .nullSafeProperty('add')
            .call([
          fromJson(
            streamType,
            streamType.isNullableType
                ? params
                    .index(literalNum(1))
                    .property(ParameterBuilderMixin.nullOrName)
                    .call([
                    closure1(r'$v', (p1) => p1.property('value').code),
                  ])
                : params.index(literalNum(1)).property('value'),
          ),
        ]).code,
      );

  Code _buildErrorMethod(MethodElement method, DartType streamType) =>
      buildRegisterMethodWithParams(
        '${method.name}#error',
        async: false,
        (params) => Block.of([
          declareFinal(_errorRef.symbol!)
              .assign(
                params
                    .index(literalNum(1))
                    .property('asMap')
                    .asA(Types.map(Types.string, Types.dynamic)),
              )
              .statement,
          _controllerMapRef
              .index(params.index(literalNum(0)).property('asInt'))
              .asA(
                Types.streamController(Types.fromDartType(streamType))
                    .asNullable(true),
              )
              .nullSafeProperty('addError')
              .call([
            Types.jsonRpc2RpcException.newInstance([
              _errorRef.index(literalString('code')).asA(Types.$int),
              _errorRef.index(literalString('message')).asA(Types.string),
            ], {
              'data': _errorRef
                  .index(literalString('data'))
                  .asA(Types.object.asNullable(true)),
            }),
          ]).statement,
        ]),
      );

  Code _buildDoneMethod(MethodElement method, DartType streamType) =>
      buildRegisterMethodWithParams(
        '${method.name}#done',
        async: false,
        (params) => _controllerMapRef
            .property('remove')
            .call([params.index(literalNum(0)).property('asInt')])
            .asA(
              Types.streamController(Types.fromDartType(streamType))
                  .asNullable(true),
            )
            .nullSafeProperty('close')
            .call(const [])
            .code,
      );

  Code _buildCleanupMethod() =>
      JsonRpcInstance.ref.property('done').property('then').call([
        closure1(
          '_',
          (_) => Block.of([
            ForIn(
              _controllerRef.symbol!,
              _controllerMapRef.property('values'),
              Globals.unawaitedRef.call([
                _controllerRef.property('close').call(const []),
              ]).statement,
            ),
            _controllerMapRef.property('clear').call(const []).statement,
          ]),
        ),
      ]).statement;
}
