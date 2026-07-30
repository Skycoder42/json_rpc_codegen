import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart' hide RecordType;
import 'package:collection/collection.dart';
import 'package:dart_test_tools/code_gen.dart';
import 'package:meta/meta.dart';

import '../common/closure_builder_mixin.dart';
import '../common/method_mapper_mixin.dart';
import '../common/parameter_builder_mixin.dart';
import '../common/registration_builder_mixin.dart';
import '../common/serialization_mixin.dart';
import '../common/stream_support.dart';
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
        StreamSupportMixin,
        ServerStreamBuilderMixin {
  final ClassElement _class;

  const ServerMixinBuilder(this._class);

  @override
  Mixin build() => Mixin(
    (b) => b
      ..name = '${_class.name}ServerMixin'
      ..on = StreamRpc.hasStreams(_class) ? Types.$PeerBase : Types.$ServerBase
      ..implements.add(_class.toReference())
      ..fields.addAll(buildStreamFields(_class))
      ..methods.addAll(
        _class.methods
            .where((m) => getReturnType(m).kind == .notification)
            .map(
              (method) => mapMethod(
                method,
                buildMethod: (b) =>
                    b..returns = Types.$FutureOr(CoreTypes.$void),
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
    final invocation = refer(method.name!).call(
      [
        for (final p in method.formalParameters.where((p) => p.isPositional))
          paramRefFor(p),
      ],
      {
        for (final p in method.formalParameters.where((p) => p.isNamed))
          p.name!: paramRefFor(p),
      },
    );

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
