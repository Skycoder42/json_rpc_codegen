import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../../extensions/analyzer_extensions.dart';
import '../common/base_constructor_builder_mixin.dart';
import '../common/types.dart';
import '../proxy_spec.dart';
import 'stream_builder_mixin.dart';

/// @nodoc
@internal
final class ClientClassBuilder extends ProxySpec
    with BaseConstructorBuilderMixin {
  final ClassElement _class;

  /// @nodoc
  const ClientClassBuilder(this._class);

  @override
  Class build() {
    final hasStreams = StreamBuilderMixin.hasStreams(_class);
    return Class(
      (b) => b
        ..name = '${_class.publicName}Client'
        ..extend = hasStreams ? Types.peerBase : Types.clientBase
        ..mixins.add(
          TypeReference((b) => b..symbol = '${_class.publicName}ClientMixin'),
        )
        ..constructors.addAll(
          buildConstructors(
            hasStreams ? 'fromPeer' : 'fromClient',
            hasStreams
                ? [
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
                  ]
                : const [],
          ),
        ),
    );
  }
}
