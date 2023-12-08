import 'package:code_builder/code_builder.dart';
// ignore: implementation_imports
import 'package:code_builder/src/specs/code.dart';
import 'package:meta/meta.dart';

@internal
class ForIn implements Code {
  final String _variable;
  final Spec _iterable;
  final Code _body;

  ForIn(
    this._variable,
    Expression this._iterable,
    this._body,
  );

  @override
  R accept<R>(covariant CodeVisitor<R> visitor, [R? context]) {
    if (context is! StringSink) {
      throw UnsupportedError('Cannot build a ForIn without without a sink');
    }

    context.write('for (');
    // ignore: unnecessary_cast
    (declareFinal(_variable) as Spec).accept(visitor, context);
    context.write(' in ');
    _iterable.accept(visitor, context);
    context.write(') {');
    _body.accept(visitor, context);
    context.write('}');

    return context;
  }
}
