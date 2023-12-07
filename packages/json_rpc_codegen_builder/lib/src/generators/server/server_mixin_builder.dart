import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
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

/// @nodoc
@internal
final class ServerMixinBuilder extends ProxySpec
    with
        MethodMapperMixin,
        ClosureBuilderMixin,
        SerializationMixin,
        ParameterBuilderMixin,
        RegistrationBuilderMixin {
  static const _rpcGetterRef = Reference('jsonRpcInstance');

  final ClassElement _class;

  /// @nodoc
  const ServerMixinBuilder(this._class);

  @override
  Mixin build() => Mixin(
        (b) => b
          ..name = '${_class.publicName}ServerMixin'
          ..on = Types.serverBase
          ..methods.addAll(
            _class.methods.map(
              (method) => mapMethod(
                method,
                buildMethod: (b) => b
                  ..annotations.add(Annotations.protected)
                  ..returns = Types.futureOr(b.returns),
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
                (method) => buildRegisterMethod(
                  _rpcGetterRef,
                  method,
                ),
              ),
            ),
          ),
      );
}
