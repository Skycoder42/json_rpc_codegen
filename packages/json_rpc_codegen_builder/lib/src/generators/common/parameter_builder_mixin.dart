import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart' hide FunctionType;
import 'package:code_builder/code_builder.dart' hide RecordType;
import 'package:dart_test_tools/code_gen.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

import '../../extensions/code_builder_extensions.dart';
import '../proxy_spec.dart';
import 'annotations.dart';
import 'closure_builder_mixin.dart';
import 'serialization_mixin.dart';
import 'types.dart';

@internal
base mixin ParameterBuilderMixin
    on ProxySpec, SerializationMixin, ClosureBuilderMixin {
  static const nullCheckedOrName = r'$nullCheckedOr';
  static const existsOrName = r'$existsOr';
  static const nullCheckedName = r'$nullChecked';

  static Iterable<Spec> buildGlobals() sync* {
    yield _buildParameterExtensions();
  }

  Reference paramRefFor(FormalParameterElement param) =>
      refer('\$\$${param.name}');

  Code buildPositional(
    Reference paramsRef,
    int position,
    FormalParameterElement param,
  ) => _buildParameter(paramsRef.index(literalNum(position)), param);

  Code buildNamed(Reference paramsRef, FormalParameterElement param) =>
      _buildParameter(paramsRef.index(literalString(param.name!)), param);

  Code _buildParameter(Expression paramRef, FormalParameterElement param) =>
      declareFinal(
        '\$\$${param.name}',
      ).assign(_buildConversion(paramRef, param)).statement;

  Expression _buildConversion(
    Expression paramRef,
    FormalParameterElement param,
  ) {
    final paramType = param.type;
    return switch (paramType) {
      DartType(isDartCoreInt: true) => _accessPrimitive(
        paramRef,
        param,
        'asInt',
      ),
      DartType(isDartCoreDouble: true) => _accessPrimitive(
        paramRef,
        param,
        'asNum',
        (value) => value.property('toDouble').call(const []),
      ),
      DartType(isDartCoreNum: true) => _accessPrimitive(
        paramRef,
        param,
        'asNum',
      ),
      DartType(isDartCoreBool: true) => _accessPrimitive(
        paramRef,
        param,
        'asBool',
      ),
      DartType(isDartCoreString: true) => _accessPrimitive(
        paramRef,
        param,
        'asString',
      ),
      DartType(isEnum: true) => _accessJsonConverted(
        paramRef,
        param,
        'asString',
        paramType,
      ),
      DartType(isDartCoreIterable: true) ||
      DartType(isDartCoreList: true) ||
      DartType(
        isDartCoreSet: true,
      ) => _accessJsonConverted(paramRef, param, 'asList', paramType),
      DartType(isDartCoreMap: true) => _accessJsonConverted(
        paramRef,
        param,
        'asMap',
        paramType,
      ),
      RecordType(
        positionalFields: List(isNotEmpty: true),
        namedFields: List(isNotEmpty: true),
      ) =>
        SerializationMixin.throwInvalidRecord(paramType),
      RecordType(namedFields: List(isNotEmpty: true)) => _accessJsonConverted(
        paramRef,
        param,
        'asMap',
        paramType,
      ),
      RecordType() => _accessJsonConverted(
        paramRef,
        param,
        'asList',
        paramType,
      ),
      InterfaceType(element: ClassElement(name: 'Uri')) => _accessPrimitive(
        paramRef,
        param,
        'asUri',
      ),
      InterfaceType(element: ClassElement(name: 'DateTime')) =>
        _accessPrimitive(paramRef, param, 'asDateTime'),
      DynamicType() => _accessPrimitive(paramRef, param, 'value'),
      _ => _accessFromJson(paramRef, param, paramType),
    };
  }

  Expression _accessPrimitive(
    Expression paramRef,
    FormalParameterElement param,
    String getter, [
    Expression Function(Expression value)? transform,
  ]) {
    if (param.type.isNullableType && param.type is! DynamicType) {
      final closure = closure1(
        r'$v',
        (p1) => p1.property(getter).apply(transform).code,
      );
      if (param.isOptional) {
        return paramRef
            .property(nullCheckedOrName)
            .call(
              [closure, _getDefault(param)],
              const {},
              [param.type.toReference(nullable: false)],
            );
      } else {
        return paramRef
            .property(nullCheckedName)
            .call(
              [closure],
              const {},
              [param.type.toReference(nullable: false)],
            );
      }
    } else {
      if (param.isOptional) {
        _ensureHasDefault(param);
        return paramRef
            .property('${getter}Or')
            .call([_getDefault(param)])
            .apply(transform);
      } else {
        return paramRef.property(getter).apply(transform);
      }
    }
  }

  Expression _accessJsonConverted(
    Expression paramRef,
    FormalParameterElement param,
    String getter,
    DartType type, [
    Expression Function(Expression value)? transform,
  ]) {
    final closure = closure1(
      r'$v',
      (p1) => fromJson(
        type,
        p1.property(getter).apply(transform),
        noCast: true,
        isNull: false,
      ).code,
    );

    if (param.type.isNullableType && param.type is! DynamicType) {
      if (param.isOptional) {
        return paramRef
            .property(nullCheckedOrName)
            .call(
              [closure, _getDefault(param)],
              const {},
              [type.toReference(nullable: false)],
            );
      } else {
        return paramRef
            .property(nullCheckedName)
            .call([closure], const {}, [type.toReference(nullable: false)]);
      }
    } else {
      if (param.isOptional) {
        _ensureHasDefault(param);
        return paramRef
            .property(existsOrName)
            .call(
              [closure, _getDefault(param)],
              const {},
              [type.toReference()],
            );
      } else {
        return fromJson(
          type,
          paramRef.property(getter).apply(transform),
          noCast: true,
        );
      }
    }
  }

  Expression _accessFromJson(
    Expression paramRef,
    FormalParameterElement param,
    DartType type,
  ) {
    final jsonType = fromJsonType(type);
    final (getter, transform) = switch (jsonType) {
      DartType(isDartCoreInt: true) => ('asInt', null),
      DartType(isDartCoreDouble: true) => (
        'asNum',
        (Expression e) => e.property('toDouble').call(const []),
      ),
      DartType(isDartCoreNum: true) => ('asNum', null),
      DartType(isDartCoreBool: true) => ('asBool', null),
      DartType(isDartCoreString: true) => ('asString', null),
      DartType(isEnum: true) => ('asString', null),
      DartType(isDartCoreIterable: true) ||
      DartType(isDartCoreList: true) ||
      DartType(
        isDartCoreSet: true,
      ) => ('asList', (Expression e) => e.property('cast').call(const [])),
      DartType(isDartCoreMap: true) => (
        'asMap',
        (Expression e) => e.property('cast').call(const []),
      ),
      DynamicType() => ('value', null),
      _ => ('value', (Expression e) => e.asA(jsonType.toReference())),
    };
    return _accessJsonConverted(paramRef, param, getter, type, transform);
  }

  // TODO public use everywhere
  Expression _getDefault(FormalParameterElement param) => param.hasDefaultValue
      ? CodeExpression(Code(param.defaultValueCode!))
      : literalNull;

  void _ensureHasDefault(FormalParameterElement param) {
    if (!param.hasDefaultValue) {
      throw InvalidGenerationSourceError(
        'Non nullable optional parameters must have a default value.',
        element: param,
        todo: 'Make the type nullable or specify a default value.',
      );
    }
  }

  static Extension _buildParameterExtensions() {
    final typeT = TypeReference((b) => b..symbol = 'T');
    const getterParamRef = Reference('getter');
    const defaultValueParamRef = Reference('defaultValue');
    return Extension(
      (b) => b
        ..name = r'_$JsonRpc2ParameterExtensions'
        ..on = Types.$Parameter
        ..methods.add(
          Method(
            (b) => b
              ..name = nullCheckedName
              ..annotations.add(Annotations.pragmaVmPreferInline)
              ..annotations.add(Annotations.pragmaDart2jsTryInline)
              ..annotations.add(Annotations.pragmaWasmPreferInline)
              ..types.add(typeT.boundTo(CoreTypes.$Object))
              ..returns = typeT.asNullable(true)
              ..requiredParameters.add(_buildGetter(getterParamRef, typeT))
              ..body = refer('value')
                  .notEqualTo(literalNull)
                  .conditional(
                    getterParamRef.call([refer('this')]),
                    literalNull,
                  )
                  .code,
          ),
        )
        ..methods.add(
          Method(
            (b) => b
              ..name = nullCheckedOrName
              ..annotations.add(Annotations.pragmaVmPreferInline)
              ..annotations.add(Annotations.pragmaDart2jsTryInline)
              ..annotations.add(Annotations.pragmaWasmPreferInline)
              ..types.add(typeT.boundTo(CoreTypes.$Object))
              ..returns = typeT.asNullable(true)
              ..requiredParameters.add(_buildGetter(getterParamRef, typeT))
              ..requiredParameters.add(
                Parameter(
                  (b) => b
                    ..name = defaultValueParamRef.symbol!
                    ..type = typeT.asNullable(true),
                ),
              )
              ..body = refer('exists')
                  .conditional(
                    refer(nullCheckedName).call([getterParamRef]),
                    defaultValueParamRef,
                  )
                  .code,
          ),
        )
        ..methods.add(
          Method(
            (b) => b
              ..name = existsOrName
              ..annotations.add(Annotations.pragmaVmPreferInline)
              ..annotations.add(Annotations.pragmaDart2jsTryInline)
              ..annotations.add(Annotations.pragmaWasmPreferInline)
              ..types.add(typeT)
              ..returns = typeT
              ..requiredParameters.add(_buildGetter(getterParamRef, typeT))
              ..requiredParameters.add(
                Parameter(
                  (b) => b
                    ..name = defaultValueParamRef.symbol!
                    ..type = typeT,
                ),
              )
              ..body = refer('exists')
                  .conditional(
                    getterParamRef.call([refer('this')]),
                    defaultValueParamRef,
                  )
                  .code,
          ),
        ),
    );
  }

  static Parameter _buildGetter(Reference name, TypeReference type) =>
      Parameter(
        (b) => b
          ..name = name.symbol!
          ..type = FunctionType(
            (b) => b
              ..returnType = type
              ..requiredParameters.add(Types.$Parameter),
          ),
      );
}

extension on Expression {
  Expression apply(Expression Function(Expression value)? transform) =>
      transform?.call(this) ?? this;
}
