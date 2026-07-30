import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_test_tools/code_gen.dart';
import 'package:json_rpc_codegen/json_rpc_codegen.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart' hide LibraryBuilder;

import 'generators/client/client_class_builder.dart';
import 'generators/client/client_mixin_builder.dart';
import 'generators/common/parameter_builder_mixin.dart';
import 'generators/common/serialization_mixin.dart';
import 'generators/server/server_class_builder.dart';
import 'generators/server/server_mixin_builder.dart';
import 'readers/json_rpc_reader.dart';

@internal
class JsonRpcGenerator extends GeneratorForAnnotation<JsonRpc>
    with DartGeneratorMixin {
  final BuilderOptions builderOptions;

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
    if (element is! ClassElement ||
        !element.isAbstract ||
        !element.isInterface) {
      throw InvalidGenerationSourceError(
        'The $JsonRpc annotation can only be used on abstract interface '
        'classes',
        element: element,
      );
    }

    final jsonRpc = JsonRpcReader(annotation);

    final library = LibraryBuilder();
    if (jsonRpc.client) {
      library.body.add(ClientMixinBuilder(element));
    }
    if (jsonRpc.server) {
      library.body.add(ServerMixinBuilder(element));
    }
    if (jsonRpc.client && !jsonRpc.mixinsOnly) {
      library.body.add(ClientClassBuilder(element));
    }
    if (jsonRpc.server && !jsonRpc.mixinsOnly) {
      library.body.add(ServerClassBuilder(element));
    }

    return createDartCode(scoped: false, library.build());
  }

  void _buildLibraryPrefix(StringBuffer buffer) => buffer.write(
    createDartCode(
      scoped: false,
      Library(
        (b) => b
          ..ignoreForFile.add('avoid_futureor_void')
          ..ignoreForFile.add('avoid_positional_boolean_parameters')
          ..ignoreForFile.add('cascade_invocations')
          ..ignoreForFile.add('cast_nullable_to_non_nullable')
          ..ignoreForFile.add('document_ignores')
          ..ignoreForFile.add('lines_longer_than_80_chars')
          ..ignoreForFile.add('no_literal_bool_comparisons')
          ..ignoreForFile.add('prefer_expression_function_bodies')
          ..ignoreForFile.add('unnecessary_parenthesis')
          ..ignoreForFile.add('unreachable_from_main')
          ..ignoreForFile.add('unused_element'),
      ),
    ),
  );

  void _buildLibrarySuffix(StringBuffer buffer) => buffer.write(
    createDartCode(
      scoped: false,
      Library(
        (b) => b
          ..body.addAll(SerializationMixin.buildGlobals())
          ..body.addAll(ParameterBuilderMixin.buildGlobals()),
      ),
    ),
  );
}
