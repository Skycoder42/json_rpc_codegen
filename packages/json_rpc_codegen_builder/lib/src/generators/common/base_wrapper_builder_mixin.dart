import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../proxy_spec.dart';
import 'types.dart';

/// @nodoc
@internal
base mixin BaseWrapperBuilderMixin on ProxySpec {
  ///@nodoc
  Iterable<Constructor> buildConstructors(Reference clientRef) sync* {
    yield _default(clientRef);
    yield _withoutJson(clientRef);
  }

  /// @nodoc
  Iterable<Method> buildWrapperMethods(Reference baseRef) sync* {
    yield _done(baseRef);
    yield _isClosed(baseRef);
    yield _listen(baseRef);
    yield _close(baseRef);
  }

  ///@nodoc
  @visibleForOverriding
  TypeReference get baseType;

  ///@nodoc
  @visibleForOverriding
  Iterable<Parameter> get extraOptionalParams => const [];

  ///@nodoc
  @visibleForOverriding
  Map<String, Expression> get extraArgs => const {};

  Constructor _default(Reference clientRef) {
    const channelParamRef = Reference('channel');
    return Constructor(
      (b) => b
        ..requiredParameters.add(
          Parameter(
            (b) => b
              ..name = channelParamRef.symbol!
              ..type = Types.streamChannel(Types.string),
          ),
        )
        ..optionalParameters.addAll(extraOptionalParams)
        ..initializers.add(
          clientRef
              .assign(baseType.newInstance([channelParamRef], extraArgs))
              .code,
        ),
    );
  }

  Constructor _withoutJson(Reference baseRef) {
    const channelParamRef = Reference('channel');
    return Constructor(
      (b) => b
        ..name = 'withoutJson'
        ..requiredParameters.add(
          Parameter(
            (b) => b
              ..name = channelParamRef.symbol!
              ..type = Types.streamChannel(),
          ),
        )
        ..optionalParameters.addAll(extraOptionalParams)
        ..initializers.add(
          baseRef
              .assign(
                baseType.newInstanceNamed(
                  'withoutJson',
                  [channelParamRef],
                  extraArgs,
                ),
              )
              .code,
        ),
    );
  }

  Method _done(Reference baseRef) => Method(
        (b) => b
          ..name = 'done'
          ..type = MethodType.getter
          ..returns = Types.future(Types.$void)
          ..body = baseRef.property('done').code,
      );

  Method _isClosed(Reference baseRef) => Method(
        (b) => b
          ..name = 'isClosed'
          ..type = MethodType.getter
          ..returns = Types.$bool
          ..body = baseRef.property('isClosed').code,
      );

  Method _listen(Reference baseRef) => Method(
        (b) => b
          ..name = 'listen'
          ..returns = Types.future(Types.$void)
          ..body = baseRef.property('listen').call(const []).code,
      );

  Method _close(Reference baseRef) => Method(
        (b) => b
          ..name = 'close'
          ..returns = Types.future(Types.$void)
          ..body = baseRef.property('close').call(const []).code,
      );
}
