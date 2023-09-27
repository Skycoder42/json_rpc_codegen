import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../common/types.dart';

/// @nodoc
@internal
class WrapperBuilder {
  final Reference _clientRef;

  /// @nodoc
  const WrapperBuilder(this._clientRef);

  ///@nodoc
  Iterable<Constructor> buildConstructors() sync* {
    yield _fromChannel();
    yield _withoutJson();
    yield _fromClient();
  }

  /// @nodoc
  Iterable<Method> buildWrapperMethods() sync* {
    yield _done();
    yield _isClosed();
    yield _listen();
    yield _close();
    yield _withBatch();
  }

  Constructor _fromChannel() {
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
        ..initializers.add(
          _clientRef
              .assign(Types.jsonRpc2Client.newInstance([channelParamRef]))
              .code,
        ),
    );
  }

  Constructor _withoutJson() {
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
        ..initializers.add(
          _clientRef
              .assign(
                Types.jsonRpc2Client.newInstanceNamed(
                  'withoutJson',
                  [channelParamRef],
                ),
              )
              .code,
        ),
    );
  }

  Constructor _fromClient() {
    const clientParamRef = Reference('client');
    return Constructor(
      (b) => b
        ..name = 'fromClient'
        ..requiredParameters.add(
          Parameter(
            (b) => b
              ..name = clientParamRef.symbol!
              ..type = Types.jsonRpc2Client,
          ),
        )
        ..initializers.add(
          _clientRef.assign(clientParamRef).code,
        ),
    );
  }

  Method _done() => Method(
        (b) => b
          ..name = 'done'
          ..type = MethodType.getter
          ..returns = Types.future(Types.$void)
          ..body = _clientRef.property('done').code,
      );

  Method _isClosed() => Method(
        (b) => b
          ..name = 'isClosed'
          ..type = MethodType.getter
          ..returns = Types.bool
          ..body = _clientRef.property('isClosed').code,
      );

  Method _listen() => Method(
        (b) => b
          ..name = 'listen'
          ..returns = Types.future(Types.$void)
          ..body = _clientRef.property('listen').call(const []).code,
      );

  Method _close() => Method(
        (b) => b
          ..name = 'close'
          ..returns = Types.future(Types.$void)
          ..body = _clientRef.property('close').call(const []).code,
      );

  Method _withBatch() {
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
        ..body = _clientRef.property('withBatch').call([
          callbackRef,
        ]).code,
    );
  }
}