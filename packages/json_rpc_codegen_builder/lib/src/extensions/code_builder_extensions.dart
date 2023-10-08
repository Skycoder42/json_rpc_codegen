import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

/// @nodoc
@internal
extension ExpressionX on Expression {
  /// @nodoc
  Expression autoProperty(String name, bool isNullable) =>
      isNullable ? nullSafeProperty(name) : property(name);
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
