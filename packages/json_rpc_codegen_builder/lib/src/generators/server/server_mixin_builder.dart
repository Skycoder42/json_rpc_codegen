import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart' hide RecordType;
import 'package:collection/collection.dart';
import 'package:dart_test_tools/code_gen.dart';
import 'package:meta/meta.dart';

import '../../extensions/analyzer_extensions.dart';
import '../common/annotations.dart';
import '../common/closure_builder_mixin.dart';
import '../common/method_mapper_mixin.dart';
import '../common/parameter_builder_mixin.dart';
import '../common/registration_builder_mixin.dart';
import '../common/serialization_mixin.dart';
import '../common/types.dart';
import '../proxy_spec.dart';
import 'stream_builder_mixin.dart';

@internal
final class ServerMixinBuilder extends ProxySpec
    with
        MethodMapperMixin,
        ClosureBuilderMixin,
        SerializationMixin,
        ParameterBuilderMixin,
        RegistrationBuilderMixin,
        StreamBuilderMixin {
  final ClassElement _class;

  const ServerMixinBuilder(this._class);

  @override
  Mixin build() => Mixin(
    (b) => b
      ..name = '${_class.publicName}ServerMixin'
      ..on = StreamBuilderMixin.hasStreams(_class)
          ? Types.$PeerBase
          : Types.$ServerBase
      ..fields.addAll(buildStreamFields(_class))
      ..methods.addAll(
        _class.methods.map(
          (method) => mapMethod(
            method,
            buildMethod: (b) => b
              ..annotations.add(Annotations.protected)
              ..returns = switch (getReturnType(method)) {
                (kind: .notification, type: _) => Types.$FutureOr(
                  CoreTypes.$void,
                ),
                (kind: .request, :final type) => Types.$FutureOr(
                  type.toReference(),
                ),
                (kind: .stream, :final type) => CoreTypes.$Stream(
                  type.toReference(),
                ),
              },
            buildParam: (_, builder) => builder
              ..named = false
              ..required = false,
            checkRequired: (_) => true,
          ),
        ),
      )
      ..methods.add(
        buildRegisterMethods(
          _class.methods
              .map(_buildRegisterMethod)
              .followedBy(buildStreamCleanupMethod(_class)),
        ),
      ),
  );

  Code _buildRegisterMethod(MethodElement method) {
    final (:type, :kind) = getReturnType(method);
    if (kind == .stream) {
      return buildStreamRegistrations(method, type);
    }

    final parameterMode = validateParameters(method);
    return parameterMode == ParameterMode.none
        ? buildRegisterMethodWithoutParams(
            method.name!,
            () => Block.of(_buildInvocation(method, type, kind)),
          )
        : buildRegisterMethodWithParams(
            method.name!,
            (params) => Block.of([
              if (parameterMode.hasPositional)
                ...method.formalParameters.mapIndexed(
                  (i, e) => buildPositional(params, i, e),
                ),
              if (parameterMode.hasNamed)
                ...method.formalParameters.map((e) => buildNamed(params, e)),
              ..._buildInvocation(method, type, kind),
            ]),
          );
  }

  Iterable<Code> _buildInvocation(
    MethodElement method,
    DartType returnType,
    ReturnKind returnKind,
  ) sync* {
    final invocation = refer(
      method.name!,
    ).call([for (final p in method.formalParameters) paramRefFor(p)]);

    if (returnKind == .notification ||
        (returnKind == .request && returnType is VoidType)) {
      yield invocation.awaited.statement;
      return;
    }

    if (returnType is RecordType) {
      const resultRef = Reference(r'$result');
      yield declareFinal(
        resultRef.symbol!,
      ).assign(invocation.awaited).statement;
      yield toJson(returnType, resultRef).returned.statement;
    } else {
      yield toJson(
        returnType,
        invocation.awaited.parenthesized,
      ).returned.statement;
    }
  }
}
