import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart' as ast_type;
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';
import 'package:source_helper/source_helper.dart';

@internal
abstract base class Types {
  Types._();

  static Reference fromDartType(
    ast_type.DartType dartType, {
    bool? isNull,
  }) {
    if (dartType is ast_type.VoidType || dartType.isDartCoreNull) {
      return $void;
    } else if (dartType is ast_type.RecordType) {
      return _fromRecord(dartType);
    } else {
      return TypeReference(
        (b) {
          b
            ..symbol = dartType.element!.name
            ..isNullable =
                isNull ?? dartType.nullabilitySuffix != NullabilitySuffix.none;

          if (dartType is ast_type.InterfaceType) {
            b.types.addAll(dartType.typeArguments.map(fromDartType));
          }
        },
      );
    }
  }

  static TypeReference fromClass(ClassElement clazz) => _named(clazz.name);

  static TypeReference fromTypeParameter(TypeParameterElement typeParameter) =>
      TypeReference(
        (b) => b
          ..symbol = typeParameter.name
          ..bound = typeParameter.bound != null
              ? Types.fromDartType(typeParameter.bound!)
              : null,
      );

  static TypeReference list([Reference? type]) => TypeReference(
        (b) => b
          ..symbol = 'List'
          ..types.addAll([
            if (type != null) type,
          ]),
      );

  static TypeReference map([Reference? key, Reference? value]) => TypeReference(
        (b) => b
          ..symbol = 'Map'
          ..types.addAll([
            if (key != null) key,
            if (value != null) value,
          ]),
      );

  static TypeReference future([Reference? type]) => TypeReference(
        (b) => b
          ..symbol = 'Future'
          ..types.addAll([
            if (type != null) type,
          ]),
      );

  static TypeReference futureOr([Reference? type]) => TypeReference(
        (b) => b
          ..symbol = 'FutureOr'
          ..types.addAll([
            if (type != null) type,
          ]),
      );

  static TypeReference streamChannel([Reference? type]) => TypeReference(
        (b) => b
          ..symbol = 'StreamChannel'
          ..types.addAll([
            if (type != null) type,
          ]),
      );

  static TypeReference streamController([Reference? type]) => TypeReference(
        (b) => b
          ..symbol = 'StreamController'
          ..types.addAll([
            if (type != null) type,
          ]),
      );

  static TypeReference streamSubscription([Reference? type]) => TypeReference(
        (b) => b
          ..symbol = 'StreamSubscription'
          ..types.addAll([
            if (type != null) type,
          ]),
      );

  static final dynamic = _named('dynamic');

  static final $void = _named('void');

  static final $bool = _named('bool');

  static final $int = _named('int');

  static final object = _named('Object');

  static final string = _named('String');

  static final mapEntry = _named('MapEntry');

  static final argumentError = _named('ArgumentError');

  static final stackTrace = _named('StackTrace');

  static final zone = _named('Zone');

  static final jsonRpc2Client = TypeReference(
    (b) => b..symbol = 'Client',
  );

  static final jsonRpc2Server = TypeReference(
    (b) => b..symbol = 'Server',
  );

  static final jsonRpc2Parameters = TypeReference(
    (b) => b..symbol = 'Parameters',
  );

  static final jsonRpc2Parameter = TypeReference(
    (b) => b..symbol = 'Parameter',
  );

  static final jsonRpc2RpcException = TypeReference(
    (b) => b..symbol = 'RpcException',
  );

  static final jsonRpc2ErrorCallback = TypeReference(
    (b) => b..symbol = 'ErrorCallback',
  );

  static final clientBase = TypeReference(
    (b) => b..symbol = 'ClientBase',
  );

  static final serverBase = TypeReference(
    (b) => b..symbol = 'ServerBase',
  );

  static final peerBase = TypeReference(
    (b) => b..symbol = 'PeerBase',
  );

  static final streamCommand = TypeReference(
    (b) => b..symbol = 'StreamCommand',
  );

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
