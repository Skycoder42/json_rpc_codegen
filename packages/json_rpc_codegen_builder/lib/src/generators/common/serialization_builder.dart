import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';
import 'package:source_helper/source_helper.dart';

import 'types.dart';

/// @nodoc
@internal
enum JsonType {
  /// @nodoc
  jNull('value'),

  /// @nodoc
  jInt('asInt'),

  /// @nodoc
  jDouble('asDouble'),

  /// @nodoc
  jNum('asNum'),

  /// @nodoc
  jBool('asBool'),

  /// @nodoc
  jString('asString'),

  /// @nodoc
  jList('asList'),

  /// @nodoc
  jMap('asMap');

  /// @nodoc
  final String paramGet;

  /// @nodoc
  const JsonType(this.paramGet);

  /// @nodoc
  String get paramGetOr => '${paramGet}Or';
}

/// @nodoc
@internal
abstract base class SerializationBuilder {
  SerializationBuilder._();

  /// @nodoc
  static JsonType jsonTypeFor(DartType type) {
    if (type.isDartCoreNull) {
      return JsonType.jNull;
    } else if (type.isDartCoreInt) {
      return JsonType.jInt;
    } else if (type.isDartCoreDouble) {
      return JsonType.jDouble;
    } else if (type.isDartCoreNum) {
      return JsonType.jNum;
    } else if (type.isDartCoreBool) {
      return JsonType.jBool;
    } else if (type.isDartCoreString || type.isEnum) {
      return JsonType.jString;
    } else if (type.isDartCoreList || type.isDartCoreIterable) {
      return JsonType.jList;
    } else {
      return JsonType.jMap;
    }
  }

  /// @nodoc
  static Expression fromJson(
    DartType type,
    Expression value, {
    bool noCast = false,
  }) {
    if (type.isDartCoreIterable || type.isDartCoreList) {
      return _fromList(type, value, noCast: noCast);
    } else if (type.isDartCoreMap) {
      return _fromMap(type, value, noCast: noCast);
    } else if (type.isEnum) {
      return Types.fromDartType(type)
          .property('values')
          .property('byName')
          .call([_maybeCast(value, Types.string, noCast)]);
    } else if (_isPrimitiveType(type)) {
      return _maybeCast(value, Types.fromDartType(type), noCast);
    } else {
      return Types.fromDartType(type).newInstanceNamed('fromJson', [
        value.asA(Types.map(Types.string, Types.dynamic)),
      ]);
    }
  }

  /// @nodoc
  static Expression toJson(DartType type, Expression value) {
    if (type.isDartCoreIterable || type.isDartCoreList) {
      return _toList(type, value);
    } else if (type.isDartCoreMap) {
      return _toMap(type, value);
    } else if (type.isEnum) {
      return value.property('name');
    } else {
      return value;
    }
  }

  static Expression _fromList(
    DartType type,
    Expression value, {
    bool noCast = false,
  }) {
    final interfaceType = type as InterfaceType;
    final listType = interfaceType.typeArguments.single;
    const elementParamRef = Reference('e');

    final iterable = _maybeCast(
      value,
      Types.list(),
      noCast,
    ).property('map').call([
      Method(
        (b) => b
          ..requiredParameters.add(
            Parameter(
              (b) => b
                ..name = elementParamRef.symbol!
                ..type = Types.dynamic,
            ),
          )
          ..body = fromJson(listType, elementParamRef).code,
      ).closure,
    ]);

    return type.isDartCoreList
        ? iterable.property('toList').call(const [])
        : iterable;
  }

  static Expression _toList(DartType type, Expression value) {
    final interfaceType = type as InterfaceType;
    final listType = interfaceType.typeArguments.single;

    const elementParamRef = Reference('e');
    final convertExpression = toJson(listType, elementParamRef);
    if (identical(convertExpression, elementParamRef)) {
      return value;
    }

    return value
        .property('map')
        .call([
          Method(
            (b) => b
              ..requiredParameters.add(
                Parameter((b) => b..name = elementParamRef.symbol!),
              )
              ..body = convertExpression.code,
          ).closure,
        ])
        .property('toList')
        .call(const [], const {'growable': literalFalse});
  }

  static Expression _fromMap(
    DartType type,
    Expression value, {
    bool noCast = false,
  }) {
    final interfaceType = type as InterfaceType;
    final keyType = interfaceType.typeArguments[0];
    final valueType = interfaceType.typeArguments[1];

    const keyParamRef = Reference('k');
    const valueParamRef = Reference('v');

    return _maybeCast(value, Types.map(), noCast).property('map').call([
      Method(
        (b) => b
          ..requiredParameters.addAll([
            Parameter(
              (b) => b
                ..name = keyParamRef.symbol!
                ..type = Types.dynamic,
            ),
            Parameter(
              (b) => b
                ..name = valueParamRef.symbol!
                ..type = Types.dynamic,
            ),
          ])
          ..body = Types.mapEntry.newInstance([
            fromJson(keyType, keyParamRef),
            fromJson(valueType, valueParamRef),
          ]).code,
      ).closure,
    ]);
  }

  static Expression _toMap(DartType type, Expression value) {
    final interfaceType = type as InterfaceType;
    final keyType = interfaceType.typeArguments[0];
    final valueType = interfaceType.typeArguments[1];

    const keyParamRef = Reference('k');
    const valueParamRef = Reference('v');

    final convertKeyExpression = toJson(keyType, keyParamRef);
    final convertValueExpression = toJson(valueType, valueParamRef);
    if (identical(convertKeyExpression, keyParamRef) &&
        identical(convertValueExpression, valueParamRef)) {
      return value;
    }

    return value.property('map').call([
      Method(
        (b) => b
          ..requiredParameters.addAll([
            Parameter((b) => b..name = keyParamRef.symbol!),
            Parameter((b) => b..name = valueParamRef.symbol!),
          ])
          ..body = Types.mapEntry.newInstance([
            convertKeyExpression,
            convertValueExpression,
          ]).code,
      ).closure,
    ]);
  }

  static bool _isPrimitiveType(DartType type) =>
      type.isDartCoreNull ||
      type.isDartCoreBool ||
      type.isDartCoreNum ||
      type.isDartCoreInt ||
      type.isDartCoreDouble ||
      type.isDartCoreString;

  static Expression _maybeCast(
    Expression ref,
    TypeReference type,
    bool noCast,
  ) =>
      noCast ? ref : ref.asA(type);
}
