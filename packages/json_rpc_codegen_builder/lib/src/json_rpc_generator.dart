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
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    final buffer = StringBuffer();

    // add library prefix
    _buildLibraryPrefix(buffer);

    // add content
    buffer.write(await super.generate(library, buildStep));

    // add library suffix
    _buildLibrarySuffix(buffer);

    return buffer.toString();
  }

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement || !element.isAbstract || !element.isPrivate) {
      throw InvalidGenerationSourceError(
        'The $JsonRpc annotation can only be used on abstract private classes',
        element: element,
      );
    }

    final jsonRpc = JsonRpcReader(annotation);
    final buffer = StringBuffer();
    final emitter = _createEmitter();
    if (jsonRpc.client) {
      ClientMixinBuilder(element).accept(emitter, buffer);
    }
    if (jsonRpc.server) {
      ServerMixinBuilder(element).accept(emitter, buffer);
    }
    if (jsonRpc.client && !jsonRpc.mixinsOnly) {
      ClientClassBuilder(element).accept(emitter, buffer);
    }
    if (jsonRpc.server && !jsonRpc.mixinsOnly) {
      ServerClassBuilder(element).accept(emitter, buffer);
    }

    return buffer.toString();
  }

  DartEmitter _createEmitter() {
    final emitter = DartEmitter(
      orderDirectives: true,
      useNullSafetySyntax: true,
    );
    return emitter;
  }

  void _buildLibraryPrefix(StringBuffer buffer) => Library(
        (b) => b
          ..ignoreForFile.add('type=lint')
          ..ignoreForFile.add('unused_element'),
      ).accept<StringSink>(_createEmitter(), buffer);

  void _buildLibrarySuffix(StringBuffer buffer) => Library(
        (b) => b
          ..body.addAll(SerializationMixin.buildGlobals())
          ..body.addAll(ParameterBuilderMixin.buildGlobals()),
      ).accept<StringSink>(_createEmitter(), buffer);
}

// TODO support sets, object and records
