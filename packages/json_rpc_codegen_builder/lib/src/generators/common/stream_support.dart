import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../../builders/for_in.dart';
import 'closure_builder_mixin.dart';
import 'constants.dart';

@internal
enum StreamSubMethod {
  listen,
  data,
  error,
  done,
  cancel,
  pause,
  resume;

  String get suffix => '#$name';
}

@internal
sealed class StreamRpc {
  static const streamIdRef = Reference(r'$streamId');
  static const errorRef = Reference(r'$error');
  static const stackTraceRef = Reference(r'$stackTrace');

  static bool hasStreams(ClassElement clazz) =>
      clazz.methods.any((m) => m.returnType.isDartAsyncStream);

  static String methodName(MethodElement method, StreamSubMethod sub) =>
      '${method.name}${sub.suffix}';
}

@internal
base mixin StreamSupportMixin on ClosureBuilderMixin {
  @protected
  Expression streamIdFrom(Reference params, [Expression? index]) =>
      params.index(index ?? literalNum(0)).property('asInt');

  @protected
  Iterable<Code> buildStreamCleanup(
    ClassElement clazz, {
    required Reference map,
    required Reference itemRef,
    required String dispose,
  }) sync* {
    if (!StreamRpc.hasStreams(clazz)) {
      return;
    }

    yield Globals.unawaitedRef.call([
      JsonRpcInstance.ref.property('done').property('then').call([
        closure1(
          '_',
          (_) => Block.of([
            ForIn(
              itemRef.symbol!,
              map.property('values'),
              Globals.unawaitedRef.call([
                itemRef.property(dispose).call(const []),
              ]).statement,
            ),
            map.property('clear').call(const []).statement,
          ]),
        ),
      ]),
    ]).statement;
  }
}
