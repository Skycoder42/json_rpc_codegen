import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

@internal
extension FormalParameterElementX on FormalParameterElement {
  /// The default value of this parameter as an expression, or `null` literal.
  Expression get defaultValueExpression =>
      hasDefaultValue ? CodeExpression(Code(defaultValueCode!)) : literalNull;

  /// The default value of this parameter as code, or `null` if it has none.
  Code? get defaultValueCodeOrNull =>
      hasDefaultValue ? Code(defaultValueCode!) : null;
}
