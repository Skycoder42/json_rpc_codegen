import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_test_tools/code_gen.dart';
import 'package:meta/meta.dart';

import '../../builders/iterable_if.dart';
import '../../extensions/code_builder_extensions.dart';
import '../../extensions/parameter_extensions.dart';
import '../../readers/defaults_reader.dart';
import '../common/method_mapper_mixin.dart';
import '../common/serialization_mixin.dart';

@internal
base mixin InvocationBuilderMixin on MethodMapperMixin, SerializationMixin {
  Code buildMethodInvocation(
    Expression target,
    MethodElement method, {
    String invocationSuffix = '',
    Iterable<Code> Function(Expression invocation)? buildReturn,
    Map<String, Reference> extraArgs = const {},
  }) {
    final isServerDefault = DefaultsReader.isServerDefault(method);
    final parameterMode = validateParameters(method);

    final invocation = target.call([
      literalString(rpcMethodName(method, invocationSuffix)),
      if (parameterMode.hasPositional)
        _buildPositionalParameters(
          method.formalParameters,
          isServerDefault,
          extraArgs.values,
        )
      else if (parameterMode.hasNamed)
        _buildNamedParameters(
          method.formalParameters,
          isServerDefault,
          extraArgs,
        )
      else if (extraArgs.isNotEmpty)
        literalList(extraArgs.values, CoreTypes.$dynamic),
    ]);

    if (buildReturn == null) {
      return invocation.code;
    } else {
      return Block.of(buildReturn(invocation));
    }
  }

  Expression _buildPositionalParameters(
    List<FormalParameterElement> params,
    bool isServerDefault,
    Iterable<Reference> extraArgs,
  ) {
    if (!isServerDefault) {
      return literalList([
        ...extraArgs,
        for (final p in params) paramToJson(p, refer(p.name!)),
      ], CoreTypes.$dynamic);
    }

    final lastRequiredIndex = params.lastIndexWhere((p) => p.isRequired);

    final paramExpressions = <Expression>[];
    Expression? validateRest;
    for (final (index, param) in params.indexed.toList().reversed) {
      final paramRef = refer(param.name!);
      if (index <= lastRequiredIndex) {
        paramExpressions.add(paramToJson(param, paramRef));
        continue;
      }

      if (validateRest == null) {
        if (param.hasDefaultValue) {
          validateRest = paramRef.notEqualTo(param.defaultValueExpression);
          paramExpressions.add(
            IterableIf(validateRest, paramToJson(param, paramRef)),
          );
        } else {
          paramExpressions.add(paramToJson(param, paramRef).collectionNonNull);
          validateRest = paramRef.notEqualTo(literalNull);
        }
      } else {
        validateRest = paramRef
            .notEqualTo(param.defaultValueExpression)
            .or(validateRest);
        paramExpressions.add(
          IterableIf(validateRest, paramToJson(param, paramRef)),
        );
      }
    }

    return literalList([
      ...extraArgs,
      ...paramExpressions.reversed,
    ], CoreTypes.$dynamic);
  }

  Expression _buildNamedParameters(
    Iterable<FormalParameterElement> params,
    bool isServerDefault,
    Map<String, Reference> extraArgs,
  ) => literalMap(
    {
      for (final MapEntry(:key, :value) in extraArgs.entries)
        literalString(key, raw: true): value,
      for (final p in params)
        if (p.isOptional && isServerDefault)
          if (p.hasDefaultValue)
            IterableIf(
              refer(p.name!).notEqualTo(p.defaultValueExpression),
              literalString(rpcParamName(p), raw: true),
            ): paramToJson(
              p,
              refer(p.name!),
            )
          else
            literalString(rpcParamName(p), raw: true): paramToJson(
              p,
              refer(p.name!),
            ).collectionNonNull
        else
          literalString(rpcParamName(p), raw: true): paramToJson(
            p,
            refer(p.name!),
          ),
    },
    CoreTypes.$String,
    CoreTypes.$dynamic,
  );
}
