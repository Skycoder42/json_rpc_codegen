// ignore_for_file: unnecessary_lambdas

import 'package:dart_test_tools/test.dart';
import 'package:json_rpc_2/error_code.dart';
import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:json_rpc_codegen/src/base/peer_base.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockPeer extends Mock implements Peer {}

class MockParameters extends Mock implements Parameters {}

class _TestPeerBase extends PeerBase {
  _TestPeerBase(super.jsonRpcInstance) : super.fromPeer();
}

void main() {
  group('$PeerBase', () {
    final mockPeer = MockPeer();

    late PeerBase sut;

    setUp(() {
      reset(mockPeer);

      sut = _TestPeerBase(mockPeer);
    });

    tearDown(() {
      verifyNoMoreInteractions(mockPeer);
    });

    test('constructor calls registerMethods', () {
      // ignore: invalid_use_of_visible_for_overriding_member
      verify(() => mockPeer.registerFallback(sut.onUnknownMethod));
    });

    group('methods', () {
      setUp(() {
        clearInteractions(mockPeer);
      });

      test('onUnhandledError wraps peer.onUnhandledError', () async {
        void errorHandler(dynamic e, dynamic s) {}

        when(() => mockPeer.onUnhandledError).thenReturn(errorHandler);

        expect(sut.onUnhandledError, errorHandler);

        verify(() => mockPeer.onUnhandledError);
      });

      test('strictProtocolChecks wraps peer.strictProtocolChecks', () {
        when(() => mockPeer.strictProtocolChecks).thenReturn(true);

        expect(sut.strictProtocolChecks, isTrue);

        verify(() => mockPeer.strictProtocolChecks);
      });

      test('done wraps peer.done', () async {
        when(() => mockPeer.done).thenReturnAsync(null);

        await expectLater(sut.done, completes);

        verify(() => mockPeer.done);
      });

      test('isClosed wraps peer.isClosed', () {
        when(() => mockPeer.isClosed).thenReturn(true);

        expect(sut.isClosed, isTrue);

        verify(() => mockPeer.isClosed);
      });

      test('listen wraps peer.listen', () async {
        when(() => mockPeer.listen()).thenReturnAsync(null);

        await expectLater(sut.listen(), completes);

        verify(() => mockPeer.listen());
      });

      test('close wraps peer.close', () async {
        when(() => mockPeer.close()).thenReturnAsync(null);

        await expectLater(sut.close(), completes);

        verify(() => mockPeer.close());
      });

      test('withBatch wraps client.withBatch', () async {
        void callback() {}

        sut.withBatch(callback);

        verify(() => mockPeer.withBatch(callback));
      });

      test('onUnknownMethod throws by default', () {
        const testMethodName = 'test-method';
        final mockParameters = MockParameters();

        when(() => mockParameters.method).thenReturn(testMethodName);

        expect(
          // ignore: invalid_use_of_visible_for_overriding_member
          () async => sut.onUnknownMethod(mockParameters),
          throwsA(
            isA<RpcException>()
                .having((m) => m.code, 'code', METHOD_NOT_FOUND)
                .having((m) => m.message, 'message', contains(testMethodName)),
          ),
        );
      });

      test('registerMethods calls peer.registerFallback', () {
        // ignore: invalid_use_of_visible_for_overriding_member
        sut.registerMethods();

        // ignore: invalid_use_of_visible_for_overriding_member
        verify(() => mockPeer.registerFallback(sut.onUnknownMethod));
      });
    });
  });
}
