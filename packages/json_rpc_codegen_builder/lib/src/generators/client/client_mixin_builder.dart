import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

import '../../builders/iterable_if.dart';
import '../../readers/default_reader.dart';
import '../common/closure_builder_mixin.dart';
import '../common/method_mapper_mixin.dart';
import '../common/serialization_mixin.dart';
import '../common/types.dart';
import '../proxy_spec.dart';

/// @nodoc
@internal
final class ClientMixinBuilder extends ProxySpec
    with MethodMapperMixin, ClosureBuilderMixin, SerializationMixin {
  static const _rpcGetterRef = Reference('jsonRpcInstance');

  final ClassElement _class;

  /// @nodoc
  const ClientMixinBuilder(this._class);

  /// @nodoc
  @override
  Mixin build() => Mixin(
        (b) => b
          ..name = '${_class.name}ClientMixin'
          ..on = Types.clientBase
          ..implements.add(Types.fromClass(_class))
          ..methods.addAll(_class.methods.map(_buildMethod)),
      );

  Method _buildMethod(MethodElement method) {
    final returnType = getReturnType(method);
    if (returnType is VoidType) {
      return _buildNotificationMethod(method);
    } else {
      return _buildRequestMethod(method, returnType);
    }
  }

  Method _buildNotificationMethod(MethodElement method) => mapMethod(
        method,
        defaultValueBuilder: _buildDefaultValue,
        (b) => b
          ..returns = Types.$void
          ..body = _buildNotificationBody(method),
      );

  Method _buildRequestMethod(MethodElement method, DartType returnType) =>
      mapMethod(
        method,
        defaultValueBuilder: _buildDefaultValue,
        (b) => b
          ..returns = Types.future(Types.fromDartType(returnType))
          ..modifier = MethodModifier.async
          ..body = _buildRequestBody(method, returnType),
      );

  Code? _buildDefaultValue(ParameterElement param) {
    final clientDefault = DefaultReader.client(param);
    if (clientDefault != null) {
      return clientDefault.valueCode;
    }

    if (param.isOptional && !param.type.isNullableType) {
      throw InvalidGenerationSourceError(
        'Optional parameters without a @ClientDefault must be nullable!',
        element: param,
        todo: 'Change the parameter type to ${param.type}?',
      );
    }

    return null;
  }

  Code _buildNotificationBody(MethodElement method) => _buildMethodInvocation(
        _rpcGetterRef.property('sendNotification'),
        method,
      ).code;

  Code _buildRequestBody(MethodElement method, DartType returnType) {
    final invocation = _buildMethodInvocation(
      _rpcGetterRef.property('sendRequest'),
      method,
    );

    const resultVarRef = Reference(r'$result');
    return Block.of([
      declareFinal(resultVarRef.symbol!, type: Types.dynamic)
          .assign(invocation.awaited)
          .statement,
      fromJson(returnType, resultVarRef).returned.statement,
    ]);
  }

  Expression _buildMethodInvocation(Expression target, MethodElement method) {
    final parameterMode = validateParameters(method);
    return target.call([
      literalString(method.name),
      if (parameterMode.hasPositional)
        _buildPositionalParameters(method.parameters),
      if (parameterMode.hasNamed)
        literalMap(
          {
            // TODO enforce value not null!
            for (final p in method.parameters)
              if (p.isOptional && DefaultReader.client(p) == null)
                IterableIf(
                  refer(p.name).notEqualTo(literalNull),
                  literalString(p.name),
                ): toJson(p.type, refer(p.name))
              else
                literalString(p.name): toJson(p.type, refer(p.name)),
          },
          Types.string,
          Types.dynamic,
        ),
    ]);
  }

  Expression _buildPositionalParameters(
    List<ParameterElement> params,
  ) {
    final lastRequiredIndex = params.indexed
            .toList()
            .reversed
            .skipWhile(
              (r) => r.$2.isOptional && DefaultReader.client(r.$2) == null,
            )
            .map((r) => r.$1)
            .firstOrNull ??
        -1;

    final paramExpressions = <Expression>[];
    Expression? condition;
    for (final (index, param) in params.indexed.toList().reversed) {
      if (index <= lastRequiredIndex) {
        paramExpressions.add(toJson(param.type, refer(param.name)));
        continue;
      }

      if (condition == null) {
        condition = refer(param.name).notEqualTo(literalNull);
      } else {
        condition = refer(param.name).notEqualTo(literalNull).or(condition);
      }

      paramExpressions.add(
        IterableIf(
          condition,
          toJson(param.type, refer(param.name)),
        ),
      );
    }

    return literalList(
      paramExpressions.reversed,
      Types.dynamic,
    );
  }
}
