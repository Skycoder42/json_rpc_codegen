import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

/// @nodoc
@internal
abstract base class Types {
  Types._();

  /// @nodoc
  static TypeReference fromDartType(DartType dartType) => TypeReference(
        (b) {
          b
            ..symbol = dartType.element!.name
            ..isNullable = dartType.nullabilitySuffix != NullabilitySuffix.none
            ..url = dartType.element?.library?.location?.components.firstOrNull;

          if (dartType is InterfaceType) {
            b.types.addAll(dartType.typeArguments.map(fromDartType));
          }
        },
      );

  /// @nodoc
  static TypeReference fromTypeParameter(TypeParameterElement typeParameter) =>
      TypeReference(
        (b) => b
          ..symbol = typeParameter.name
          ..bound = typeParameter.bound != null
              ? Types.fromDartType(typeParameter.bound!)
              : null,
      );

  /// @nodoc
  static TypeReference list([TypeReference? type]) => TypeReference(
        (b) => b
          ..symbol = 'List'
          ..types.addAll([
            if (type != null) type,
          ]),
      );

  /// @nodoc
  static TypeReference map([TypeReference? key, TypeReference? value]) =>
      TypeReference(
        (b) => b
          ..symbol = 'Map'
          ..types.addAll([
            if (key != null) key,
            if (value != null) value,
          ]),
      );

  /// @nodoc
  static final dynamic = _named('dynamic');

  /// @nodoc
  static final $void = _named('void');

  /// @nodoc
  static final string = _named('String');

  /// @nodoc
  static final function0 = _named('dynamic Function()');

  /// @nodoc
  static final mapEntry = _named('MapEntry');

  /// @nodoc
  static final jsonRpc2Client = TypeReference(
    (b) => b
      ..symbol = 'Client'
      ..url = 'package:json_rpc_2/json_rpc_2.dart',
  );

  static TypeReference _named(String name) => TypeReference(
        (b) => b..symbol = name,
      );
}
