// ignore_for_file: avoid_futureor_void for tests

import 'package:json_rpc_codegen/json_rpc_codegen.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'models/simple.dart';

@GenerateNiceMocks([MockSpec<SimpleServer>()])
import 'simple_test.mocks.dart';

class _TestSimpleServer extends SimpleServer {
  final mock = MockSimpleServer();

  _TestSimpleServer(super.channel) : super();

  @override
  FutureOr<void> notify(String message, int level) =>
      mock.notify(message, level);

  @override
  FutureOr<double> request(int id, Category? category, String user) =>
      mock.request(id, category, user);
}

void main() {
  late _TestSimpleServer sutServer;
  late SimpleClient sutClient;

  setUp(() {
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

    // ignore: discarded_futures for setup
    sutServer = _TestSimpleServer(serverChannel)..listen();
    addTearDown(sutServer.close);
    // ignore: discarded_futures for setup
    sutClient = SimpleClient(clientChannel)..listen();
    addTearDown(sutClient.close);
  });

  group('notify', () {
    const testMessage = 'test-message';
    const testLevel = 42;

    test('sends message and level', () async {
      sutClient.notify(testMessage, testLevel);

      await pumpEventQueue();

      verify(sutServer.mock.notify(testMessage, testLevel));
    });

    test('sends client defaults', () async {
      sutClient.notify(testMessage);

      await pumpEventQueue();

      verify(sutServer.mock.notify(testMessage, 10));
    });
  });

  group('request', () {
    const testId = 1443;
    const testCategory = Category.catB;
    const testUser = 'test-user';
    const testResult = 4.22;

    test('sends request to server and returns the server result', () async {
      when(sutServer.mock.request(any, any, any)).thenReturn(testResult);

      await expectLater(
        sutClient.request(id: testId, category: testCategory, user: testUser),
        completion(testResult),
      );

      verify(sutServer.mock.request(testId, testCategory, testUser));
    });

    test('passes server defaults to callback', () async {
      when(sutServer.mock.request(any, any, any)).thenReturn(testResult);

      await expectLater(sutClient.request(id: testId), completion(testResult));

      verify(sutServer.mock.request(testId, null, 'self'));
    });
  });
}
