import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

/// @nodoc
@internal
abstract base class Annotations {
  Annotations._();

  /// @nodoc
  static const Reference override = Reference('override');

  /// @nodoc
  static const Reference protected = Reference('protected');

  /// @nodoc
  static const Reference visibleForOverriding =
      Reference('visibleForOverriding');

  /// @nodoc
  static const Reference mustCallSuper = Reference('mustCallSuper');
}
