import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart' hide FunctionType;
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';
import 'package:source_helper/source_helper.dart';

import '../common/closure_builder_mixin.dart';
import '../../extensions/code_builder_extensions.dart';
import '../common/serialization_mixin.dart';
import '../common/types.dart';
import '../proxy_spec.dart';

/// @nodoc
@internal
base mixin ParameterBuilderMixin
    on ProxySpec, SerializationMixin, ClosureBuilderMixin {
  static const _nullOrName = r'$nullOr';
  static const _nullOrRef = Reference(_nullOrName);
  static const _maybeNullOrName = r'$maybeNullOr';

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
      return _access(paramRef, param, 'asInt');
    } else if (paramType.isDartCoreDouble) {
      return _access(paramRef, param, 'asNum')
          .autoProperty('toDouble', paramType.isNullableType)
          .call(const []);
    } else if (paramType.isDartCoreNum) {
      return _access(paramRef, param, 'asNum');
    } else if (paramType.isDartCoreBool) {
      return _access(paramRef, param, 'asBool');
    } else if (paramType.isDartCoreString) {
      return _access(paramRef, param, 'asString');
    } else if (paramType.isEnum) {
      return fromJson(
        paramType,
        _access(paramRef, param, 'asString'),
        noCast: true,
      );
    } else if (paramType.isDartCoreList || paramType.isDartCoreIterable) {
      return fromJson(
        paramType,
        _access(paramRef, param, 'asList'),
        noCast: true,
      );
    } else if (paramType.isDartCoreMap) {
      return fromJson(
        paramType,
        _access(paramRef, param, 'asMap'),
        noCast: true,
      );
    } else if (paramType
        case InterfaceType(
          element: ClassElement(
            name: 'Uri',
          )
        )) {
      return _access(paramRef, param, 'asUri');
    } else if (paramType
        case InterfaceType(
          element: ClassElement(
            name: 'DateTime',
          )
        )) {
      return _access(paramRef, param, 'asDateTime');
    } else if (paramType is DynamicType) {
      return _access(paramRef, param, 'value');
    } else {
      return fromJson(
        paramType,
        _access(paramRef, param, 'value'),
        noCast: true,
      );
    }
  }

  Expression _access(
    Expression paramRef,
    ParameterElement param,
    String getter,
  ) {
    if (param.type.isNullableType && param.type is! DynamicType) {
      final closure = closure1(r'$v', (p1) => p1.property(getter).code);
      if (param.isOptional) {
        return paramRef.property(_maybeNullOrName).call([
          closure,
          // if (param.hasDefaultValue) _defaultFor(param) else literalNull,
        ]);
      } else {
        return paramRef.property(_nullOrName).call([closure]);
      }
    } else {
      if (param.isOptional) {
        return paramRef.property('${getter}Or').call([/*_defaultFor(param)*/]);
      } else {
        return paramRef.property(getter);
      }
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
              ..name = _nullOrName
              ..types.add(typeT)
              ..returns = typeT.asNullable(true)
              ..requiredParameters.add(_buildGetter(getterParamRef, typeT))
              ..body = refer('value')
                  .equalTo(literalNull)
                  .conditional(
                    literalNull,
                    getterParamRef.call([refer('this')]),
                  )
                  .code,
          ),
        )
        ..methods.add(
          Method(
            (b) => b
              ..name = _maybeNullOrName
              ..types.add(typeT)
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
                    _nullOrRef.call(const [getterParamRef], const {}, [typeT]),
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
              ..requiredParameters.add(Types.jsonRpc2Parameter),
          ),
      );
}
