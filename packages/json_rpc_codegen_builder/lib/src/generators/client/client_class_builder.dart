import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../../extensions/analyzer_extensions.dart';
import '../common/base_constructor_builder_mixin.dart';
import '../common/types.dart';
import '../proxy_spec.dart';

/// @nodoc
@internal
final class ClientClassBuilder extends ProxySpec
    with BaseConstructorBuilderMixin {
  final ClassElement _class;

  /// @nodoc
  const ClientClassBuilder(this._class);

  @override
  Class build() => Class(
        (b) => b
          ..name = '${_class.publicName}Client'
          ..extend = Types.clientBase
          ..mixins.add(
            TypeReference((b) => b..symbol = '${_class.publicName}ClientMixin'),
          )
          ..constructors.addAll(buildConstructors('fromClient')),
      );
}
