import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

import '../common/serialization_builder.dart';
import '../common/types.dart';
import '../proxy_spec.dart';

/// @nodoc
@internal
final class ServerGenerator extends ProxySpec {
  static const _serverName = 'jsonRpcServer';
  static const _serverRef = Reference(_serverName);
  static const _paramsParamName = 'p';
  static const _paramsParamRef = Reference(_paramsParamName);

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
              ...method.parameters.mapIndexed(_buildPositionalParamMapping),
            if (hasNamed) ...method.parameters.map(_buildNamedParamMapping),
          ]),
      ).closure,
    ]).statement;
  }

  Code _buildPositionalParamMapping(int position, ParameterElement param) =>
      _buildParamMapping(
        _paramsParamRef.index(literalNum(position)),
        param,
      );

  Code _buildNamedParamMapping(ParameterElement param) => _buildParamMapping(
        _paramsParamRef.index(literalString(param.name)),
        param,
      );

  Code _buildParamMapping(Expression paramRef, ParameterElement param) {
    final jsonType = SerializationBuilder.jsonTypeFor(param.type);

    final Expression paramValue;
    if (param.isOptional) {
      paramValue = paramRef.property(jsonType.paramGetOr).call([
        if (param.hasDefaultValue)
          CodeExpression(Code(param.defaultValueCode!))
        else
          literalNull,
      ]);
    } else {
      paramValue = paramRef.property(jsonType.paramGet);
    }

    return declareFinal(param.name)
        .assign(
          SerializationBuilder.fromJson(
            param.type,
            paramValue,
            noCast: true,
          ),
        )
        .statement;
  }
}

// TODO disallow generics
// TODO handle null values
// TODO map Uri/DateTime
