import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

@isTest
void testCodeGeneration(
  String assetPrefix,
  dynamic Function(LibraryElement library) body, {
  required Builder builder,
  required String sourceContent,
}) =>
    test(
      '$builder generates correct code for $assetPrefix.dart',
      () async {
        final assetId = makeAssetId('a|$assetPrefix.json_rpc_codegen.g.part');
        final reader = await PackageAssetReader.currentIsolate();
        final writer = InMemoryAssetWriter();

        await testBuilder(
          builder,
          reader: reader,
          writer: writer,
          {
            'a|$assetPrefix.dart': sourceContent,
          },
        );

        expect(writer.assets, hasLength(1));
        final MapEntry(key: id, value: binaryContent) =
            writer.assets.entries.single;
        expect(id, assetId);
        final decodedContent = utf8.decode(binaryContent);

        printOnFailure(decodedContent);

        return resolveSource(
          inputId: assetId,
          decodedContent,
          (resolver) async {
            final library = await resolver.libraryFor(assetId);
            expect(library, isNotNull);
            return body(library);
          },
        );
      },
    );
