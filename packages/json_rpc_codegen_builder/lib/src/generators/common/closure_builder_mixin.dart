import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../proxy_spec.dart';

/// @nodoc
@internal
base mixin ClosureBuilderMixin on ProxySpec {
  /// @nodoc
  Expression closure0(
    Code Function() buildBody, {
    MethodModifier? modifier,
  }) =>
      Method(
        (b) => b
          ..modifier = modifier
          ..body = buildBody(),
      ).closure;

  /// @nodoc
  Expression closure1(
    String param1,
    Code Function(Reference p1) buildBody, {
    MethodModifier? modifier,
    TypeReference? type1,
  }) =>
      Method(
        (b) => b
          ..requiredParameters.add(
            Parameter(
              (b) => b
                ..name = param1
                ..type = type1,
            ),
          )
          ..modifier = modifier
          ..body = buildBody(refer(param1)),
      ).closure;

  /// @nodoc
  Expression closure2(
    String param1,
    String param2,
    Code Function(Reference p1, Reference p2) buildBody, {
    MethodModifier? modifier,
    TypeReference? type1,
    TypeReference? type2,
  }) =>
      Method(
        (b) => b
          ..requiredParameters.addAll([
            Parameter(
              (b) => b
                ..name = param1
                ..type = type1,
            ),
            Parameter(
              (b) => b
                ..name = param2
                ..type = type2,
            ),
          ])
          ..modifier = modifier
          ..body = buildBody(refer(param1), refer(param2)),
      ).closure;
}
