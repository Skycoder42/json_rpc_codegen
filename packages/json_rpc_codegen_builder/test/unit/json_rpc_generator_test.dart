import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
// ignore: no_self_package_imports
import 'package:json_rpc_codegen_builder/json_rpc_codegen_builder.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  testCodeGeneration(
    'lib/empty',
    builder: jsonRpcCodegenBuilder(BuilderOptions.empty),
    sourceContent: '''
import 'package:json_rpc_codegen/json_rpc_codegen.dart';

@jsonRpc
abstract class _TestEmpty {}
''',
    (library) async {
      expect(
        library.topLevelElements,
        contains(
          isA<MixinElement>()
              .having((m) => m.name, 'name', 'TestEmptyClientMixin')
              .having((m) => m.methods, 'methods', isEmpty)
              .having((m) => m.fields, 'fields', isEmpty),
        ),
      );
      expect(
        library.topLevelElements,
        contains(
          isA<MixinElement>()
              .having((m) => m.name, 'name', 'TestEmptyServerMixin')
              .having(
                (m) => m.methods,
                'methods',
                allOf(
                  hasLength(1),
                  contains(
                    isA<MethodElement>()
                        .having((m) => m.name, 'name', 'registerMethods'),
                  ),
                ),
              )
              .having((m) => m.fields, 'fields', isEmpty),
        ),
      );
      expect(
        library.topLevelElements,
        contains(
          isA<ClassElement>()
              .having((m) => m.name, 'name', 'TestEmptyClient')
              .having((m) => m.methods, 'methods', isEmpty)
              .having((m) => m.fields, 'fields', isEmpty),
        ),
      );
      expect(
        library.topLevelElements,
        contains(
          isA<ClassElement>()
              .having((m) => m.name, 'name', 'TestEmptyServer')
              .having((m) => m.methods, 'methods', isEmpty)
              .having((m) => m.fields, 'fields', isEmpty),
        ),
      );
    },
  );
}
