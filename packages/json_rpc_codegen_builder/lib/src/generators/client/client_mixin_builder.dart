import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

import '../../builders/iterable_if.dart';
import '../../extensions/analyzer_extensions.dart';
import '../../readers/defaults_reader.dart';
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
          ..name = '${_class.publicName}ClientMixin'
          ..on = Types.clientBase
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
        buildMethod: (b) => b
          ..returns = Types.$void
          ..body = _buildNotificationBody(method),
        buildParam: (p, b) => _buildParam(method, p, b),
      );

  Method _buildRequestMethod(MethodElement method, DartType returnType) =>
      mapMethod(
        method,
        buildMethod: (b) => b
          ..returns = Types.future(Types.fromDartType(returnType))
          ..modifier =
              method.returnType.isDartCoreNull ? null : MethodModifier.async
          ..body = _buildRequestBody(method, returnType),
        buildParam: (p, b) => _buildParam(method, p, b),
      );

  void _buildParam(
    MethodElement method,
    ParameterElement parameter,
    ParameterBuilder builder,
  ) {
    if (parameter.isRequired) {
      return;
    }

    final isClientDefault = DefaultsReader.isClientDefault(method);
    if (isClientDefault) {
      if (parameter.hasDefaultValue) {
        builder.defaultTo = Code(parameter.defaultValueCode!);
      } else if (!parameter.type.isNullableType) {
        throw InvalidGenerationSourceError(
          'An RPC method parameter that uses client defaults must either be '
          'nullable or have an explicit default value set.',
          element: parameter,
          todo:
              'Change the type to ${parameter.type}? or specify a default value',
        );
      }
    } else {
      builder.type = Types.fromDartType(parameter.type, isNull: true);
    }
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

    if (returnType.isDartCoreNull) {
      return invocation.code;
    } else {
      const resultVarRef = Reference(r'$result');
      return Block.of([
        declareFinal(resultVarRef.symbol!, type: Types.dynamic)
            .assign(invocation.awaited)
            .statement,
        fromJson(returnType, resultVarRef).returned.statement,
      ]);
    }
  }

  Expression _buildMethodInvocation(Expression target, MethodElement method) {
    final isServerDefault = DefaultsReader.isServerDefault(method);
    final parameterMode = validateParameters(method);

    return target.call([
      literalString(method.name),
      if (parameterMode.hasPositional)
        _buildPositionalParameters(method.parameters, isServerDefault),
      if (parameterMode.hasNamed)
        literalMap(
          {
            for (final p in method.parameters)
              if (p.isOptional && isServerDefault)
                IterableIf(
                  refer(p.name).notEqualTo(literalNull),
                  literalString(p.name),
                ): toJson(p.type, refer(p.name), isNull: false)
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
    bool isServerDefault,
  ) {
    if (!isServerDefault) {
      return literalList(
        [
          for (final p in params) toJson(p.type, refer(p.name)),
        ],
        Types.dynamic,
      );
    }

    final lastRequiredIndex = params.indexed
            .toList()
            .reversed
            .skipWhile(
              (r) => r.$2.isOptional,
            )
            .map((r) => r.$1)
            .firstOrNull ??
        -1;

    final paramExpressions = <Expression>[];
    Expression? condition; // TODO assert non null instead
    for (final (index, param) in params.indexed.toList().reversed) {
      if (index <= lastRequiredIndex) {
        paramExpressions.add(toJson(param.type, refer(param.name)));
        continue;
      }

      bool? overwriteIsNull;
      if (condition == null) {
        overwriteIsNull = false;
        condition = refer(param.name).notEqualTo(literalNull);
      } else {
        condition = refer(param.name).notEqualTo(literalNull).or(condition);
      }

      paramExpressions.add(
        IterableIf(
          condition,
          toJson(
            param.type,
            refer(param.name),
            isNull: overwriteIsNull,
          ),
        ),
      );
    }

    return literalList(
      paramExpressions.reversed,
      Types.dynamic,
    );
  }
}
