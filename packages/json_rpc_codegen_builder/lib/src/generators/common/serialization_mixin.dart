import 'package:analyzer/dart/element/type.dart' hide FunctionType;
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';
import 'package:source_helper/source_helper.dart';

import '../proxy_spec.dart';
import 'closure_builder_mixin.dart';
import 'code_builder_extensions.dart';
import 'types.dart';

/// @nodoc
@internal
base mixin SerializationMixin on ProxySpec, ClosureBuilderMixin {
  static const _maybeMapName = r'_$maybeMap';
  static const _maybeMapRef = Reference(_maybeMapName);

  /// @nodoc
  static Iterable<Spec> buildGlobalMethods() sync* {
    yield _buildMaybeMap();
  }

  /// @nodoc
  @protected
  Expression fromJson(
    DartType type,
    Expression value, {
    bool noCast = false,
  }) {
    if (type.isDartCoreIterable || type.isDartCoreList) {
      return _fromList(type, value, noCast: noCast);
    } else if (type.isDartCoreMap) {
      return _fromMap(type, value, noCast: noCast);
    } else if (type.isEnum) {
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
      return _ifNotNull(
        type,
        value,
        (ref) => Types.fromDartType(type, isNull: false)
            .newInstanceNamed('fromJson', [ref]),
      );
    }
  }

  /// @nodoc
  @protected
  Expression toJson(DartType type, Expression value) {
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

  Expression _fromList(
    DartType type,
    Expression value, {
    bool noCast = false,
  }) {
    final interfaceType = type as InterfaceType;
    final listType = interfaceType.typeArguments.single;

    final iterable = _maybeCast(
      value,
      Types.list().asNullable(type.isNullableType),
      noCast,
    ).autoProperty('map', type.isNullableType).call([
      closure1(
        r'$e',
        type1: Types.dynamic,
        (p1) => fromJson(listType, p1).code,
      ),
    ]);

    return type.isDartCoreList
        ? iterable.property('toList').call(const [])
        : iterable;
  }

  Expression _toList(DartType type, Expression value) {
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
          closure1(elementParamRef.symbol!, (p1) => convertExpression.code),
        ])
        .property('toList')
        .call(const [], const {'growable': literalFalse});
  }

  Expression _fromMap(
    DartType type,
    Expression value, {
    bool noCast = false,
  }) {
    final interfaceType = type as InterfaceType;
    final keyType = interfaceType.typeArguments[0];
    final valueType = interfaceType.typeArguments[1];

    return _maybeCast(
      value,
      Types.map().asNullable(type.isNullableType),
      noCast,
    ).autoProperty('map', type.isNullableType).call([
      closure2(
        r'$k',
        r'$v',
        type1: Types.dynamic,
        type2: Types.dynamic,
        (p1, p2) => Types.mapEntry.newInstance([
          fromJson(keyType, p1),
          fromJson(valueType, p2),
        ]).code,
      ),
    ]);
  }

  Expression _toMap(DartType type, Expression value) {
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
      closure2(
        keyParamRef.symbol!,
        valueParamRef.symbol!,
        (p1, p2) => Types.mapEntry.newInstance([
          convertKeyExpression,
          convertValueExpression,
        ]).code,
      ),
    ]);
  }

  bool _isPrimitiveType(DartType type) =>
      type.isDartCoreNull ||
      type.isDartCoreBool ||
      type.isDartCoreNum ||
      type.isDartCoreInt ||
      type.isDartCoreDouble ||
      type.isDartCoreString;

  Expression _maybeCast(
    Expression ref,
    TypeReference type,
    bool noCast,
  ) =>
      noCast ? ref : ref.asA(type);

  Expression _ifNotNull(
    DartType type,
    Expression value,
    Expression Function(Expression ref) buildExpression,
  ) {
    if (!type.isNullableType) {
      return buildExpression(value);
    }

    return _maybeMapRef.call([
      value,
      closure1(r'$v', (p1) => buildExpression(p1).code),
    ]);
  }

  static Method _buildMaybeMap() {
    final tConverted = TypeReference((b) => b..symbol = 'TConverted');
    final tJson = TypeReference((b) => b..symbol = 'TJson');
    const valueParamRef = Reference(r'$value');
    const convertParamRef = Reference(r'$convert');
    return Method(
      (b) => b
        ..name = _maybeMapName
        ..returns = tConverted.asNullable(true)
        ..types.add(tConverted.boundTo(Types.object))
        ..types.add(tJson.boundTo(Types.object))
        ..requiredParameters.add(
          Parameter(
            (b) => b
              ..name = valueParamRef.symbol!
              ..type = tJson.asNullable(true),
          ),
        )
        ..requiredParameters.add(
          Parameter(
            (b) => b
              ..name = convertParamRef.symbol!
              ..type = FunctionType(
                (b) => b
                  ..returnType = tConverted
                  ..requiredParameters.add(tJson),
              ),
          ),
        )
        ..body = valueParamRef
            .equalTo(literalNull)
            .conditional(
              literalNull,
              convertParamRef.call([valueParamRef]),
            )
            .code,
    );
  }
}
