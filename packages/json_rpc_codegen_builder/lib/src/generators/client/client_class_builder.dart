import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../common/proxy_class_builder_mixin.dart';
import '../common/stream_support.dart';
import '../common/types.dart';
import '../proxy_spec.dart';

@internal
final class ClientClassBuilder extends ProxySpec with ProxyClassBuilderMixin {
  final ClassElement _class;

  const new(this._class);

  @override
  Class build() {
    final hasStreams = StreamRpc.hasStreams(_class);
    return buildProxyClass(
      name: '${_class.name}Client',
      extend: hasStreams ? Types.$PeerBase : Types.$ClientBase,
      fromName: hasStreams ? 'fromPeer' : 'fromClient',
      extraParams: [
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
      ],
    );
  }
}
