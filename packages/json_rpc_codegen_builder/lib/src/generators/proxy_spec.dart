import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

@internal
abstract base class ProxySpec implements Spec {
  const new();

  Spec build();

  @override
  R accept<R>(SpecVisitor<R> visitor, [R? context]) =>
      build().accept(visitor, context);
}
