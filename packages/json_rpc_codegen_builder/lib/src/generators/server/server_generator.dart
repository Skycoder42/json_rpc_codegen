import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart' hide ParameterBuilder;
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import '../common/types.dart';
import '../proxy_spec.dart';
import 'parameter_builder.dart';

/// @nodoc
@internal
final class ServerGenerator extends ProxySpec {
  static const _serverName = 'jsonRpcServer';
  static const _serverRef = Reference(_serverName);
  static const _paramsParamName = 'p';
  static const _paramsParamRef = Reference(_paramsParamName);

  // ignore: avoid_field_initializers_in_const_classes
  final _parameterBuilder = const ParameterBuilder(_paramsParamRef);

  final ClassElement _class;

  /// @nodoc
  const ServerGenerator(this._class);

  @override
  Class build() => Class(
        (b) => b
          ..name = '${_class.name}Server'
          ..abstract = true
          ..implements.add(refer(_class.name))
          ..fields.add(
            Field(
              (b) => b
                ..name = _serverName
                ..modifier = FieldModifier.final$
                ..type = Types.jsonRpc2Server,
            ),
          )
          ..methods.add(_buildRegisterMethod()),
      );

  Method _buildRegisterMethod() => Method(
        (b) => b
          ..name = '_registerMethods'
          ..returns = Types.$void
          ..body = Block.of(
            _class.methods.map(_buildRegisterFor),
          ),
      );

  Code _buildRegisterFor(MethodElement method) {
    final hasPositional = method.parameters.any((e) => e.isPositional);
    final hasNamed = method.parameters.any((e) => e.isNamed);
    if (hasPositional && hasNamed) {
      throw InvalidGenerationSourceError(
        'An RPC method can have only either named or positional parameters, '
        'not both',
        element: method,
        // ignore: missing_whitespace_between_adjacent_strings
        todo: 'Make all parameters positional or named',
      );
    }

    return _serverRef.property('registerMethod').call([
      literalString(method.name),
      Method(
        (b) => b
          ..requiredParameters.addAll([
            if (method.parameters.isNotEmpty)
              Parameter(
                (b) => b
                  ..name = _paramsParamName
                  ..type = Types.jsonRpc2Parameters,
              ),
          ])
          ..body = Block.of([
            if (hasPositional)
              ...method.parameters
                  .mapIndexed(_parameterBuilder.buildPositional),
            if (hasNamed)
              ...method.parameters.map(_parameterBuilder.buildNamed),
          ]),
      ).closure,
    ]).statement;
  }
}

// TODO handle null values
// TODO disallow generics
// TODO map Uri/DateTime
// TODO explicit toJson?
