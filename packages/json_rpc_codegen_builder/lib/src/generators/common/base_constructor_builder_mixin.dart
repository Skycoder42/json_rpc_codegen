import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../proxy_spec.dart';
import 'constants.dart';

@internal
base mixin BaseConstructorBuilderMixin on ProxySpec {
  @protected
  Iterable<Constructor> buildConstructors(
    String fromName, [
    Iterable<Parameter> extraParams = const [],
  ]) sync* {
    yield _default(extraParams);
    yield _withoutJson(extraParams);
    yield _fromInstance(fromName);
  }

  Constructor _default(Iterable<Parameter> extraParams) {
    const channelParamRef = Reference('channel');
    return Constructor(
      (b) => b
        ..requiredParameters.add(
          Parameter(
            (b) => b
              ..name = channelParamRef.symbol!
              ..toSuper = true,
          ),
        )
        ..optionalParameters.addAll(extraParams)
        ..initializers.add(refer('super').call(const []).code),
    );
  }

  Constructor _withoutJson(Iterable<Parameter> extraParams) {
    const channelParamRef = Reference('channel');
    return Constructor(
      (b) => b
        ..name = 'withoutJson'
        ..requiredParameters.add(
          Parameter(
            (b) => b
              ..name = channelParamRef.symbol!
              ..toSuper = true,
          ),
        )
        ..optionalParameters.addAll(extraParams)
        ..initializers.add(
          refer('super').property('withoutJson').call(const []).code,
        ),
    );
  }

  Constructor _fromInstance(String name) => Constructor(
        (b) => b
          ..name = name
          ..requiredParameters.add(
            Parameter(
              (b) => b
                ..name = JsonRpcInstance.ref.symbol!
                ..toSuper = true,
            ),
          )
          ..initializers.add(
            refer('super').property(name).call(const []).code,
          ),
      );
}
