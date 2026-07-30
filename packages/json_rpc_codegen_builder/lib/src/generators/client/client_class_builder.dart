import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../common/base_constructor_builder_mixin.dart';
import '../common/types.dart';
import '../proxy_spec.dart';
import 'stream_builder_mixin.dart';

@internal
final class ClientClassBuilder extends ProxySpec
    with BaseConstructorBuilderMixin {
  final ClassElement _class;

  const ClientClassBuilder(this._class);

  @override
  Class build() {
    final hasStreams = StreamBuilderMixin.hasStreams(_class);
    return Class(
      (b) => b
        ..name = '${_class.name}Client'
        ..extend = hasStreams ? Types.$PeerBase : Types.$ClientBase
        ..mixins.add(
          TypeReference((b) => b..symbol = '${_class.name}ClientMixin'),
        )
        ..constructors.addAll(
          buildConstructors(hasStreams ? 'fromPeer' : 'fromClient', [
            Parameter(
              (b) => b
                ..name = 'idGenerator'
                ..named = true
                ..toSuper = true,
            ),
            if (hasStreams)
              Parameter(
                (b) => b
                  ..name = 'onUnhandledError'
                  ..named = true
                  ..toSuper = true,
              ),
            if (hasStreams)
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
}
