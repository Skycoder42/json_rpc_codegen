import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';
import 'package:source_helper/source_helper.dart';

import 'types.dart';

/// @nodoc
@internal
abstract base class SerializationBuilder {
  SerializationBuilder._();

  /// @nodoc
  static Expression fromJson(DartType type, Expression value) {
    if (type.isDartCoreIterable || type.isDartCoreList) {
      return _fromList(type, value);
    } else if (type.isDartCoreMap) {
      return _fromMap(type, value);
    } else if (type.isEnum) {
      return Types.fromDartType(type)
          .property('values')
          .property('byName')
          .call([value.asA(Types.string)]);
    } else if (_isPrimitiveType(type)) {
      return value.asA(Types.fromDartType(type));
    } else {
      return Types.fromDartType(type).newInstanceNamed('fromJson', [
        value.asA(Types.map(Types.string, Types.dynamic)),
      ]);
    }
  }

  static Expression _fromList(DartType type, Expression value) {
    final interfaceType = type as InterfaceType;
    final listType = interfaceType.typeArguments.single;
    const elementParamRef = Reference('e');
    final iterable = value.asA(Types.list()).property('map').call([
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

  static Expression _fromMap(DartType type, Expression value) {
    final interfaceType = type as InterfaceType;
    final keyType = interfaceType.typeArguments[0];
    final valueType = interfaceType.typeArguments[1];

    const keyParamRef = Reference('k');
    const valueParamRef = Reference('v');
    return value.asA(Types.map()).property('map').call([
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

  static bool _isPrimitiveType(DartType type) =>
      type.isDartCoreNull ||
      type.isDartCoreBool ||
      type.isDartCoreNum ||
      type.isDartCoreInt ||
      type.isDartCoreDouble ||
      type.isDartCoreString;
}
