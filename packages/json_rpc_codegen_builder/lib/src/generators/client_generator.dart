import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import 'proxy_spec.dart';

/// @nodoc
@internal
final class ClientGenerator extends ProxySpec {
  static const _clientName = '_jsonRpcClient';
  static const _clientRef = Reference(_clientName);

  final ClassElement _class;

  /// @nodoc
  const ClientGenerator(this._class);

  /// @nodoc
  @override
  Class build() => Class(
        (b) => b
          ..name = '${_class.name}Client'
          ..implements.add(refer(_class.name))
          ..fields.add(
            Field(
              (b) => b
                ..name = _clientName
                ..modifier = FieldModifier.final$
                ..type = TypeReference(
                  (b) => b
                    ..symbol = 'Client'
                    ..url = 'package:json_rpc_2/json_rpc_2.dart',
                ),
            ),
          )
          ..constructors.add(
            Constructor(
              (b) => b
                ..constant = true
                ..requiredParameters.add(
                  Parameter(
                    (b) => b
                      ..name = _clientName
                      ..toThis = true,
                  ),
                ),
            ),
          )
          ..methods.addAll(_class.methods.map(_buildMethod)),
      );

  Method _buildMethod(MethodElement method) {
    if (method.returnType is VoidType) {
      return _buildNotificationMethod(method);
    }

    return Method(
      (b) => b
        ..name = method.name
        ..returns = TypeReference((b) => b..symbol = 'void'),
    );
  }

  Method _buildNotificationMethod(MethodElement method) => Method(
        (b) => b
          ..name = method.name
          ..types.addAll(method.typeParameters.map(_buildTypeParameter))
          ..returns = TypeReference((b) => b..symbol = 'void')
          ..requiredParameters.addAll(
            method.parameters
                .where((e) => e.isRequiredPositional)
                .map((e) => _buildParameter(e, true)),
          )
          ..optionalParameters.addAll(
            method.parameters
                .where((e) => !e.isRequiredPositional)
                .map((e) => _buildParameter(e, false)),
          )
          ..annotations.add(const Reference('override')),
      );

  Parameter _buildParameter(ParameterElement parameter, bool positional) =>
      Parameter(
        (b) => b
          ..name = parameter.name
          ..type = _buildType(parameter.type)
          ..named = parameter.isNamed
          ..required = parameter.isRequiredNamed
          ..covariant = parameter.isCovariant
          ..defaultTo = parameter.hasDefaultValue
              ? Code(parameter.defaultValueCode!)
              : null,
      );

  TypeReference _buildType(DartType dartType) => TypeReference(
        (b) {
          b
            ..symbol = dartType.element!.name
            ..isNullable = dartType.nullabilitySuffix != NullabilitySuffix.none
            ..url = dartType.element?.library?.location?.components.firstOrNull;

          if (dartType is InterfaceType) {
            b.types.addAll(dartType.typeArguments.map(_buildType));
          }
        },
      );

  TypeReference _buildTypeParameter(TypeParameterElement typeParameter) =>
      TypeReference(
        (b) => b
          ..symbol = typeParameter.name
          ..bound = typeParameter.bound != null
              ? _buildType(typeParameter.bound!)
              : null,
      );
}
