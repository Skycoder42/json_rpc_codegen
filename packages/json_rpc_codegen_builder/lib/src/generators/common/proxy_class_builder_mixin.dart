import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import 'constants.dart';

@internal
base mixin ProxyClassBuilderMixin {
  @protected
  Class buildProxyClass({
    required String name,
    required Reference extend,
    required String fromName,
    bool abstract = false,
    Iterable<Parameter> extraParams = const [],
  }) => Class(
    (b) => b
      ..name = name
      ..abstract = abstract
      ..extend = extend
      ..mixins.add(TypeReference((b) => b..symbol = '${name}Mixin'))
      ..constructors.addAll(_buildConstructors(fromName, extraParams)),
  );

  Iterable<Constructor> _buildConstructors(
    String fromName, [
    Iterable<Parameter> extraParams = const [],
  ]) sync* {
    yield _channelConstructor(extraParams);
    yield _channelConstructor(extraParams, 'withoutJson');
    yield _fromInstance(fromName);
  }

  Constructor _channelConstructor(
    Iterable<Parameter> extraParams, [
    String? name,
  ]) {
    const channelParamRef = Reference('channel');
    final superRef = refer('super');
    return Constructor(
      (b) => b
        ..name = name
        ..requiredParameters.add(
          Parameter(
            (b) => b
              ..name = channelParamRef.symbol!
              ..toSuper = true,
          ),
        )
        ..optionalParameters.addAll(extraParams)
        ..initializers.add(
          (name != null ? superRef.property(name) : superRef)
              .call(const [])
              .code,
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
      ..initializers.add(refer('super').property(name).call(const []).code),
  );
}
