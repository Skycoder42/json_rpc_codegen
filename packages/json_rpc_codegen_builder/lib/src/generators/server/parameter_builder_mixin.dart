import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';
import 'package:source_helper/source_helper.dart';

import '../common/code_builder_extensions.dart';
import '../common/serialization_mixin.dart';
import '../proxy_spec.dart';

/// @nodoc
@internal
base mixin ParameterBuilderMixin on ProxySpec, SerializationMixin {
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
      declareFinal('\$${param.name}')
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
    if (param.type.isNullableType) {
      const maybeParamRef = Reference(r'$v');
      final closure = Method(
        (b) => b
          ..requiredParameters.add(
            Parameter(
              (b) => b..name = maybeParamRef.symbol!,
            ),
          )
          ..body = maybeParamRef.property(getter).code,
      ).closure;

      if (param.isOptional) {
        return paramRef.property('maybeNullOr').call([
          closure,
          if (param.hasDefaultValue) _defaultFor(param) else literalNull,
        ]);
      } else {
        return paramRef.property('nullOr').call([closure]);
      }
    } else {
      if (param.isOptional) {
        return paramRef.property('${getter}Or').call([_defaultFor(param)]);
      } else {
        return paramRef.property(getter);
      }
    }
  }

  Expression _defaultFor(ParameterElement param) =>
      CodeExpression(Code(param.defaultValueCode!));
}
