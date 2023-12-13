// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';

import 'package:json_rpc_codegen/json_rpc_codegen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:dart_test_tools/test.dart';

import 'models/common.dart';
import 'models/stream.dart';

class _MockStreamTestsServer extends Mock implements StreamServer {}

class _TestStreamServer extends StreamServer {
  final mock = _MockStreamTestsServer();

  _TestStreamServer(super.channel) : super();

  @override
  Stream<int> simple() => mock.simple();

  @override
  Stream<String> positional(
    String variant,
    User user,
    List<int> levels,
    Permission permission,
    Uri? reference,
    Color color,
  ) =>
      mock.positional(variant, user, levels, permission, reference, color);

  @override
  Stream<(User, Permission)> named(
    String variant,
    User user,
    List<int> levels,
    Permission permission,
    Uri? reference,
    Color color,
  ) =>
      mock.named(variant, user, levels, permission, reference, color);
}

void main() {
  setUpAll(() {
    registerFallbackValue(const User('', ''));
    registerFallbackValue(Permission.readOnly);
    registerFallbackValue(const Color(0, 0, 0));
  });

  late _TestStreamServer sutServer;
  late StreamClient sutClient;

  setUp(() async {
    final upstreamController = StreamController<String>.broadcast();
    addTearDown(upstreamController.close);
    upstreamController.stream.listen(printOnFailure);

    final downstreamController = StreamController<String>.broadcast();
    addTearDown(downstreamController.close);
    downstreamController.stream.listen(printOnFailure);

    final clientChannel = StreamChannel(
      downstreamController.stream,
      upstreamController.sink,
    );

    final serverChannel = StreamChannel(
      upstreamController.stream,
      downstreamController.sink,
    );

    // ignore: unawaited_futures
    sutServer = _TestStreamServer(serverChannel)..listen();
    addTearDown(sutServer.close);
    // ignore: unawaited_futures
    sutClient = StreamClient(clientChannel)..listen();
    addTearDown(sutClient.close);
  });

  group('stream', () {
    test('forwards a simple, single event', () async {
      const testValue = (
        User('a', 'b'),
        Permission.writeOnly,
      );
      when(() => sutServer.mock.named(any(), any(), any(), any(), any(), any()))
          .thenStream(Stream.value(testValue));

      await expectLater(
        sutClient.named(
          variant: 'variant',
          user: testValue.$1,
          permission: Permission.readWrite,
        ),
        emitsInOrder([
          isRecord(testValue.$1, testValue.$2),
          emitsDone,
        ]),
      );

      verify(
        () => sutServer.mock.named(
          'variant',
          testValue.$1,
          const [5, 75],
          Permission.readWrite,
          null,
          const Color(255, 255, 255),
        ),
      );
    });

    test('forwards all kinds of events', () async {
      final serverController = StreamController<int>();
      addTearDown(serverController.close);

      when(() => sutServer.mock.simple()).thenStream(serverController.stream);

      final sub = sutClient.simple().listen((event) {});
      await sub.cancel();
    });
  });
}
