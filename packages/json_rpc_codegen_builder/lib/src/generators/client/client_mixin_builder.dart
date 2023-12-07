import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

import '../../extensions/analyzer_extensions.dart';
import '../../readers/defaults_reader.dart';
import '../common/closure_builder_mixin.dart';
import '../common/constants.dart';
import '../common/method_mapper_mixin.dart';
import '../common/parameter_builder_mixin.dart';
import '../common/registration_builder_mixin.dart';
import '../common/serialization_mixin.dart';
import '../common/types.dart';
import '../proxy_spec.dart';
import 'invocation_builder_mixin.dart';
import 'stream_builder_mixin.dart';

/// @nodoc
@internal
final class ClientMixinBuilder extends ProxySpec
    with
        MethodMapperMixin,
        ClosureBuilderMixin,
        SerializationMixin,
        InvocationBuilderMixin,
        ParameterBuilderMixin,
        RegistrationBuilderMixin,
        StreamBuilderMixin {
  final ClassElement _class;

  /// @nodoc
  const ClientMixinBuilder(this._class);

  /// @nodoc
  @override
  Mixin build() => Mixin(
        (b) => b
          ..name = '${_class.publicName}ClientMixin'
          ..on = StreamBuilderMixin.hasStreams(_class)
              ? Types.peerBase
              : Types.clientBase
          ..fields.addAll(buildStreamFields(_class))
          ..methods.addAll(
            [
              ..._class.methods.map(_buildMethod),
              buildStreamListeners(_class),
            ].whereNotNull(),
          ),
      );

  Method _buildMethod(MethodElement method) {
    final returnType = getReturnType(method);
    if (returnType is VoidType) {
      return _buildNotificationMethod(method);
    } else if (returnType.isDartAsyncStream) {
      return _buildStreamMethod(method);
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

  Method _buildStreamMethod(MethodElement method) => mapMethod(
        method,
        buildMethod: (b) => b..body = buildStreamBody(method),
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
          todo: 'Change the type to ${parameter.type}? '
              'or specify a default value',
        );
      }
    } else {
      builder.type = Types.fromDartType(parameter.type, isNull: true);
    }
  }

  Code _buildNotificationBody(MethodElement method) => buildMethodInvocation(
        JsonRpcInstance.sendNotification,
        method,
        isAsync: false,
      );

  Code _buildRequestBody(MethodElement method, DartType returnType) =>
      buildMethodInvocation(
        JsonRpcInstance.sendRequest,
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
}
