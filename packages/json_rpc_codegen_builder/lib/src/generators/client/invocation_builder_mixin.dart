import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_test_tools/code_gen.dart';
import 'package:meta/meta.dart';

import '../../builders/if.dart';
import '../../extensions/code_builder_extensions.dart';
import '../../readers/defaults_reader.dart';
import '../common/method_mapper_mixin.dart';
import '../common/serialization_mixin.dart';

@internal
base mixin InvocationBuilderMixin on MethodMapperMixin, SerializationMixin {
  Code buildMethodInvocation(
    Expression target,
    MethodElement method, {
    required bool isAsync,
    String invocationSuffix = '',
    Iterable<Code> Function(Expression invocation)? buildReturn,
    Map<String, Reference> extraArgs = const {},
  }) {
    final isServerDefault = DefaultsReader.isServerDefault(method);
    final parameterMode = validateParameters(method);

    final validations = <Code>[];

    final invocation = target.call([
      literalString('${method.name}$invocationSuffix'),
      if (parameterMode.hasPositional)
        _buildPositionalParameters(
          method.formalParameters,
          isServerDefault,
          extraArgs.values,
          validations,
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

    if (validations.isEmpty && buildReturn == null) {
      return invocation.code;
    } else {
      return Block.of([
        ...validations.reversed,
        if (buildReturn == null)
          isAsync ? invocation.awaited.statement : invocation.statement
        else
          ...buildReturn(invocation),
      ]);
    }
  }

  Expression _buildPositionalParameters(
    List<FormalParameterElement> params,
    bool isServerDefault,
    Iterable<Reference> extraArgs,
    List<Code> validations,
  ) {
    if (!isServerDefault) {
      return literalList([
        ...extraArgs,
        for (final p in params) toJson(p.type, refer(p.name!)),
      ], CoreTypes.$dynamic);
    }

    final lastRequiredIndex = params.lastIndexWhere((p) => p.isRequired);

    final paramExpressions = <Expression>[];
    Expression? validateRest;
    final restNames = <String>[];
    for (final (index, param) in params.indexed.toList().reversed) {
      if (index <= lastRequiredIndex) {
        paramExpressions.add(toJson(param.type, refer(param.name!)));
        continue;
      }

      if (validateRest == null) {
        validateRest = refer(param.name!).notEqualTo(literalNull);
        restNames.add(param.name!);
      } else {
        validations.add(
          $if(
            refer(
              param.name!,
            ).equalTo(literalNull).and(validateRest.parenthesized),
            [
              CoreTypes.$ArgumentError
                  .newInstance([
                    literalString(
                      'Cannot set optional value to null if any of the '
                      'following parameters (${restNames.join(', ')}) are not '
                      'null.',
                    ),
                    literalString(param.name!),
                  ])
                  .thrown
                  .statement,
            ],
          ),
        );
        validateRest = refer(
          param.name!,
        ).notEqualTo(literalNull).or(validateRest);
        restNames.add(param.name!);
      }

      paramExpressions.add(
        toJson(param.type, refer(param.name!), isNull: true).collectionNonNull,
      );
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
          literalString(p.name!): toJson(
            p.type,
            refer(p.name!),
            isNull: true,
          ).collectionNonNull
        else
          literalString(p.name!): toJson(p.type, refer(p.name!)),
    },
    CoreTypes.$String,
    CoreTypes.$dynamic,
  );
}
