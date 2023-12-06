import 'package:code_builder/code_builder.dart';
// ignore: implementation_imports
import 'package:code_builder/src/visitors.dart';
import 'package:meta/meta.dart';

/// @nodoc
@internal
extension ExpressionX on Expression {
  /// @nodoc
  Expression autoProperty(String name, bool isNullable) =>
      isNullable ? nullSafeProperty(name) : property(name);

  Expression get postfixIncrement => CodeExpression(
        Block.of([
          code,
          const Code('++'),
        ]),
      );
}

/// @nodoc
@internal
extension TypeReferenceX on TypeReference {
  /// @nodoc
  TypeReference asNullable(bool isNullable) => TypeReference(
        (b) => b
          ..replace(this)
          ..isNullable = isNullable,
      );

  /// @nodoc
  TypeReference boundTo(TypeReference type) => TypeReference(
        (b) => b
          ..replace(this)
          ..bound = type,
      );
}

/// @nodoc
@internal
extension SpecIterableX on Iterable<Spec> {
  /// @nodoc
  void acceptAll<R>(SpecVisitor<R> visitor, [R? context]) => forEach((element) {
        element.accept<R>(visitor, context);
      });
}
