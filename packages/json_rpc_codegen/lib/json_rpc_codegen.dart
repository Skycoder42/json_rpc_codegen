import 'package:json_rpc_2/error_code.dart';
// ignore: implementation_imports
import 'package:json_rpc_2/src/utils.dart' show getErrorMessage;

export 'dart:async'
    show FutureOr, StreamController, StreamSubscription, unawaited;

export 'package:json_rpc_2/json_rpc_2.dart';
export 'package:meta/meta.dart'
    show mustCallSuper, protected, visibleForOverriding;
export 'package:stack_trace/stack_trace.dart' show Chain;
export 'package:stream_channel/stream_channel.dart' show StreamChannel;

export 'src/annotations/defaults.dart';
export 'src/annotations/json_rpc.dart';
export 'src/base/client_base.dart';
export 'src/base/peer_base.dart';
export 'src/base/server_base.dart';

/// @nodoc
const jsonRpc2ServerError = SERVER_ERROR;

/// @nodoc
const jsonRpc2GetErrorMessage = getErrorMessage;
