import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:json_rpc_codegen/json_rpc_codegen.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import 'generators/client/client_class_builder.dart';
import 'generators/client/client_mixin_builder.dart';
import 'generators/common/serialization_mixin.dart';
import 'generators/server/parameter_builder_mixin.dart';
import 'generators/server/server_class_builder.dart';
import 'generators/server/server_mixin_builder.dart';
import 'readers/json_rpc_reader.dart';

/// @nodoc
@internal
class JsonRpcGenerator extends GeneratorForAnnotation<JsonRpc> {
  /// @nodoc
  final BuilderOptions builderOptions;

  /// @nodoc
  const JsonRpcGenerator(this.builderOptions);

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement ||
        !element.isAbstract ||
        !element.isInterface) {
      throw InvalidGenerationSourceError(
        'The $JsonRpc annotation can only be used on abstract interfaces',
        element: element,
      );
    }

    final jsonRpc = JsonRpcReader(annotation);
    final emitter = DartEmitter(
      orderDirectives: true,
      useNullSafetySyntax: true,
    );
    return _buildLibrary(jsonRpc, element)
        .accept(emitter, StringBuffer())
        .toString();
  }

  Library _buildLibrary(JsonRpcReader jsonRpc, ClassElement clazz) => Library(
        (b) => b
          ..ignoreForFile.add('type=lint')
          ..body.addAll([
            if (jsonRpc.client) ClientMixinBuilder(clazz),
            if (jsonRpc.server) ServerMixinBuilder(clazz),
            if (jsonRpc.client && !jsonRpc.mixinsOnly)
              ClientClassBuilder(clazz),
            if (jsonRpc.server && !jsonRpc.mixinsOnly)
              ServerClassBuilder(clazz),
          ])
          ..body.addAll(SerializationMixin.buildGlobals())
          ..body.addAll(ParameterBuilderMixin.buildGlobals()),
      );
}
