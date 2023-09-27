import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:json_rpc_codegen/json_rpc_codegen.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import 'generators/client/client_generator.dart';

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

    final emitter = DartEmitter(
      orderDirectives: true,
      useNullSafetySyntax: true,
    );
    return _buildLibrary(element).accept(emitter, StringBuffer()).toString();
  }

  Library _buildLibrary(ClassElement element) => Library(
        (b) => b..body.add(ClientGenerator(element)),
      );
}
