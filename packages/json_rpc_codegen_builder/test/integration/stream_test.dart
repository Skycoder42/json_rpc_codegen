// ignore_for_file: invalid_use_of_protected_member, unnecessary_lambdas

import 'dart:async';

import 'package:dart_test_tools/test.dart';
import 'package:json_rpc_2/error_code.dart' as error_code;
import 'package:json_rpc_codegen/json_rpc_codegen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'models/common.dart';
import 'models/stream.dart';

abstract interface class Callable0<TReturn> {
  TReturn call();
}

abstract interface class Callable1<TReturn, TArg1> {
  TReturn call(TArg1 arg1);
}

class MockCallable0<TReturn> extends Mock implements Callable0<TReturn> {}

class MockCallable1<TReturn, TArg1> extends Mock
    implements Callable1<TReturn, TArg1> {}

class MockStreamTestsServer extends Mock implements StreamServer {}

class TestStreamServer extends StreamServer {
  final mock = MockStreamTestsServer();

  TestStreamServer(super.channel) : super();

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
    registerFallbackValue(StackTrace.empty);
  });

  late TestStreamServer sutServer;
  late StreamClient sutClient;

  setUp(() async {
    final upstreamController = StreamController<String>.broadcast();
    addTearDown(upstreamController.close);
    upstreamController.stream.listen((e) => printOnFailure('>>> $e'));

    final downstreamController = StreamController<String>.broadcast();
    addTearDown(downstreamController.close);
    downstreamController.stream.listen((e) => printOnFailure('<<< $e'));

    final clientChannel = StreamChannel(
      downstreamController.stream,
      upstreamController.sink,
    );

    final serverChannel = StreamChannel(
      upstreamController.stream,
      downstreamController.sink,
    );

    // ignore: unawaited_futures
    sutServer = TestStreamServer(serverChannel)..listen();
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

    group('complex', () {
      final mockOnListen = MockCallable0();
      final mockOnCancel = MockCallable0<Future>();
      final mockOnPause = MockCallable0();
      final mockOnResume = MockCallable0();

      late StreamController<int> serverController;

      setUp(() async {
        reset(mockOnListen);
        reset(mockOnCancel);
        reset(mockOnPause);
        reset(mockOnResume);

        when(() => mockOnCancel.call()).thenReturnAsync(null);

        serverController = StreamController<int>(
          onListen: mockOnListen.call,
          onCancel: mockOnCancel.call,
          onPause: mockOnPause.call,
          onResume: mockOnResume.call,
        );
        addTearDown(serverController.close);

        when(() => sutServer.mock.simple()).thenStream(serverController.stream);
      });

      void verifyAllClean([Iterable<Mock> mocks = const []]) {
        verifyNoMoreInteractions(mockOnListen);
        verifyNoMoreInteractions(mockOnCancel);
        verifyNoMoreInteractions(mockOnPause);
        verifyNoMoreInteractions(mockOnResume);
        mocks.forEach(verifyNoMoreInteractions);
      }

      test('calls listen on the server when listened to', () async {
        final sub = sutClient.simple().listen((_) {});
        addTearDown(sub.cancel);

        await Future.delayed(const Duration(milliseconds: 1));

        verify(() => mockOnListen.call()).called(1);
        verifyAllClean();
      });

      test('forwards data events', () async {
        expect(
          sutClient.simple(),
          emitsInOrder([42, 99, emitsDone]),
        );

        serverController
          ..add(42)
          ..add(99);
        expect(serverController.close(), completes);
      });

      testData<(Object, StackTrace?, Matcher)>(
        'forwards error events',
        [
          (
            Exception('error1'),
            null,
            isA<RpcException>()
                .having((m) => m.code, 'code', error_code.SERVER_ERROR)
                .having((m) => m.message, 'message', 'error1')
                .having((m) => m.data, 'data', {
              'full': 'Exception: error1',
              'stack': isEmpty,
              'request': startsWith('simple#'),
            })
          ),
          (
            Exception('error2'),
            StackTrace.current,
            isA<RpcException>()
                .having((m) => m.code, 'code', error_code.SERVER_ERROR)
                .having((m) => m.message, 'message', 'error2')
                .having((m) => m.data, 'data', {
              'full': 'Exception: error2',
              'stack': isNotEmpty,
              'request': startsWith('simple#'),
            }),
          ),
          (
            RpcException(123, 'error3'),
            null,
            isA<RpcException>()
                .having((m) => m.code, 'code', 123)
                .having((m) => m.message, 'message', 'error3')
                .having((m) => m.data, 'data', {
              'request': startsWith('simple#'),
            }),
          ),
          (
            RpcException(123, 'error4', data: 'extra'),
            null,
            isA<RpcException>()
                .having((m) => m.code, 'code', 123)
                .having((m) => m.message, 'message', 'error4')
                .having((m) => m.data, 'data', 'extra'),
          ),
        ],
        dataToString: (fixture) => fixture.$1.toString(),
        (fixture) async {
          expect(
            sutClient.simple(),
            emitsInOrder([emitsError(fixture.$3), emitsDone]),
          );

          serverController.addError(fixture.$1, fixture.$2);
          expect(serverController.close(), completes);
        },
      );

      test('can be paused, resumed and canceled', () async {
        final mockOnData = MockCallable1();
        final sub = sutClient.simple().listen(mockOnData.call);
        addTearDown(sub.cancel);

        serverController.add(1);
        await Future.delayed(const Duration(milliseconds: 1));

        verifyInOrder([
          () => mockOnListen.call(),
          () => mockOnData.call(1),
        ]);
        verifyAllClean([mockOnData]);

        sub.pause();
        await Future.delayed(const Duration(milliseconds: 1));
        serverController.add(2);
        await Future.delayed(const Duration(milliseconds: 1));

        verifyInOrder([
          () => mockOnPause.call(),
        ]);
        verifyAllClean([mockOnData]);

        sub.resume();
        await Future.delayed(const Duration(milliseconds: 1));
        serverController.add(3);
        await Future.delayed(const Duration(milliseconds: 1));

        verifyInOrder([
          () => mockOnResume.call(),
          () => mockOnData.call(2),
          () => mockOnData.call(3),
        ]);
        verifyAllClean([mockOnData]);

        await sub.cancel();
        serverController.add(4);
        await Future.delayed(const Duration(milliseconds: 1));

        verifyInOrder([
          () => mockOnCancel.call(),
        ]);
        verifyAllClean([mockOnData]);
      });
    });
  });
}
