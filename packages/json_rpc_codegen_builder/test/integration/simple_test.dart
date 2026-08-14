import 'package:json_rpc_codegen/json_rpc_codegen.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'models/simple.dart';

@GenerateNiceMocks([MockSpec<Simple>()])
import 'simple_test.mocks.dart';

class _TestSimpleServer extends SimpleServer {
  final mock = MockSimple();

  new(super.channel) : super();

  @override
  void notify(String message, [int level = 10]) => mock.notify(message, level);

  @override
  Future<double> request({
    required int id,
    Category? category,
    String user = 'self',
  }) => mock.request(id: id, category: category, user: user);
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

      verify(sutServer.mock.notify(testMessage));
    });
  });

  group('request', () {
    const testId = 1443;
    const testCategory = Category.catB;
    const testUser = 'test-user';
    const testResult = 4.22;

    test('sends request to server and returns the server result', () async {
      when(
        sutServer.mock.request(
          id: anyNamed('id'),
          category: anyNamed('category'),
          user: anyNamed('user'),
        ),
      ).thenReturnAsync(testResult);

      await expectLater(
        sutClient.request(id: testId, category: testCategory, user: testUser),
        completion(testResult),
      );

      verify(
        sutServer.mock.request(
          id: testId,
          category: testCategory,
          user: testUser,
        ),
      );
    });

    test('passes server defaults to callback', () async {
      when(
        sutServer.mock.request(
          id: anyNamed('id'),
          category: anyNamed('category'),
          user: anyNamed('user'),
        ),
      ).thenReturnAsync(testResult);

      await expectLater(sutClient.request(id: testId), completion(testResult));

      verify(sutServer.mock.request(id: testId));
    });
  });
}
