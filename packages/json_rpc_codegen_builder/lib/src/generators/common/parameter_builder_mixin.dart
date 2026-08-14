import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart' hide FunctionType;
import 'package:code_builder/code_builder.dart' hide RecordType;
import 'package:collection/collection.dart';
import 'package:dart_test_tools/code_gen.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

import '../../extensions/code_builder_extensions.dart';
import '../../extensions/parameter_extensions.dart';
import '../../readers/rpc_param_reader.dart';
import 'annotations.dart';
import 'closure_builder_mixin.dart';
import 'method_mapper_mixin.dart';
import 'serialization_mixin.dart';
import 'types.dart';

@internal
base mixin ParameterBuilderMixin
    on MethodMapperMixin, SerializationMixin, ClosureBuilderMixin {
  static const nullCheckedOrName = r'$nullCheckedOr';
  static const existsOrName = r'$existsOr';
  static const nullCheckedName = r'$nullChecked';

  static const _getterParamRef = Reference('getter');
  static final _typeT = TypeReference((b) => b..symbol = 'T');

  static Iterable<Spec> buildGlobals() sync* {
    yield _buildParameterExtensions();
  }

  @protected
  Reference paramRefFor(FormalParameterElement param) =>
      refer('\$\$${param.name}');

  @protected
  Code buildPositional(
    Reference paramsRef,
    int position,
    FormalParameterElement param,
  ) => _declareExtractedParameter(paramsRef.index(literalNum(position)), param);

  @protected
  Code buildNamed(Reference paramsRef, FormalParameterElement param) =>
      _declareExtractedParameter(
        paramsRef.index(literalString(rpcParamName(param), raw: true)),
        param,
      );

  /// Extracts all formal parameters of [method] from [params] into locals.
  @protected
  Iterable<Code> buildParameterExtraction(
    MethodElement method,
    ParameterMode parameterMode,
    Reference params, {
    int positionalOffset = 0,
  }) sync* {
    if (parameterMode.hasPositional) {
      yield* method.formalParameters.mapIndexed(
        (i, e) => buildPositional(params, i + positionalOffset, e),
      );
    }
    if (parameterMode.hasNamed) {
      yield* method.formalParameters.map((e) => buildNamed(params, e));
    }
  }

  /// Invokes [method] on the implementation, forwarding the extracted locals.
  @protected
  Expression buildTargetInvocation(MethodElement method) =>
      refer(method.name!).call(
        [
          for (final p in method.formalParameters.where((p) => p.isPositional))
            paramRefFor(p),
        ],
        {
          for (final p in method.formalParameters.where((p) => p.isNamed))
            p.name!: paramRefFor(p),
        },
      );

  Code _declareExtractedParameter(
    Expression paramRef,
    FormalParameterElement param,
  ) =>
      declareFinal(paramRefFor(param).symbol!)
          .assign(_buildConversion(paramRef, param))
          .statement;

  Expression _buildConversion(
    Expression paramRef,
    FormalParameterElement param,
  ) {
    // a custom converter defines the json type and thus the accessor to use
    if (RpcParamReader.read(param)?.fromJsonConverter != null) {
      return _accessFromJson(paramRef, param);
    }

    final paramType = param.type;
    if (_primitiveAccessor(paramType) case (:final getter, :final transform)?) {
      return _accessPrimitive(paramRef, param, getter, transform);
    }
    return switch (paramType) {
      DartType(isEnum: true) => _accessJsonConverted(
        paramRef,
        param,
        'asString',
      ),
      DartType(isDartCoreIterable: true) ||
      DartType(isDartCoreList: true) ||
      DartType(
        isDartCoreSet: true,
      ) => _accessJsonConverted(paramRef, param, 'asList'),
      DartType(isDartCoreMap: true) => _accessJsonConverted(
        paramRef,
        param,
        'asMap',
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
      ),
      RecordType() => _accessJsonConverted(paramRef, param, 'asList'),
      InterfaceType(element: ClassElement(name: 'Uri')) => _accessPrimitive(
        paramRef,
        param,
        'asUri',
      ),
      InterfaceType(element: ClassElement(name: 'DateTime')) =>
        _accessPrimitive(paramRef, param, 'asDateTime'),
      _ => _accessFromJson(paramRef, param),
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
      return _accessNullChecked(paramRef, param, closure);
    } else {
      if (param.isOptional) {
        _ensureHasDefault(param);
        return paramRef
            .property('${getter}Or')
            .call([param.defaultValueExpression])
            .apply(transform);
      } else {
        return paramRef.property(getter).apply(transform);
      }
    }
  }

  Expression _accessJsonConverted(
    Expression paramRef,
    FormalParameterElement param,
    String getter, [
    Expression Function(Expression value)? transform,
  ]) {
    final closure = closure1(
      r'$v',
      (p1) => paramFromJson(
        param,
        p1.property(getter).apply(transform),
        noCast: true,
        isNull: false,
      ).code,
    );

    if (param.type.isNullableType && param.type is! DynamicType) {
      return _accessNullChecked(paramRef, param, closure);
    } else {
      if (param.isOptional) {
        _ensureHasDefault(param);
        return paramRef
            .property(existsOrName)
            .call(
              [closure, param.defaultValueExpression],
              const {},
              [param.type.toReference()],
            );
      } else {
        return paramFromJson(
          param,
          paramRef.property(getter).apply(transform),
          noCast: true,
        );
      }
    }
  }

  /// Reads a nullable [param] via [closure], honoring an optional default.
  Expression _accessNullChecked(
    Expression paramRef,
    FormalParameterElement param,
    Expression closure,
  ) {
    if (param.isOptional) {
      return paramRef
          .property(nullCheckedOrName)
          .call(
            [closure, param.defaultValueExpression],
            const {},
            [param.type.toReference(nullable: false)],
          );
    } else {
      return paramRef
          .property(nullCheckedName)
          .call([closure], const {}, [param.type.toReference(nullable: false)]);
    }
  }

  Expression _accessFromJson(
    Expression paramRef,
    FormalParameterElement param,
  ) {
    final jsonType = paramJsonType(param);
    if (_primitiveAccessor(jsonType) case (:final getter, :final transform)?) {
      return _accessJsonConverted(paramRef, param, getter, transform);
    }

    final (getter, transform) = switch (jsonType) {
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
      _ => ('value', (Expression e) => e.asA(jsonType.toReference())),
    };
    return _accessJsonConverted(paramRef, param, getter, transform);
  }

  /// Maps [type] to the json_rpc_2 parameter getter for it, if primitive.
  ({String getter, Expression Function(Expression value)? transform})?
  _primitiveAccessor(DartType type) => switch (type) {
    DartType(isDartCoreInt: true) => (getter: 'asInt', transform: null),
    DartType(isDartCoreDouble: true) => (
      getter: 'asNum',
      transform: (value) => value.property('toDouble').call(const []),
    ),
    DartType(isDartCoreNum: true) => (getter: 'asNum', transform: null),
    DartType(isDartCoreBool: true) => (getter: 'asBool', transform: null),
    DartType(isDartCoreString: true) => (getter: 'asString', transform: null),
    DynamicType() => (getter: 'value', transform: null),
    _ => null,
  };

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
    const defaultValueParamRef = Reference('defaultValue');
    return Extension(
      (b) => b
        ..name = r'_$JsonRpc2ParameterExtensions'
        ..on = Types.$Parameter
        ..methods.add(
          _buildExtensionMethod(
            name: nullCheckedName,
            typeParam: _typeT.boundTo(CoreTypes.$Object),
            returns: _typeT.asNullable(true),
            body: refer('value')
                .notEqualTo(literalNull)
                .conditional(_getterParamRef.call([refer('this')]), literalNull)
                .code,
          ),
        )
        ..methods.add(
          _buildExtensionMethod(
            name: nullCheckedOrName,
            typeParam: _typeT.boundTo(CoreTypes.$Object),
            returns: _typeT.asNullable(true),
            defaultValueParam: Parameter(
              (b) => b
                ..name = defaultValueParamRef.symbol!
                ..type = _typeT.asNullable(true),
            ),
            body: refer('exists')
                .conditional(
                  refer(nullCheckedName).call([_getterParamRef]),
                  defaultValueParamRef,
                )
                .code,
          ),
        )
        ..methods.add(
          _buildExtensionMethod(
            name: existsOrName,
            typeParam: _typeT,
            returns: _typeT,
            defaultValueParam: Parameter(
              (b) => b
                ..name = defaultValueParamRef.symbol!
                ..type = _typeT,
            ),
            body: refer('exists')
                .conditional(
                  _getterParamRef.call([refer('this')]),
                  defaultValueParamRef,
                )
                .code,
          ),
        ),
    );
  }

  /// Builds one of the `Parameter` accessor extension methods.
  static Method _buildExtensionMethod({
    required String name,
    required TypeReference typeParam,
    required Reference returns,
    Parameter? defaultValueParam,
    required Code body,
  }) => Method(
    (b) => b
      ..name = name
      ..annotations.addAll(Annotations.alwaysInline)
      ..types.add(typeParam)
      ..returns = returns
      ..requiredParameters.add(_buildGetter())
      ..requiredParameters.addAll([?defaultValueParam])
      ..body = body,
  );

  static Parameter _buildGetter() => Parameter(
    (b) => b
      ..name = _getterParamRef.symbol!
      ..type = FunctionType(
        (b) => b
          ..returnType = _typeT
          ..requiredParameters.add(Types.$Parameter),
      ),
  );
}

extension on Expression {
  Expression apply(Expression Function(Expression value)? transform) =>
      transform?.call(this) ?? this;
}
