import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart' hide RecordType;
import 'package:collection/collection.dart';
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

/// @nodoc
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

  /// @nodoc
  const ServerMixinBuilder(this._class);

  @override
  Mixin build() => Mixin(
        (b) => b
          ..name = '${_class.publicName}ServerMixin'
          ..on = StreamBuilderMixin.hasStreams(_class)
              ? Types.peerBase
              : Types.serverBase
          ..fields.addAll(buildStreamFields(_class))
          ..methods.addAll(
            _class.methods.map(
              (method) => mapMethod(
                method,
                buildMethod: (b) {
                  b.annotations.add(Annotations.protected);
                  if (!method.returnType.isDartAsyncStream) {
                    b.returns = Types.futureOr(b.returns);
                  }
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
              _class.methods.map(
                _buildRegisterMethod,
              ),
            ),
          ),
      );

  Code _buildRegisterMethod(MethodElement method) {
    if (method.returnType.isDartAsyncStream) {
      return buildStreamRegistrations(method);
    }

    final parameterMode = validateParameters(method);
    return parameterMode == ParameterMode.none
        ? buildRegisterMethodWithoutParams(
            method.name,
            () => Block.of(_buildInvocation(method)),
          )
        : buildRegisterMethodWithParams(
            method.name,
            (params) => Block.of([
              if (parameterMode.hasPositional)
                ...method.parameters
                    .mapIndexed((i, e) => buildPositional(params, i, e)),
              if (parameterMode.hasNamed)
                ...method.parameters.map((e) => buildNamed(params, e)),
              ..._buildInvocation(method),
            ]),
          );
  }

  Iterable<Code> _buildInvocation(
    MethodElement method,
  ) sync* {
    final invocation = refer(method.name).call([
      for (final p in method.parameters) paramRefFor(p),
    ]);

    if (method.returnType is VoidType || method.returnType.isDartCoreNull) {
      yield invocation.awaited.statement;
      return;
    }

    final returnType = getReturnType(method);
    if (returnType is RecordType) {
      const resultRef = Reference(r'$result');
      yield declareFinal(resultRef.symbol!)
          .assign(invocation.awaited)
          .statement;
      yield toJson(returnType, resultRef).returned.statement;
    } else {
      yield toJson(
        returnType,
        invocation.awaited.parenthesized,
      ).returned.statement;
    }
  }
}
