import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../../builders/if.dart';
import '../../builders/iterable_if.dart';
import '../../readers/defaults_reader.dart';
import '../common/method_mapper_mixin.dart';
import '../common/serialization_mixin.dart';
import '../common/types.dart';

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
          method.parameters,
          isServerDefault,
          extraArgs,
          validations,
        ),
      if (parameterMode.hasNamed)
        _buildNamedParameters(
          method.parameters,
          isServerDefault,
          extraArgs,
        ),
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
    List<ParameterElement> params,
    bool isServerDefault,
    Map<String, Reference> extraArs,
    List<Code> validations,
  ) {
    if (!isServerDefault) {
      return literalList(
        [
          ...extraArs.values,
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
    Expression? validateRest;
    final restNames = <String>[];
    for (final (index, param) in params.indexed.toList().reversed) {
      if (index <= lastRequiredIndex) {
        paramExpressions.add(toJson(param.type, refer(param.name)));
        continue;
      }

      bool? overwriteIsNull;
      if (validateRest == null) {
        overwriteIsNull = false;
        validateRest = refer(param.name).notEqualTo(literalNull);
        restNames.add(param.name);
      } else {
        validations.add(
          $if(
            refer(param.name)
                .equalTo(literalNull)
                .and(validateRest.parenthesized),
            [
              Types.argumentError
                  .newInstance([
                    literalString(
                      'Cannot set optional value to null if any of the '
                      'following parameters (${restNames.join(', ')}) are not '
                      'null.',
                    ),
                    literalString(param.name),
                  ])
                  .thrown
                  .statement,
            ],
          ),
        );
        validateRest =
            refer(param.name).notEqualTo(literalNull).or(validateRest);
        restNames.add(param.name);
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
      [
        ...extraArs.values,
        ...paramExpressions.reversed,
      ],
      Types.dynamic,
    );
  }

  Expression _buildNamedParameters(
    Iterable<ParameterElement> params,
    bool isServerDefault,
    Map<String, Reference> extraArs,
  ) =>
      literalMap(
        {
          for (final MapEntry(key: key, value: value) in extraArs.entries)
            key: value,
          for (final p in params)
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
      );
}
