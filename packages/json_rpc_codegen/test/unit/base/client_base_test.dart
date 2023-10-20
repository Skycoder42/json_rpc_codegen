// ignore_for_file: unnecessary_lambdas

import 'package:dart_test_tools/test.dart';
import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:json_rpc_codegen/src/base/client_base.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockClient extends Mock implements Client {}

class _TestClientBase extends ClientBase {
  _TestClientBase(super.jsonRpcInstance) : super.fromClient();
}

void main() {
  group('$ClientBase', () {
    final mockClient = MockClient();

    late ClientBase sut;

    setUp(() {
      reset(mockClient);

      sut = _TestClientBase(mockClient);
    });

    tearDown(() {
      verifyNoMoreInteractions(mockClient);
    });

    test('done wraps client.done', () async {
      when(() => mockClient.done).thenReturnAsync(null);

      await expectLater(sut.done, completes);

      verify(() => mockClient.done);
    });

    test('isClosed wraps client.isClosed', () {
      when(() => mockClient.isClosed).thenReturn(true);

      expect(sut.isClosed, isTrue);

      verify(() => mockClient.isClosed);
    });

    test('listen wraps client.listen', () async {
      when(() => mockClient.listen()).thenReturnAsync(null);

      await expectLater(sut.listen(), completes);

      verify(() => mockClient.listen());
    });

    test('close wraps client.close', () async {
      when(() => mockClient.close()).thenReturnAsync(null);

      await expectLater(sut.close(), completes);

      verify(() => mockClient.close());
    });

    test('withBatch wraps client.withBatch', () async {
      void callback() {}

      sut.withBatch(callback);

      verify(() => mockClient.withBatch(callback));
    });
  });
}
