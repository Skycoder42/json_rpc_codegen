import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

/// @nodoc
@internal
class IterableIf extends Expression {
  /// @nodoc
  final Expression condition;

  /// @nodoc
  final Expression then;

  /// @nodoc
  final Expression? $else;

  /// @nodoc
  const IterableIf(
    this.condition,
    this.then, [
    this.$else,
  ]);

  @override
  R accept<R>(covariant ExpressionVisitor<R> visitor, [R? context]) {
    final emitter = visitor as DartEmitter;
    var sink = context as StringSink?;

    sink = const Code('if (').accept(emitter, sink);
    sink = condition.accept(emitter, sink);
    const Code(') ').accept(emitter, sink);
    then.accept(emitter, sink);

    if ($else != null) {
      const Code(' else ').accept(emitter, sink);
      $else!.accept(emitter, sink);
    }

    return sink! as R;
  }
}
