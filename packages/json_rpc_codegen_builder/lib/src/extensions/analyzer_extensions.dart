import 'package:analyzer/dart/element/element.dart';
import 'package:meta/meta.dart';

/// @nodoc
@internal
extension ClassElementX on ClassElement {
  static final _regexp = RegExp('^_+');

  /// @nodoc
  String get publicName => isPrivate ? name.replaceFirst(_regexp, '') : name;
}
