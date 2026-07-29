import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart' hide FunctionType;
import 'package:code_builder/code_builder.dart' hide RecordType;
import 'package:dart_test_tools/code_gen.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

import '../../extensions/code_builder_extensions.dart';
import '../../readers/defaults_reader.dart';
import '../proxy_spec.dart';
import 'annotations.dart';
import 'closure_builder_mixin.dart';
import 'serialization_mixin.dart';
import 'types.dart';

@internal
base mixin ParameterBuilderMixin
    on ProxySpec, SerializationMixin, ClosureBuilderMixin {
  static const maybeOrName = r'$maybeOr';
  static const nullOrName = r'$nullOr';
  static const maybeNullOrName = r'$maybeNullOr';

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
      ).autoProperty('toDouble', paramType.isNullableType).call(const []),
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
      _ => _accessJsonConverted(paramRef, param, 'value', paramType),
    };
  }

  Expression _accessPrimitive(
    Expression paramRef,
    FormalParameterElement param,
    String getter,
  ) {
    final isServerDefault = DefaultsReader.isServerDefault(
      param.enclosingElement! as MethodElement,
    );

    if (param.type.isNullableType && param.type is! DynamicType) {
      final closure = closure1(r'$v', (p1) => p1.property(getter).code);

      if (param.isOptional && isServerDefault) {
        _ensureHasNoDefault(param);
        return paramRef.property(maybeNullOrName).call([closure]);
      } else {
        return paramRef.property(nullOrName).call([closure]);
      }
    } else {
      if (param.isOptional && isServerDefault) {
        _ensureHasDefault(param);
        return paramRef.property('${getter}Or').call([_getDefault(param)]);
      } else {
        return paramRef.property(getter);
      }
    }
  }

  Expression _accessJsonConverted(
    Expression paramRef,
    FormalParameterElement param,
    String getter,
    DartType type,
  ) {
    final isServerDefault = DefaultsReader.isServerDefault(
      param.enclosingElement! as MethodElement,
    );

    final closure = closure1(
      r'$v',
      (p1) =>
          fromJson(type, p1.property(getter), noCast: true, isNull: false).code,
    );

    if (param.type.isNullableType && param.type is! DynamicType) {
      if (param.isOptional && isServerDefault) {
        _ensureHasNoDefault(param);
        return paramRef.property(maybeNullOrName).call([closure]);
      } else {
        return paramRef.property(nullOrName).call([closure]);
      }
    } else {
      if (param.isOptional && isServerDefault) {
        _ensureHasDefault(param);
        return paramRef
            .property(maybeOrName)
            .call(
              [closure, _getDefault(param)],
              const {},
              [type.toReference()],
            );
      } else {
        return fromJson(
          type,
          paramRef.property(getter),
          noCast: true,
          isNull: false,
        );
      }
    }
  }

  CodeExpression _getDefault(FormalParameterElement param) =>
      CodeExpression(Code(param.defaultValueCode!));

  void _ensureHasDefault(FormalParameterElement param) {
    if (!param.hasDefaultValue) {
      throw InvalidGenerationSourceError(
        'Non nullable optional parameters must have a default value.',
        element: param,
        todo: 'Make the type nullable or specify a default value.',
      );
    }
  }

  void _ensureHasNoDefault(FormalParameterElement param) {
    if (param.hasDefaultValue) {
      throw InvalidGenerationSourceError(
        'An RPC method cannot have an nullable optional parameter with a '
        'server sided default value.',
        element: param,
        todo: 'Make the type non nullable or remove the default value.',
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
              ..name = maybeOrName
              ..annotations.add(Annotations.pragmaPreferInline)
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
        )
        ..methods.add(
          Method(
            (b) => b
              ..name = nullOrName
              ..annotations.add(Annotations.pragmaPreferInline)
              ..types.add(typeT)
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
              ..name = maybeNullOrName
              ..annotations.add(Annotations.pragmaPreferInline)
              ..types.add(typeT)
              ..returns = typeT.asNullable(true)
              ..requiredParameters.add(_buildGetter(getterParamRef, typeT))
              ..body = refer('exists')
                  .and(refer('value').notEqualTo(literalNull))
                  .conditional(
                    getterParamRef.call([refer('this')]),
                    literalNull,
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
