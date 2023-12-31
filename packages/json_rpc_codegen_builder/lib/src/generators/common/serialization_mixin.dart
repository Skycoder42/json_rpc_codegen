import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart' hide FunctionType;
import 'package:code_builder/code_builder.dart' hide RecordType;
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

import '../../extensions/code_builder_extensions.dart';
import '../proxy_spec.dart';
import 'annotations.dart';
import 'closure_builder_mixin.dart';
import 'types.dart';

/// @nodoc
@internal
base mixin SerializationMixin on ProxySpec, ClosureBuilderMixin {
  static const _mapRef = Reference(r'_$map');
  static const _maybeMapRef = Reference(r'_$maybeMap');

  /// @nodoc
  static Iterable<Spec> buildGlobals() sync* {
    yield _buildMap();
    yield _buildMaybeMap();
  }

  /// @nodoc
  @protected
  Expression fromJson(
    DartType type,
    Expression value, {
    bool noCast = false,
    bool? isNull,
  }) {
    if (type.isDartCoreIterable || type.isDartCoreList || type.isDartCoreSet) {
      return _fromList(type, value, noCast: noCast, isNull: isNull);
    } else if (type.isDartCoreMap) {
      return _fromMap(type, value, noCast: noCast, isNull: isNull);
    } else if (type is RecordType) {
      return _fromRecord(type, value, noCast: noCast, isNull: isNull);
    } else if (type.isEnum) {
      return _ifNotNull(
        type,
        isNull ?? type.isNullableType,
        value,
        (ref) => Types.fromDartType(type, isNull: false)
            .property('values')
            .property('byName')
            .call([_maybeCast(ref, Types.string, noCast)]),
      );
    } else if (type
        case InterfaceType(
          element: ClassElement(
            name: 'Uri' || 'DateTime',
          )
        )) {
      return _ifNotNull(
        type,
        isNull ?? type.isNullableType,
        value,
        (ref) => Types.fromDartType(type, isNull: false)
            .property('parse')
            .call([_maybeCast(value, Types.string, noCast)]),
      );
    } else if (_isPrimitiveType(type)) {
      return _maybeCast(value, Types.fromDartType(type), noCast);
    } else if (type is DynamicType) {
      return value;
    } else {
      final jsonType = _fromJsonType(type);
      if (jsonType == null) {
        throw InvalidGenerationSourceError(
          'Unable to build deserialization code for $type. Is not a standard '
          'dart type and no valid .fromJson constructor could be found.',
          element: type.element,
          todo:
              'Add a fromJson constructor that a single, positional parameter.',
        );
      }

      return _ifNotNull(
        type,
        isNull ?? type.isNullableType,
        value,
        (ref) => Types.fromDartType(type, isNull: false).newInstanceNamed(
          'fromJson',
          [ref.asA(Types.fromDartType(jsonType))],
        ),
      );
    }
  }

  /// @nodoc
  @protected
  Expression toJson(DartType type, Expression value, {bool? isNull}) {
    if (type.isDartCoreIterable || type.isDartCoreList || type.isDartCoreSet) {
      return _toList(type, value, isNull: isNull);
    } else if (type.isDartCoreMap) {
      return _toMap(type, value, isNull: isNull);
    } else if (type is RecordType) {
      return _toRecord(type, value, isNull: isNull);
    } else if (type.isEnum) {
      return value.autoProperty('name', isNull ?? type.isNullableType);
    } else if (type case InterfaceType(element: ClassElement(name: 'Uri'))) {
      return value
          .autoProperty('toString', isNull ?? type.isNullableType)
          .call(const []);
    } else if (type
        case InterfaceType(
          element: ClassElement(
            name: 'DateTime',
          )
        )) {
      return value
          .autoProperty('toIso8601String', isNull ?? type.isNullableType)
          .call(const []);
    } else {
      return value;
    }
  }

  Expression _fromList(
    DartType type,
    Expression value, {
    bool noCast = false,
    bool? isNull,
  }) {
    final interfaceType = type as InterfaceType;
    final listType = interfaceType.typeArguments.single;

    var iterable = _maybeCast(
      value,
      Types.list().asNullable(isNull ?? type.isNullableType),
      noCast,
    );

    if (listType is! DynamicType) {
      iterable =
          iterable.autoProperty('map', isNull ?? type.isNullableType).call([
        closure1(
          r'$e',
          type1: Types.dynamic,
          (p1) => fromJson(listType, p1).code,
        ),
      ]);
    }

    if (type.isDartCoreList) {
      iterable = iterable.property('toList').call(const []);
    } else if (type.isDartCoreSet) {
      iterable = iterable.property('toSet').call(const []);
    }

    return iterable;
  }

  Expression _toList(DartType type, Expression value, {bool? isNull}) {
    final interfaceType = type as InterfaceType;
    final listType = interfaceType.typeArguments.single;

    const elementParamRef = Reference(r'$e');
    final convertExpression = toJson(listType, elementParamRef);
    if (identical(convertExpression, elementParamRef)) {
      return !type.isDartCoreList
          ? value
              .autoProperty('toList', isNull ?? type.isNullableType)
              .call(const [], const {'growable': literalFalse})
          : value;
    }

    return value
        .autoProperty('map', isNull ?? type.isNullableType)
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
    bool? isNull,
  }) {
    final interfaceType = type as InterfaceType;
    final keyType = interfaceType.typeArguments[0];
    final valueType = interfaceType.typeArguments[1];

    var map = _maybeCast(
      value,
      Types.map().asNullable(isNull ?? type.isNullableType),
      noCast,
    );

    if (keyType is! DynamicType || valueType is! DynamicType) {
      map = map.autoProperty('map', isNull ?? type.isNullableType).call([
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

    return map;
  }

  Expression _toMap(DartType type, Expression value, {bool? isNull}) {
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

    return value.autoProperty('map', isNull ?? type.isNullableType).call([
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

  Expression _fromRecord(
    DartType type,
    Expression value, {
    bool noCast = false,
    bool? isNull,
  }) {
    final recordType = type as RecordType;
    if (recordType.namedFields.isNotEmpty &&
        recordType.positionalFields.isNotEmpty) {
      throwInvalidRecord(recordType);
    } else if (recordType.namedFields.isNotEmpty) {
      return _ifNotNull(
        type,
        isNull ?? type.isNullableType,
        mapNonNull: true,
        _maybeCast(
          value,
          Types.map().asNullable(isNull ?? type.isNullableType),
          noCast,
        ),
        (ref) => literalRecord(const [], {
          for (final field in recordType.namedFields)
            field.name: fromJson(
              field.type,
              ref.index(literalString(field.name)),
            ),
        }),
      );
    } else {
      // empty records are treated as positional
      return _ifNotNull(
        type,
        isNull ?? type.isNullableType,
        mapNonNull: true,
        _maybeCast(
          value,
          Types.list().asNullable(isNull ?? type.isNullableType),
          noCast,
        ),
        (ref) => literalRecord(
          [
            for (final (index, field) in recordType.positionalFields.indexed)
              fromJson(
                field.type,
                ref.index(literalNum(index)),
              ),
          ],
          const {},
        ),
      );
    }
  }

  Expression _toRecord(DartType type, Expression value, {bool? isNull}) {
    final recordType = type as RecordType;
    if (recordType.namedFields.isNotEmpty &&
        recordType.positionalFields.isNotEmpty) {
      throwInvalidRecord(recordType);
    } else if (recordType.namedFields.isNotEmpty) {
      return _ifNotNull(
        type,
        isNull ?? type.isNullableType,
        value,
        (ref) => literalMap(
          {
            for (final field in recordType.namedFields)
              literalString(field.name): toJson(
                field.type,
                ref.property(field.name),
              ),
          },
          Types.string,
          Types.dynamic,
        ),
      );
    } else {
      // empty records are treated as positional
      return _ifNotNull(
        type,
        isNull ?? type.isNullableType,
        value,
        (ref) => literalList(
          {
            for (final (index, field) in recordType.positionalFields.indexed)
              toJson(
                field.type,
                ref.property('\$${index + 1}'),
              ),
          },
          Types.dynamic,
        ),
      );
    }
  }

  bool _isPrimitiveType(DartType type) =>
      type.isDartCoreNull ||
      type.isDartCoreBool ||
      type.isDartCoreNum ||
      type.isDartCoreInt ||
      type.isDartCoreDouble ||
      type.isDartCoreString;

  DartType? _fromJsonType(DartType type) {
    final element = type.element;
    if (element case ClassElement()) {
      final fromJsonConstructor =
          element.constructors.firstWhere((c) => c.name == 'fromJson');
      final jsonArg = fromJsonConstructor.parameters.firstOrNull;
      return jsonArg?.type;
    } else {
      return null;
    }
  }

  Expression _maybeCast(
    Expression ref,
    Reference type,
    bool noCast,
  ) =>
      noCast ? ref : ref.asA(type);

  Expression _ifNotNull(
    DartType type,
    bool isNull,
    Expression value,
    Expression Function(Expression ref) buildExpression, {
    bool mapNonNull = false,
  }) {
    if (!isNull) {
      if (mapNonNull) {
        return _mapRef.call([
          value,
          closure1(r'$v', (p1) => buildExpression(p1).code),
        ]);
      } else {
        return buildExpression(value);
      }
    }

    return _maybeMapRef.call([
      value,
      closure1(r'$v', (p1) => buildExpression(p1).code),
    ]);
  }

  static Method _buildMap() {
    final tConverted = TypeReference((b) => b..symbol = 'TConverted');
    final tJson = TypeReference((b) => b..symbol = 'TJson');
    const valueParamRef = Reference(r'$value');
    const convertParamRef = Reference(r'$convert');
    return Method(
      (b) => b
        ..name = _mapRef.symbol
        ..annotations.add(Annotations.pragmaPreferInline)
        ..returns = tConverted
        ..types.add(tConverted.boundTo(Types.object))
        ..types.add(tJson.boundTo(Types.object))
        ..requiredParameters.add(
          Parameter(
            (b) => b
              ..name = valueParamRef.symbol!
              ..type = tJson,
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
        ..body = convertParamRef.call([valueParamRef]).code,
    );
  }

  static Method _buildMaybeMap() {
    final tConverted = TypeReference((b) => b..symbol = 'TConverted');
    final tJson = TypeReference((b) => b..symbol = 'TJson');
    const valueParamRef = Reference(r'$value');
    const convertParamRef = Reference(r'$convert');
    return Method(
      (b) => b
        ..name = _maybeMapRef.symbol
        ..annotations.add(Annotations.pragmaPreferInline)
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

  /// @nodoc
  static Never throwInvalidRecord(RecordType recordType) {
    throw InvalidGenerationSourceError(
      'Records cannot be a mixture of positional and named.',
      element: recordType.element,
      todo: 'Make all record parameters either positional or named.',
    );
  }
}
