import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_test_tools/code_gen.dart';
import 'package:meta/meta.dart';

import '../common/closure_builder_mixin.dart';
import '../common/constants.dart';
import '../common/method_mapper_mixin.dart';
import '../common/parameter_builder_mixin.dart';
import '../common/registration_builder_mixin.dart';
import '../common/serialization_mixin.dart';
import '../common/stream_support.dart';
import '../common/types.dart';
import '../proxy_spec.dart';
import 'invocation_builder_mixin.dart';
import 'stream_builder_mixin.dart';

@internal
final class ClientMixinBuilder extends ProxySpec
    with
        MethodMapperMixin,
        ClosureBuilderMixin,
        SerializationMixin,
        InvocationBuilderMixin,
        ParameterBuilderMixin,
        RegistrationBuilderMixin,
        StreamSupportMixin,
        ClientStreamBuilderMixin {
  final ClassElement _class;

  const ClientMixinBuilder(this._class);

  @override
  Mixin build() => Mixin(
    (b) => b
      ..name = '${_class.name}ClientMixin'
      ..on = StreamRpc.hasStreams(_class) ? Types.$PeerBase : Types.$ClientBase
      ..implements.add(_class.toReference())
      ..fields.addAll(buildStreamFields(_class))
      ..methods.addAll(
        [
          ..._class.methods.map(_buildMethod),
          buildStreamListeners(_class),
        ].nonNulls,
      ),
  );

  Method _buildMethod(MethodElement method) {
    final (:type, :kind) = getReturnType(method);
    switch (kind) {
      case .notification:
        return _buildNotificationMethod(method);
      case .request:
        return _buildRequestMethod(method, type);
      case .stream:
        return _buildStreamMethod(method, type);
    }
  }

  Method _buildNotificationMethod(MethodElement method) => mapMethod(
    method,
    buildMethod: (b) => b
      ..returns = CoreTypes.$void
      ..body = _buildNotificationBody(method),
  );

  Method _buildRequestMethod(MethodElement method, DartType returnType) =>
      mapMethod(
        method,
        buildMethod: (b) => b
          ..returns = CoreTypes.$Future(returnType.toReference())
          ..modifier = .async
          ..body = _buildRequestBody(method, returnType),
      );

  Method _buildStreamMethod(MethodElement method, DartType streamType) =>
      mapMethod(
        method,
        buildMethod: (b) => b
          ..returns = CoreTypes.$Stream(streamType.toReference())
          ..body = buildStreamBody(method, streamType),
      );

  Code _buildNotificationBody(MethodElement method) =>
      buildMethodInvocation(JsonRpcInstance.sendNotification, method);

  Code _buildRequestBody(MethodElement method, DartType returnType) =>
      buildMethodInvocation(
        JsonRpcInstance.sendRequest,
        method,
        buildReturn: (invocation) => buildConvertedReturn(
          returnType,
          invocation,
          (type, value) => methodFromJson(method, type, value),
        ),
      );
}
