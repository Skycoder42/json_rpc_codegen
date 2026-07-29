import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

@internal
abstract base class Annotations {
  Annotations._();

  static const override = Reference('override');

  static const protected = Reference('protected');

  static const visibleForOverriding = Reference('visibleForOverriding');

  static const mustCallSuper = Reference('mustCallSuper');

  static const pragmaPreferInline = Reference("pragma('vm:prefer-inline')");
}
