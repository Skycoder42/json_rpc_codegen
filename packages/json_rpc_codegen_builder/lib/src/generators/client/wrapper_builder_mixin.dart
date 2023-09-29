import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../common/base_wrapper_builder_mixin.dart';
import '../common/types.dart';
import '../proxy_spec.dart';

/// @nodoc
@internal
base mixin WrapperBuilderMixin on ProxySpec, BaseWrapperBuilderMixin {
  ///@nodoc
  @override
  Iterable<Constructor> buildConstructors(Reference clientRef) sync* {
    yield* super.buildConstructors(clientRef);
    yield _fromClient(clientRef);
  }

  /// @nodoc
  @override
  Iterable<Method> buildWrapperMethods(Reference clientRef) sync* {
    yield* super.buildWrapperMethods(clientRef);
    yield _withBatch(clientRef);
  }

  ///@nodoc
  @override
  @visibleForOverriding
  TypeReference get baseType => Types.jsonRpc2Client;

  Constructor _fromClient(Reference clientRef) => Constructor(
        (b) => b
          ..name = 'fromClient'
          ..requiredParameters.add(
            Parameter(
              (b) => b
                ..name = clientRef.symbol!
                ..toThis = true,
            ),
          ),
      );

  Method _withBatch(Reference clientRef) {
    const callbackRef = Reference('callback');
    return Method(
      (b) => b
        ..name = 'withBatch'
        ..returns = Types.$void
        ..requiredParameters.add(
          Parameter(
            (b) => b
              ..name = callbackRef.symbol!
              ..type = FunctionType(),
          ),
        )
        ..body = clientRef.property('withBatch').call([
          callbackRef,
        ]).code,
    );
  }
}
