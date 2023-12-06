import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

/// @nodoc
@internal
class IterableIf extends Expression {
  final Spec _condition;
  final Spec _then;
  final Spec? _else;

  /// @nodoc
  const IterableIf(
    Expression this._condition,
    Expression this._then, [
    Expression? this._else,
  ]);

  @override
  R accept<R>(covariant ExpressionVisitor<R> visitor, [R? context]) {
    if (context is! StringSink) {
      throw UnsupportedError(
        'Cannot build an IterableIf without without a sink',
      );
    }

    context.write('if(');
    _condition.accept(visitor, context);
    context.write(')');
    _then.accept(visitor, context);

    if (_else != null) {
      context.write(' else ');
      _else.accept(visitor, context);
    }

    return context;
  }
}
