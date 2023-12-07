import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart' hide FunctionType;
import 'package:code_builder/code_builder.dart' hide RecordType;
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

/// @nodoc
@internal
base mixin ParameterBuilderMixin
    on ProxySpec, SerializationMixin, ClosureBuilderMixin {
  static const maybeOrName = r'$maybeOr';
  static const nullOrName = r'$nullOr';
  static const maybeNullOrName = r'$maybeNullOr';

  /// @nodoc
  static Iterable<Spec> buildGlobals() sync* {
    yield _buildParameterExtensions();
  }

  /// @nodoc
  Reference paramRefFor(ParameterElement param) => refer('\$\$${param.name}');

  /// @nodoc
  Code buildPositional(
    Reference paramsRef,
    int position,
    ParameterElement param,
  ) =>
      _buildParameter(
        paramsRef.index(literalNum(position)),
        param,
      );

  /// @nodoc
  Code buildNamed(
    Reference paramsRef,
    ParameterElement param,
  ) =>
      _buildParameter(
        paramsRef.index(literalString(param.name)),
        param,
      );

  Code _buildParameter(Expression paramRef, ParameterElement param) =>
      declareFinal('\$\$${param.name}')
          .assign(_buildConversion(paramRef, param))
          .statement;

  Expression _buildConversion(Expression paramRef, ParameterElement param) {
    final paramType = param.type;
    if (paramType.isDartCoreInt) {
      return _accessPrimitive(paramRef, param, 'asInt');
    } else if (paramType.isDartCoreDouble) {
      return _accessPrimitive(paramRef, param, 'asNum')
          .autoProperty('toDouble', paramType.isNullableType)
          .call(const []);
    } else if (paramType.isDartCoreNum) {
      return _accessPrimitive(paramRef, param, 'asNum');
    } else if (paramType.isDartCoreBool) {
      return _accessPrimitive(paramRef, param, 'asBool');
    } else if (paramType.isDartCoreString) {
      return _accessPrimitive(paramRef, param, 'asString');
    } else if (paramType.isEnum) {
      return _accessJsonConverted(
        paramRef,
        param,
        'asString',
        (e) => fromJson(paramType, e, noCast: true, isNull: false),
      );
    } else if (paramType.isDartCoreIterable ||
        paramType.isDartCoreList ||
        paramType.isDartCoreSet) {
      return _accessJsonConverted(
        paramRef,
        param,
        'asList',
        (e) => fromJson(paramType, e, noCast: true, isNull: false),
      );
    } else if (paramType.isDartCoreMap) {
      return _accessJsonConverted(
        paramRef,
        param,
        'asMap',
        (e) => fromJson(paramType, e, noCast: true, isNull: false),
      );
    } else if (paramType is RecordType) {
      switch ((
        paramType.positionalFields.isNotEmpty,
        paramType.namedFields.isNotEmpty
      )) {
        case (false, false):
        case (true, false):
          return _accessJsonConverted(
            paramRef,
            param,
            'asList',
            (e) => fromJson(paramType, e, noCast: true, isNull: false),
          );
        case (false, true):
          return _accessJsonConverted(
            paramRef,
            param,
            'asMap',
            (e) => fromJson(paramType, e, noCast: true, isNull: false),
          );
        case (true, true):
          SerializationMixin.throwInvalidRecord(paramType);
      }
    } else if (paramType
        case InterfaceType(
          element: ClassElement(
            name: 'Uri',
          )
        )) {
      return _accessPrimitive(paramRef, param, 'asUri');
    } else if (paramType
        case InterfaceType(
          element: ClassElement(
            name: 'DateTime',
          )
        )) {
      return _accessPrimitive(paramRef, param, 'asDateTime');
    } else if (paramType is DynamicType) {
      return _accessPrimitive(paramRef, param, 'value');
    } else {
      return _accessJsonConverted(
        paramRef,
        param,
        'value',
        (e) => fromJson(paramType, e, noCast: true, isNull: false),
      );
    }
  }

  Expression _accessPrimitive(
    Expression paramRef,
    ParameterElement param,
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
        return paramRef.property('${getter}Or').call([
          _getDefault(param),
        ]);
      } else {
        return paramRef.property(getter);
      }
    }
  }

  Expression _accessJsonConverted(
    Expression paramRef,
    ParameterElement param,
    String getter,
    Expression Function(Expression e) fromJson,
  ) {
    final isServerDefault = DefaultsReader.isServerDefault(
      param.enclosingElement! as MethodElement,
    );

    final closure = closure1(
      r'$v',
      (p1) => fromJson(p1.property(getter)).code,
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
        return paramRef.property(maybeOrName).call([
          closure,
          _getDefault(param),
        ]);
      } else {
        return fromJson(paramRef.property(getter));
      }
    }
  }

  CodeExpression _getDefault(ParameterElement param) =>
      CodeExpression(Code(param.defaultValueCode!));

  void _ensureHasDefault(ParameterElement param) {
    if (!param.hasDefaultValue) {
      throw InvalidGenerationSourceError(
        'Non nullable optional parameters must have a default value.',
        element: param,
        todo: 'Make the type nullable or specify a default value.',
      );
    }
  }

  void _ensureHasNoDefault(ParameterElement param) {
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
        ..on = Types.jsonRpc2Parameter
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
              ..requiredParameters.add(Types.jsonRpc2Parameter),
          ),
      );
}
