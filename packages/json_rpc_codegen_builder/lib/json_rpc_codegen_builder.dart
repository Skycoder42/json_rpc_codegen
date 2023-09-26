import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/json_rpc_generator.dart';

/// The [JsonRpcGenerator] builder
Builder jsonRpcCodegenBuilder(BuilderOptions options) => SharedPartBuilder(
      [JsonRpcGenerator(options)],
      'json_rpc_codegen',
    );
