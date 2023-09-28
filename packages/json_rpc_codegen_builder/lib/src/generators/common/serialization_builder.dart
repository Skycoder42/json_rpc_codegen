import 'package:analyzer/dart/element/type.dart' hide FunctionType;
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';
import 'package:source_helper/source_helper.dart';

import 'code_builder_extensions.dart';
import 'types.dart';

/// @nodoc
@internal
abstract base class SerializationBuilder {
  static const _maybeMapName = r'_$maybeMap';
  static const _maybeMapRef = Reference(_maybeMapName);

  SerializationBuilder._();

  /// @nodoc
  static Iterable<Spec> buildGlobalMethods() sync* {
    yield Method(
      (b) => b
        ..name = _maybeMapName
        ..returns = TypeReference(
          (b) => b
            ..symbol = 'TConverted'
            ..isNullable = true,
        )
        ..types.add(
          TypeReference(
            (b) => b
              ..symbol = 'TConverted'
              ..bound = refer('Object'),
          ),
        )
        ..types.add(
          TypeReference(
            (b) => b
              ..symbol = 'TJson'
              ..bound = refer('Object'),
          ),
        )
        ..requiredParameters.add(
          Parameter(
            (b) => b
              ..name = r'$value'
              ..type = TypeReference(
                (b) => b
                  ..symbol = 'TJson'
                  ..isNullable = true,
              ),
          ),
        )
        ..requiredParameters.add(
          Parameter(
            (b) => b
              ..name = r'$convert'
              ..type = FunctionType(
                (b) => b
                  ..returnType = refer('TConverted')
                  ..requiredParameters.add(refer('TJson')),
              ),
          ),
        )
        ..body = refer(r'$value')
            .equalTo(literalNull)
            .conditional(
              literalNull,
              refer(r'$convert').call([refer(r'$value')]),
            )
            .code,
    );
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
      // TODO add everywhere
      return _ifNotNull(
        type,
        value,
        (ref) => Types.fromDartType(type, isNull: false)
            .property('values')
            .property('byName')
            .call([_maybeCast(ref, Types.string, noCast)]),
      );
    } else if (_isPrimitiveType(type)) {
      return _maybeCast(value, Types.fromDartType(type), noCast);
    } else {
      return Types.fromDartType(type).newInstanceNamed('fromJson', [
        value, // TODO.asA(Types.map(Types.string, Types.dynamic)),
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
      return value.autoProperty('name', type.isNullableType);
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
    const elementParamRef = Reference(r'$e');

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

    const elementParamRef = Reference(r'$e');
    final convertExpression = toJson(listType, elementParamRef);
    if (identical(convertExpression, elementParamRef)) {
      return value;
    }

    return value
        .autoProperty('map', type.isNullableType)
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

    const keyParamRef = Reference(r'$k');
    const valueParamRef = Reference(r'$v');

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

    const keyParamRef = Reference(r'$k');
    const valueParamRef = Reference(r'$v');

    final convertKeyExpression = toJson(keyType, keyParamRef);
    final convertValueExpression = toJson(valueType, valueParamRef);
    if (identical(convertKeyExpression, keyParamRef) &&
        identical(convertValueExpression, valueParamRef)) {
      return value;
    }

    return value.autoProperty('map', type.isNullableType).call([
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

  static Expression _ifNotNull(
    DartType type,
    Expression value,
    Expression Function(Expression ref) buildExpression,
  ) {
    if (!type.isNullableType) {
      return buildExpression(value);
    }

    const callbackParamRef = Reference(r'$v');
    return _maybeMapRef.call([
      value,
      // TODO extract code
      Method(
        (b) => b
          ..requiredParameters.add(
            Parameter(
              (b) => b..name = callbackParamRef.symbol!,
            ),
          )
          ..body = buildExpression(callbackParamRef).code,
      ).closure,
    ]);
  }
}
