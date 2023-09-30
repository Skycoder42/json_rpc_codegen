import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart' hide ParameterBuilder;
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../common/annotations.dart';
import '../common/base_wrapper_builder_mixin.dart';
import '../common/closure_builder_mixin.dart';
import '../common/method_mapper_mixin.dart';
import '../common/serialization_mixin.dart';
import '../common/types.dart';
import '../proxy_spec.dart';
import 'parameter_builder_mixin.dart';
import 'wrapper_builder_mixin.dart';

/// @nodoc
@internal
final class ServerGenerator extends ProxySpec
    with
        MethodMapperMixin,
        ClosureBuilderMixin,
        SerializationMixin,
        BaseWrapperBuilderMixin,
        WrapperBuilderMixin,
        ParameterBuilderMixin {
  static const _serverName = 'jsonRpcServer';
  static const _serverRef = Reference(_serverName);
  static const _registerMethodName = '_registerMethods';
  static const _registerMethoRef = Reference('_registerMethods');
  static const _onUnknownMethodName = 'onUnknownMethod';
  static const _onUnknownMethodRef = Reference('onUnknownMethod');

  final ClassElement _class;

  /// @nodoc
  const ServerGenerator(this._class);

  @override
  Class build() => Class(
        (b) => b
          ..name = '${_class.name}Server'
          ..abstract = true
          ..implements.add(TypeReference((b) => b..symbol = _class.name))
          ..fields.add(
            Field(
              (b) => b
                ..name = _serverName
                ..modifier = FieldModifier.final$
                ..type = Types.jsonRpc2Server,
            ),
          )
          ..constructors.addAll(
            buildConstructors(_serverRef).map(
              (c) => Constructor(
                (b) => b
                  ..replace(c)
                  ..body = _registerMethoRef.call(const []).statement,
              ),
            ),
          )
          ..methods.addAll(buildWrapperMethods(_serverRef))
          ..methods.addAll(
            _class.methods.map(
              (method) => mapMethod(
                method,
                (b) => b..annotations.add(Annotations.protected),
              ),
            ),
          )
          ..methods.add(_buildFallback())
          ..methods.add(_buildRegisterMethod()),
      );

  Method _buildRegisterMethod() => Method(
        (b) => b
          ..name = _registerMethodName
          ..returns = Types.$void
          ..body = Block.of([
            ..._class.methods.map(_buildRegisterFor),
            _serverRef
                .property('registerFallback')
                .call(const [_onUnknownMethodRef]).statement,
          ]),
      );

  Code _buildRegisterFor(MethodElement method) {
    final parameterMode = validateParameters(method);

    return _serverRef.property('registerMethod').call([
      literalString(method.name),
      if (parameterMode == ParameterMode.none)
        closure0(
          modifier: MethodModifier.async,
          () => _buildInvocation(method).code,
        )
      else
        closure1(
          r'$params',
          type1: Types.jsonRpc2Parameters,
          modifier: MethodModifier.async,
          (p1) => Block.of([
            if (parameterMode.hasPositional)
              ...method.parameters
                  .mapIndexed((i, e) => buildPositional(p1, i, e)),
            if (parameterMode.hasNamed)
              ...method.parameters.map((e) => buildNamed(p1, e)),
            _buildInvocation(method).returned.statement,
          ]),
        ),
    ]).statement;
  }

  Expression _buildInvocation(MethodElement method) {
    final invocation = refer(method.name).call(
      [
        for (final p in method.parameters.where((p) => p.isPositional))
          paramRefFor(p),
      ],
      {
        for (final p in method.parameters.where((p) => p.isNamed))
          p.name: paramRefFor(p),
      },
    );

    return toJson(
      getReturnType(method),
      invocation.awaited.parenthesized,
    );
  }

  Method _buildFallback() {
    const paramsParamRef = Reference('params');
    return Method(
      (b) => b
        ..name = _onUnknownMethodName
        ..returns = Types.futureOr(Types.dynamic)
        ..annotations.add(Annotations.visibleForOverriding)
        ..requiredParameters.add(
          Parameter(
            (b) => b
              ..name = paramsParamRef.symbol!
              ..type = Types.jsonRpc2Parameters,
          ),
        )
        ..body = Types.jsonRpc2RpcException
            .newInstanceNamed(
              'methodNotFound',
              [paramsParamRef.property('method')],
            )
            .thrown
            .code,
    );
  }
}

// TODO fromJson casts
// TODO support dynamic?
// TODO Peer support
