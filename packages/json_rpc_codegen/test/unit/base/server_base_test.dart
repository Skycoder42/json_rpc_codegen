// ignore_for_file: unnecessary_lambdas

import 'package:dart_test_tools/test.dart';
import 'package:json_rpc_2/error_code.dart';
import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:json_rpc_codegen/src/base/server_base.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockServer extends Mock implements Server {}

class MockParameters extends Mock implements Parameters {}

class _TestServerBase extends ServerBase {
  _TestServerBase(super.jsonRpcInstance) : super.fromServer();
}

void main() {
  group('$ServerBase', () {
    final mockServer = MockServer();

    late ServerBase sut;

    setUp(() {
      reset(mockServer);

      sut = _TestServerBase(mockServer);
    });

    tearDown(() {
      verifyNoMoreInteractions(mockServer);
    });

    test('constructor calls registerMethods', () {
      // ignore: invalid_use_of_visible_for_overriding_member
      verify(() => mockServer.registerFallback(sut.onUnknownMethod));
    });

    group('methods', () {
      setUp(() {
        clearInteractions(mockServer);
      });

      test('onUnhandledError wraps server.onUnhandledError', () async {
        void errorHandler(dynamic e, dynamic s) {}

        when(() => mockServer.onUnhandledError).thenReturn(errorHandler);

        expect(sut.onUnhandledError, errorHandler);

        verify(() => mockServer.onUnhandledError);
      });

      test('strictProtocolChecks wraps server.strictProtocolChecks', () {
        when(() => mockServer.strictProtocolChecks).thenReturn(true);

        expect(sut.strictProtocolChecks, isTrue);

        verify(() => mockServer.strictProtocolChecks);
      });

      test('done wraps server.done', () async {
        when(() => mockServer.done).thenReturnAsync(null);

        await expectLater(sut.done, completes);

        verify(() => mockServer.done);
      });

      test('isClosed wraps server.isClosed', () {
        when(() => mockServer.isClosed).thenReturn(true);

        expect(sut.isClosed, isTrue);

        verify(() => mockServer.isClosed);
      });

      test('listen wraps server.listen', () async {
        when(() => mockServer.listen()).thenReturnAsync(null);

        await expectLater(sut.listen(), completes);

        verify(() => mockServer.listen());
      });

      test('close wraps server.close', () async {
        when(() => mockServer.close()).thenReturnAsync(null);

        await expectLater(sut.close(), completes);

        verify(() => mockServer.close());
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

      test('registerMethods calls server.registerFallback', () {
        // ignore: invalid_use_of_visible_for_overriding_member
        sut.registerMethods();

        // ignore: invalid_use_of_visible_for_overriding_member
        verify(() => mockServer.registerFallback(sut.onUnknownMethod));
      });
    });
  });
}
