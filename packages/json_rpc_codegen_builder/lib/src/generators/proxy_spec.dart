import 'package:code_builder/code_builder.dart';
// ignore: implementation_imports
import 'package:code_builder/src/visitors.dart';
import 'package:meta/meta.dart';

/// @nodoc
@internal
abstract base class ProxySpec<T extends Spec> implements Spec {
  /// @nodoc
  const ProxySpec();

  /// @nodoc
  T build();

  @override
  R accept<R>(SpecVisitor<R> visitor, [R? context]) =>
      build().accept(visitor, context);
}
