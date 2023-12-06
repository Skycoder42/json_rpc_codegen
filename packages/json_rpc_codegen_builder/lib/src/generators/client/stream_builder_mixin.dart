import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:json_rpc_codegen/json_rpc_codegen.dart' hide Parameter;
import 'package:meta/meta.dart';

import '../../extensions/code_builder_extensions.dart';
import '../common/types.dart';
import '../proxy_spec.dart';

/// @nodoc
@internal
base mixin StreamBuilderMixin on ProxySpec {
  // TODO reuse somehow
  static const _rpcGetterRef = Reference('jsonRpcInstance');
  static const _streamIdRef = Reference(r'$streamId');
  static const _controllerRef = Reference(r'$controller');
  static const _paramsRef = Reference(r'$params');

  /// @nodoc
  Field buildStreamCounter(MethodElement method) => Field(
        (b) => b
          ..name = '\$${method.name}StreamCounter'
          ..modifier = FieldModifier.var$
          ..assignment = literalNum(0).code,
      );

  /// @nodoc
  Code buildStreamBody(
    MethodElement method,
    DartType returnType,
  ) =>
      Block.of(_buildStreamBodyImpl(method, returnType));

  Iterable<Code> _buildStreamBodyImpl(
    MethodElement method,
    DartType returnType,
  ) sync* {
    final streamType = (returnType as InterfaceType).typeArguments.single;

    yield declareFinal(_streamIdRef.symbol!)
        .assign(refer('\$${method.name}StreamCounter').postfixIncrement)
        .statement;
    yield declareFinal(_controllerRef.symbol!)
        .assign(
          Types.streamController(Types.fromDartType(streamType)).newInstance(
            const [],
            {
              'onListen': _buildStreamNotification(
                method,
                StreamCommand.listen,
                withArgs: true,
              ),
              'onCancel':
                  _buildStreamNotification(method, StreamCommand.cancel),
              'onPause': _buildStreamNotification(method, StreamCommand.pause),
              'onResume':
                  _buildStreamNotification(method, StreamCommand.resume),
            },
          ),
        )
        .statement;

// TODO move away, cannot be called multiple times
    yield _rpcGetterRef.property('registerMethod').call([
      literalString(method.name),
      _buildStreamListener(),
    ]).statement;

    yield _controllerRef.property('stream').returned.statement;
  }

  Expression _buildStreamNotification(
    MethodElement method,
    StreamCommand command, {
    bool withArgs = false,
  }) =>
      Method(
        (b) => b
          ..body = _rpcGetterRef.property('sendNotification').call([
            literalString(method.name),
            literalList(
              [
                Types.streamCommand.property(command.name).property('name'),
                _streamIdRef,
                if (withArgs) ...[
                  // TODO map parameters
                ],
              ],
              Types.dynamic,
            ),
          ]).code,
      ).closure;

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
