import 'package:code_builder/code_builder.dart';
// ignore: implementation_imports
import 'package:code_builder/src/visitors.dart';
import 'package:meta/meta.dart';

import '../extensions/code_builder_extensions.dart';

class _CatchInfo {
  final Spec? on;
  final Spec? error;
  final Spec? stackTrace;
  final Iterable<Spec> body;

  _CatchInfo(this.on, this.error, this.stackTrace, this.body);
}

/// @nodoc
@internal
class TryCatch implements Code, Spec {
  final Iterable<Spec> _try;
  final List<_CatchInfo> _catch;
  final Iterable<Spec>? _finally;

  TryCatch._(this._try, this._catch, this._finally);

  TryCatch catch$({
    TypeReference? on,
    Reference? error,
    Reference? stackTrace,
    required Iterable<Code> body,
  }) {
    if (on == null && error == null) {
      throw ArgumentError('Either on or error must be set!');
    }
    return TryCatch._(
      _try,
      [..._catch, _CatchInfo(on, error, stackTrace, body)],
      _finally,
    );
  }

  TryCatch finally$(Iterable<Code> body) {
    if (_finally != null) {
      throw StateError('Can only define finally once');
    }
    return TryCatch._(_try, _catch, body);
  }

  @override
  R accept<R>(SpecVisitor<R> visitor, [R? context]) {
    if (context is! StringSink) {
      throw UnsupportedError('Cannot use try-catch without a sink');
    }

    if (_catch.isEmpty && _finally == null) {
      throw StateError('Must define at least one catch or finally');
    }

    context.write('try {');
    _try.acceptAll(visitor, context);
    context.write('}');

    for (final catchInfo in _catch) {
      if (catchInfo.on != null) {
        context.write(' on ');
        catchInfo.on!.accept(visitor, context);
      }

      if (catchInfo.error != null) {
        context.write(' catch(');
        catchInfo.error!.accept(visitor, context);

        if (catchInfo.stackTrace != null) {
          context.write(', ');
          catchInfo.stackTrace!.accept(visitor, context);
        }

        context.write(') ');
      }

      context.write('{');
      catchInfo.body.acceptAll(visitor, context);
      context.write('}');
    }

    if (_finally != null) {
      context.write(' finally {');
      _finally.acceptAll(visitor, context);
      context.write('}');
    }

    return context;
  }
}

/// @nodoc
@internal
TryCatch try$(Iterable<Code> body) => TryCatch._(
      body,
      const [],
      null,
    );
