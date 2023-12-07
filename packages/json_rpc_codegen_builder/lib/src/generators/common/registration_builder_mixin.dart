import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../proxy_spec.dart';
import 'annotations.dart';
import 'types.dart';

@internal
base mixin RegistrationBuilderMixin on ProxySpec {
  Method buildRegisterMethods(Iterable<Code> methods) => Method(
        (b) => b
          ..name = 'registerMethods'
          ..returns = Types.$void
          ..annotations.add(Annotations.override)
          ..annotations.add(Annotations.visibleForOverriding)
          ..annotations.add(Annotations.mustCallSuper)
          ..body = Block.of([
            refer('super').property('registerMethods').call(const []).statement,
            ...methods,
          ]),
      );
}
