import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart' hide FunctionType;
import 'package:code_builder/code_builder.dart' hide RecordType;
import 'package:dart_test_tools/code_gen.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

import '../../extensions/code_builder_extensions.dart';
import 'annotations.dart';
import 'closure_builder_mixin.dart';

@internal
base mixin SerializationMixin on ClosureBuilderMixin {
  static const _mapRef = Reference(r'_$map');
  static const _maybeMapRef = Reference(r'_$maybeMap');

  static Iterable<Spec> buildGlobals() sync* {
    yield _buildMap();
    yield _buildMaybeMap();
  }

  @protected
  Expression fromJson(
    DartType type,
    Expression value, {
    bool noCast = false,
    bool? isNull,
  }) {
    switch (type) {
      case InterfaceType(isDartCoreIterable: true) ||
          InterfaceType(isDartCoreList: true) ||
          InterfaceType(isDartCoreSet: true):
        return _fromList(type, value, noCast: noCast, isNull: isNull);
      case InterfaceType(isDartCoreMap: true):
        return _fromMap(type, value, noCast: noCast, isNull: isNull);
      case RecordType():
        return _fromRecord(type, value, noCast: noCast, isNull: isNull);
      case DartType(isEnum: true):
        return _ifNotNull(
          type,
          isNull ?? type.isNullableType,
          value,
          (ref) => type
              .toReference(nullable: false)
              .property('values')
              .property('byName')
              .call([_maybeCast(ref, CoreTypes.$String, noCast)]),
        );
      case InterfaceType(element: ClassElement(name: 'Uri' || 'DateTime')):
        return _ifNotNull(
          type,
          isNull ?? type.isNullableType,
          value,
          (ref) => type.toReference(nullable: false).property('parse').call([
            _maybeCast(ref, CoreTypes.$String, noCast),
          ]),
        );
      case _ when _isPrimitiveType(type):
        return _maybeCast(value, type.toReference(), noCast);
      case DynamicType():
        return value;
      case _:
        final jsonType = fromJsonType(type);
        return _ifNotNull(
          type,
          isNull ?? type.isNullableType,
          value,
          (ref) => type.toReference(nullable: false).newInstanceNamed(
            'fromJson',
            [_maybeCast(ref, jsonType.toReference(), noCast)],
          ),
        );
    }
  }

  @protected
  Expression toJson(DartType type, Expression value, {bool? isNull}) {
    switch (type) {
      case InterfaceType(isDartCoreIterable: true) ||
          InterfaceType(isDartCoreList: true) ||
          InterfaceType(isDartCoreSet: true):
        return _toList(type, value, isNull: isNull);
      case InterfaceType(isDartCoreMap: true):
        return _toMap(type, value, isNull: isNull);
      case RecordType():
        return _toRecord(type, value, isNull: isNull);
      case DartType(isEnum: true):
        return value.autoProperty('name', isNull ?? type.isNullableType);
      case InterfaceType(element: ClassElement(name: 'Uri')):
        return value
            .autoProperty('toString', isNull ?? type.isNullableType)
            .call(const []);
      case InterfaceType(element: ClassElement(name: 'DateTime')):
        return value
            .autoProperty('toIso8601String', isNull ?? type.isNullableType)
            .call(const []);
      case _:
        return value;
    }
  }

  Expression _fromList(
    InterfaceType type,
    Expression value, {
    bool noCast = false,
    bool? isNull,
  }) {
    final listType = type.typeArguments.single;

    var iterable = _maybeCast(
      value,
      CoreTypes.$List().asNullable(isNull ?? type.isNullableType),
      noCast,
    );

    if (listType is! DynamicType) {
      iterable = iterable
          .autoProperty('map', isNull ?? type.isNullableType)
          .call([
            closure1(
              r'$e',
              type1: CoreTypes.$dynamic,
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

  Expression _toList(InterfaceType type, Expression value, {bool? isNull}) {
    final listType = type.typeArguments.single;

    const elementParamRef = Reference(r'$e');
    final convertExpression = toJson(listType, elementParamRef);
    if (identical(convertExpression, elementParamRef)) {
      return !type.isDartCoreList
          ? value.autoProperty('toList', isNull ?? type.isNullableType).call(
              const [],
              const {'growable': literalFalse},
            )
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
    InterfaceType type,
    Expression value, {
    bool noCast = false,
    bool? isNull,
  }) {
    _validateMapKey(type);

    final keyType = type.typeArguments[0];
    final valueType = type.typeArguments[1];

    var map = _maybeCast(
      value,
      CoreTypes.$Map().asNullable(isNull ?? type.isNullableType),
      noCast,
    );

    if (keyType is! DynamicType || valueType is! DynamicType) {
      map = map.autoProperty('map', isNull ?? type.isNullableType).call([
        closure2(
          r'$k',
          r'$v',
          type1: CoreTypes.$dynamic,
          type2: CoreTypes.$dynamic,
          (p1, p2) => CoreTypes.$MapEntry().newInstance([
            // keys are never converted, only cast - see _validateMapKey
            _maybeCast(p1, keyType.toReference(), keyType is DynamicType),
            fromJson(valueType, p2),
          ]).code,
        ),
      ]);
    }

    return map;
  }

  Expression _toMap(InterfaceType type, Expression value, {bool? isNull}) {
    _validateMapKey(type);

    final valueType = type.typeArguments[1];

    const keyParamRef = Reference(r'$k');
    const valueParamRef = Reference(r'$v');

    // keys are always strings and thus never need to be converted
    final convertValueExpression = toJson(valueType, valueParamRef);
    if (identical(convertValueExpression, valueParamRef)) {
      return value;
    }

    return value.autoProperty('map', isNull ?? type.isNullableType).call([
      closure2(
        keyParamRef.symbol!,
        valueParamRef.symbol!,
        (p1, p2) => CoreTypes.$MapEntry().newInstance([
          p1,
          convertValueExpression,
        ]).code,
      ),
    ]);
  }

  Expression _fromRecord(
    RecordType type,
    Expression value, {
    bool noCast = false,
    bool? isNull,
  }) {
    if (type.namedFields.isNotEmpty && type.positionalFields.isNotEmpty) {
      throwInvalidRecord(type);
    } else if (type.namedFields.isNotEmpty) {
      return _ifNotNull(
        type,
        isNull ?? type.isNullableType,
        mapNonNull: true,
        _maybeCast(
          value,
          CoreTypes.$Map().asNullable(isNull ?? type.isNullableType),
          noCast,
        ),
        (ref) => literalRecord(const [], {
          for (final field in type.namedFields)
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
          CoreTypes.$List().asNullable(isNull ?? type.isNullableType),
          noCast,
        ),
        (ref) => literalRecord([
          for (final (index, field) in type.positionalFields.indexed)
            fromJson(field.type, ref.index(literalNum(index))),
        ], const {}),
      );
    }
  }

  Expression _toRecord(RecordType type, Expression value, {bool? isNull}) {
    if (type.namedFields.isNotEmpty && type.positionalFields.isNotEmpty) {
      throwInvalidRecord(type);
    } else if (type.namedFields.isNotEmpty) {
      return _ifNotNull(
        type,
        isNull ?? type.isNullableType,
        value,
        (ref) => literalMap(
          {
            for (final field in type.namedFields)
              literalString(field.name): toJson(
                field.type,
                ref.property(field.name),
              ),
          },
          CoreTypes.$String,
          CoreTypes.$dynamic,
        ),
      );
    } else {
      // empty records are treated as positional
      return _ifNotNull(
        type,
        isNull ?? type.isNullableType,
        value,
        (ref) => literalList({
          for (final (index, field) in type.positionalFields.indexed)
            toJson(field.type, ref.property('\$${index + 1}')),
        }, CoreTypes.$dynamic),
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

  DartType fromJsonType(DartType type) {
    final element = type.element;
    DartType? jsonType;
    if (element case ClassElement()) {
      final fromJsonConstructor = element.constructors.firstWhere(
        (c) => c.name == 'fromJson',
      );
      final jsonArg = fromJsonConstructor.formalParameters.firstOrNull;
      jsonType = jsonArg?.type;
    }

    if (jsonType == null) {
      throw InvalidGenerationSourceError(
        'Unable to build deserialization code for $type. Is not a standard '
        'dart type and no valid .fromJson constructor could be found.',
        element: type.element,
        todo:
            'Add a fromJson constructor that a single, '
            'positional parameter.',
      );
    }

    return jsonType;
  }

  Expression _maybeCast(Expression ref, Reference type, bool noCast) =>
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
        ..annotations.add(Annotations.pragmaVmPreferInline)
        ..annotations.add(Annotations.pragmaDart2jsTryInline)
        ..annotations.add(Annotations.pragmaWasmPreferInline)
        ..returns = tConverted
        ..types.add(tConverted.boundTo(CoreTypes.$Object))
        ..types.add(tJson.boundTo(CoreTypes.$Object))
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
        ..annotations.add(Annotations.pragmaVmPreferInline)
        ..annotations.add(Annotations.pragmaDart2jsTryInline)
        ..annotations.add(Annotations.pragmaWasmPreferInline)
        ..returns = tConverted.asNullable(true)
        ..types.add(tConverted.boundTo(CoreTypes.$Object))
        ..types.add(tJson.boundTo(CoreTypes.$Object))
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
            .conditional(literalNull, convertParamRef.call([valueParamRef]))
            .code,
    );
  }

  /// Ensures that the key type of [mapType] can be a JSON object key.
  ///
  /// Only non nullable [String]s can be used. `dynamic`, `Object` and `Object?`
  /// are accepted as an unchecked escape hatch - no conversion is emitted for
  /// them and the key must already be a [String] at runtime.
  static void _validateMapKey(InterfaceType mapType) {
    final keyType = mapType.typeArguments[0];

    // must be checked first, as isNullableType reports dynamic as nullable
    if (keyType is DynamicType || keyType.isDartCoreObject) {
      return;
    }

    if (keyType.isDartCoreString && !keyType.isNullableType) {
      return;
    }

    throw InvalidGenerationSourceError(
      'Only non nullable Strings can be used as map keys, but '
      '${mapType.getDisplayString()} was used.',
      todo: 'Change the key type of the map to String.',
    );
  }

  static Never throwInvalidRecord(RecordType recordType) {
    throw InvalidGenerationSourceError(
      'Records cannot be a mixture of positional and named.',
      element: recordType.element,
      todo: 'Make all record parameters either positional or named.',
    );
  }
}
