import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../common/base_constructor_builder_mixin.dart';
import '../common/types.dart';
import '../proxy_spec.dart';

/// @nodoc
@internal
final class ServerClassBuilder extends ProxySpec
    with BaseConstructorBuilderMixin {
  final ClassElement _class;

  /// @nodoc
  const ServerClassBuilder(this._class);

  @override
  Class build() => Class(
        (b) => b
          ..name = '${_class.name}Server'
          ..abstract = true
          ..extend = Types.serverBase
          ..mixins.add(
            TypeReference((b) => b..symbol = '${_class.name}ServerMixin'),
          )
          ..constructors.addAll(
            buildConstructors('fromServer', [
              Parameter(
                (b) => b
                  ..name = 'onUnhandledError'
                  ..named = true
                  ..toSuper = true,
              ),
              Parameter(
                (b) => b
                  ..name = 'strictProtocolChecks'
                  ..named = true
                  ..toSuper = true,
              ),
            ]),
          ),
      );
}
