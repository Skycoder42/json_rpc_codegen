import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart' as ast_type;
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';
import 'package:source_helper/source_helper.dart';

/// @nodoc
@internal
abstract base class Types {
  Types._();

  /// @nodoc
  static Reference fromDartType(
    ast_type.DartType dartType, {
    bool? isNull,
  }) {
    if (dartType is ast_type.VoidType || dartType.isDartCoreNull) {
      return $void;
    } else if (dartType is ast_type.RecordType) {
      return _fromRecord(dartType);
    } else {
      return dartType is ast_type.VoidType || dartType.isDartCoreNull
          ? $void
          : TypeReference(
              (b) {
                b
                  ..symbol = dartType.element!.name
                  ..isNullable = isNull ??
                      dartType.nullabilitySuffix != NullabilitySuffix.none;

                if (dartType is ast_type.InterfaceType) {
                  b.types.addAll(dartType.typeArguments.map(fromDartType));
                }
              },
            );
    }
  }

  /// @nodoc
  static TypeReference fromClass(ClassElement clazz) => _named(clazz.name);

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
  static TypeReference list([Reference? type]) => TypeReference(
        (b) => b
          ..symbol = 'List'
          ..types.addAll([
            if (type != null) type,
          ]),
      );

  /// @nodoc
  static TypeReference map([Reference? key, Reference? value]) => TypeReference(
        (b) => b
          ..symbol = 'Map'
          ..types.addAll([
            if (key != null) key,
            if (value != null) value,
          ]),
      );

  /// @nodoc
  static TypeReference future([Reference? type]) => TypeReference(
        (b) => b
          ..symbol = 'Future'
          ..types.addAll([
            if (type != null) type,
          ]),
      );

  /// @nodoc
  static TypeReference futureOr([Reference? type]) => TypeReference(
        (b) => b
          ..symbol = 'FutureOr'
          ..types.addAll([
            if (type != null) type,
          ]),
      );

  /// @nodoc
  static TypeReference streamChannel([Reference? type]) => TypeReference(
        (b) => b
          ..symbol = 'StreamChannel'
          ..types.addAll([
            if (type != null) type,
          ]),
      );

  /// @nodoc
  static TypeReference streamController([Reference? type]) => TypeReference(
        (b) => b
          ..symbol = 'StreamController'
          ..types.addAll([
            if (type != null) type,
          ]),
      );

  /// @nodoc
  static final dynamic = _named('dynamic');

  /// @nodoc
  static final $void = _named('void');

  /// @nodoc
  static final $bool = _named('bool');

  /// @nodoc
  static final $int = _named('int');

  /// @nodoc
  static final object = _named('Object');

  /// @nodoc
  static final string = _named('String');

  /// @nodoc
  static final mapEntry = _named('MapEntry');

  /// @nodoc
  static final argumentError = _named('ArgumentError');

  /// @nodoc
  static final jsonRpc2Client = TypeReference(
    (b) => b..symbol = 'Client',
  );

  /// @nodoc
  static final jsonRpc2Server = TypeReference(
    (b) => b..symbol = 'Server',
  );

  /// @nodoc
  static final jsonRpc2Parameters = TypeReference(
    (b) => b..symbol = 'Parameters',
  );

  /// @nodoc
  static final jsonRpc2Parameter = TypeReference(
    (b) => b..symbol = 'Parameter',
  );

  /// @nodoc
  static final jsonRpc2RpcException = TypeReference(
    (b) => b..symbol = 'RpcException',
  );

  /// @nodoc
  static final jsonRpc2ErrorCallback = TypeReference(
    (b) => b..symbol = 'ErrorCallback',
  );

  /// @nodoc
  static final clientBase = TypeReference(
    (b) => b..symbol = 'ClientBase',
  );

  /// @nodoc
  static final serverBase = TypeReference(
    (b) => b..symbol = 'ServerBase',
  );

  /// @nodoc
  static final peerBase = TypeReference(
    (b) => b..symbol = 'PeerBase',
  );

  /// @nodoc
  static final streamCommand = TypeReference(
    (b) => b..symbol = 'StreamCommand',
  );

  /// @nodoc
  static final streamEvent = TypeReference(
    (b) => b..symbol = 'StreamEvent',
  );

  static TypeReference _named(String name) => TypeReference(
        (b) => b..symbol = name,
      );

  static RecordType _fromRecord(ast_type.RecordType record) => RecordType(
        (b) => b
          ..isNullable = record.isNullableType
          ..positionalFieldTypes.addAll([
            for (final field in record.positionalFields)
              fromDartType(field.type),
          ])
          ..namedFieldTypes.addAll({
            for (final field in record.namedFields)
              field.name: fromDartType(field.type),
          }),
      );
}
