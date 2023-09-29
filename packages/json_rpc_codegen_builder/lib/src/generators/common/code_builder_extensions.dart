import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

/// @nodoc
@internal
extension ExpressionX on Expression {
  /// @nodoc
  Expression autoProperty(String name, bool isNullable) =>
      isNullable ? nullSafeProperty(name) : property(name);
}
