import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../common/base_wrapper_builder_mixin.dart';
import '../common/code_builder_extensions.dart';
import '../common/types.dart';
import '../proxy_spec.dart';

/// @nodoc
@internal
base mixin WrapperBuilderMixin on ProxySpec, BaseWrapperBuilderMixin {
  static const _onUnhandledErrorName = 'onUnhandledError';
  static const _onUnhandledErrorRef = Reference(_onUnhandledErrorName);
  static const _strictProtocolChecksName = 'strictProtocolChecks';
  static const _strictProtocolChecksRef = Reference(_strictProtocolChecksName);

  @override
  Iterable<Constructor> buildConstructors(Reference serverRef) sync* {
    yield* super.buildConstructors(serverRef);
    yield _fromServer(serverRef);
  }

  @override
  Iterable<Method> buildWrapperMethods(Reference serverRef) sync* {
    yield _onUnhandledError(serverRef);
    yield _strictProtocolChecks(serverRef);
    yield* super.buildWrapperMethods(serverRef);
  }

  @override
  @visibleForOverriding
  TypeReference get baseType => Types.jsonRpc2Server;

  @override
  @visibleForOverriding
  Iterable<Parameter> get extraOptionalParams => [
        Parameter(
          (b) => b
            ..name = _onUnhandledErrorName
            ..type = Types.jsonRpc2ErrorCallback.asNullable(true)
            ..named = true,
        ),
        Parameter(
          (b) => b
            ..name = _strictProtocolChecksName
            ..named = true
            ..type = Types.$bool
            ..defaultTo = literalTrue.code,
        ),
      ];

  @override
  @visibleForOverriding
  Map<String, Expression> get extraArgs => const {
        _onUnhandledErrorName: _onUnhandledErrorRef,
        _strictProtocolChecksName: _strictProtocolChecksRef,
      };

  Constructor _fromServer(Reference serverRef) => Constructor(
        (b) => b
          ..name = 'fromServer'
          ..requiredParameters.add(
            Parameter(
              (b) => b
                ..name = serverRef.symbol!
                ..toThis = true,
            ),
          ),
      );

  Method _onUnhandledError(Reference serverRef) => Method(
        (b) => b
          ..name = _onUnhandledErrorName
          ..type = MethodType.getter
          ..returns = Types.jsonRpc2ErrorCallback.asNullable(true)
          ..body = serverRef.property(_onUnhandledErrorName).code,
      );

  Method _strictProtocolChecks(Reference serverRef) => Method(
        (b) => b
          ..name = _strictProtocolChecksName
          ..type = MethodType.getter
          ..returns = Types.$bool
          ..body = serverRef.property(_strictProtocolChecksName).code,
      );
}
