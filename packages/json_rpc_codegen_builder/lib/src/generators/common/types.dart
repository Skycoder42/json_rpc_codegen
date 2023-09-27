import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';

abstract base class Types {
  Types._();

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

  static TypeReference fromTypeParameter(TypeParameterElement typeParameter) =>
      TypeReference(
        (b) => b
          ..symbol = typeParameter.name
          ..bound = typeParameter.bound != null
              ? Types.fromDartType(typeParameter.bound!)
              : null,
      );

  static TypeReference list([TypeReference? type]) => TypeReference(
        (b) => b
          ..symbol = 'List'
          ..types.addAll([
            if (type != null) type,
          ]),
      );

  static TypeReference map([TypeReference? key, TypeReference? value]) =>
      TypeReference(
        (b) => b
          ..symbol = 'Map'
          ..types.addAll([
            if (key != null) key,
            if (value != null) value,
          ]),
      );

  static final dynamic = _named('dynamic');
  static final $void = _named('void');
  static final string = _named('String');
  static final function0 = _named('dynamic Function()');
  static final mapEntry = _named('MapEntry');

  static final jsonRpc2Client = TypeReference(
    (b) => b
      ..symbol = 'Client'
      ..url = 'package:json_rpc_2/json_rpc_2.dart',
  );

  static TypeReference _named(String name) => TypeReference(
        (b) => b..symbol = name,
      );
}
