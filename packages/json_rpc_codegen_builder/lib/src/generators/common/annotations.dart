import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

@internal
abstract base class Annotations {
  Annotations._();

  static const override = Reference('override');

  static const visibleForOverriding = Reference('visibleForOverriding');

  static const mustCallSuper = Reference('mustCallSuper');

  static const pragmaVmPreferInline = Reference("pragma('vm:prefer-inline')");
  static const pragmaDart2jsTryInline = Reference(
    "pragma('dart2js:tryInline')",
  );
  static const pragmaWasmPreferInline = Reference(
    "pragma('wasm:prefer-inline')",
  );

  static const alwaysInline = [
    pragmaVmPreferInline,
    pragmaDart2jsTryInline,
    pragmaWasmPreferInline,
  ];
}
