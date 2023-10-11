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
          ..modifier = MethodModifier.async
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
        isAsync: false,
      );

  Code _buildRequestBody(MethodElement method, DartType returnType) =>
      _buildMethodInvocation(
        _rpcGetterRef.property('sendRequest'),
        method,
        isAsync: true,
        buildReturn: returnType.isDartCoreNull
            ? null
            : (invocation) sync* {
                const resultVarRef = Reference(r'$result');
                yield declareFinal(resultVarRef.symbol!, type: Types.dynamic)
                    .assign(invocation.awaited)
                    .statement;
                yield fromJson(returnType, resultVarRef).returned.statement;
              },
      );

  Code _buildMethodInvocation(
    Expression target,
    MethodElement method, {
    required bool isAsync,
    Iterable<Code> Function(Expression invocation)? buildReturn,
  }) {
    final isServerDefault = DefaultsReader.isServerDefault(method);
    final parameterMode = validateParameters(method);

    final assertions = <Code>[];

    final invocation = target.call([
      literalString(method.name),
      if (parameterMode.hasPositional)
        _buildPositionalParameters(
          method.parameters,
          isServerDefault,
          assertions,
        ),
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

    if (assertions.isEmpty && buildReturn == null) {
      return invocation.code;
    } else {
      return Block.of([
        ...assertions.reversed,
        if (buildReturn == null)
          isAsync ? invocation.awaited.statement : invocation.statement
        else
          ...buildReturn(invocation),
      ]);
    }
  }

  Expression _buildPositionalParameters(
    List<ParameterElement> params,
    bool isServerDefault,
    List<Code> assertions,
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
    Expression? assertRest;
    for (final (index, param) in params.indexed.toList().reversed) {
      if (index <= lastRequiredIndex) {
        paramExpressions.add(toJson(param.type, refer(param.name)));
        continue;
      }

      bool? overwriteIsNull;
      if (assertRest == null) {
        overwriteIsNull = false;
        assertRest = refer(param.name).equalTo(literalNull);
      } else {
        assertions.add(
          refer('assert').call([
            refer(param.name)
                .notEqualTo(literalNull)
                .or(assertRest.parenthesized),
          ]).statement,
        );
        assertRest = refer(param.name).equalTo(literalNull).and(assertRest);
      }

      paramExpressions.add(
        IterableIf(
          refer(param.name).notEqualTo(literalNull),
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
