import 'package:collection/collection.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'models/common.dart';

/// [Color] deliberately does not implement [Object.==], to keep custom types
/// without value equality covered - it is compared by it's JSON representation
/// instead.
class _ColorEquality implements Equality<Object?> {
  const _ColorEquality();

  @override
  bool equals(Object? e1, Object? e2) => switch ((e1, e2)) {
    (final Color c1, final Color c2) => c1.toJson() == c2.toJson(),
    _ => e1 == e2,
  };

  @override
  int hash(Object? e) => e is Color ? e.toJson().hashCode : e.hashCode;

  @override
  bool isValidKey(Object? o) => true;
}

const _deepEquality = DeepCollectionEquality(_ColorEquality());

/// Matches collections and [Color]s deeply.
///
/// This is required as [equals] compares [Color]s by identity, as they do not
/// implement [Object.==].
Matcher deepEquals(Object? expected) => predicate(
  ($actual) => _deepEquality.equals(expected, $actual),
  'deeply equals $expected',
);

/// [deepEquals] as positional mockito argument matcher.
T? deepArg<T>(Object? expected) => argThat(deepEquals(expected));

/// [deepEquals] as named mockito argument matcher for the parameter [name].
T? deepNamedArg<T>(String name, Object? expected) =>
    argThat(deepEquals(expected), named: name);
