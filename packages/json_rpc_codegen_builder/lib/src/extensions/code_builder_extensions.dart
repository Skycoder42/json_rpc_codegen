import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

@internal
extension ExpressionX on Expression {
  // ignore: avoid_positional_boolean_parameters for single param
  Expression autoProperty(String name, bool isNullable) =>
      isNullable ? nullSafeProperty(name) : property(name);

  Expression get postfixIncrement =>
      CodeExpression(Block.of([code, const Code('++')]));

  Expression $case(Expression pattern) =>
      CodeExpression(Block.of([code, const Code(' case '), pattern.code]));

  Expression get collectionNonNull =>
      CodeExpression(Block.of([const Code('?'), code]));

  Expression get patternNonNull =>
      CodeExpression(Block.of([code, const Code('?')]));
}

@internal
extension TypeReferenceX on TypeReference {
  TypeReference boundTo(TypeReference type) => TypeReference(
    (b) => b
      ..replace(this)
      ..bound = type,
  );
}

@internal
extension SpecIterableX on Iterable<Spec> {
  void acceptAll<R>(SpecVisitor<R> visitor, [R? context]) => forEach((element) {
    element.accept<R>(visitor, context);
  });
}
