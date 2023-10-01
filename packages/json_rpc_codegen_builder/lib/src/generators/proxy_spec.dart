import 'package:code_builder/code_builder.dart';
// ignore: implementation_imports
import 'package:code_builder/src/visitors.dart';
import 'package:meta/meta.dart';

/// @nodoc
@internal
abstract base class ProxySpec implements Spec {
  /// @nodoc
  const ProxySpec();

  /// @nodoc
  Spec build();

  @override
  R accept<R>(SpecVisitor<R> visitor, [R? context]) =>
      build().accept(visitor, context);
}
