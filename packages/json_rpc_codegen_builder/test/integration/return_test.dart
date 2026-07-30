import 'package:json_rpc_codegen/json_rpc_codegen.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'matchers.dart';
import 'models/common.dart';
import 'models/return_tests.dart';

@GenerateNiceMocks([MockSpec<ReturnTests>()])
import 'return_test.mocks.dart';

typedef PosRecord = (int?, Permission, Iterable<User?>, ({int x, int y}));

typedef NamedRecord = ({
  Color c,
  Map<String, String?>? d,
  (int, int) p,
  double r,
});

class ReturnTestsClient extends ClientBase with ReturnTestsClientMixin {
  ReturnTestsClient(super.channel) : super();
}

abstract class ReturnTestsServer extends ServerBase
    with ReturnTestsServerMixin {
  ReturnTestsServer(super.channel) : super();
}

class _TestReturnTestsServer extends ReturnTestsServer {
  final mock = MockReturnTests();

  _TestReturnTestsServer(super.channel) : super();

  @override
  Future<bool> boolRet() => mock.boolRet();

  @override
  Future<num?> numRet() => mock.numRet();

  @override
  Future<int> intRet() => mock.intRet();

  @override
  Future<double?> doubleRet() => mock.doubleRet();

  @override
  Future<String> stringRet() => mock.stringRet();

  @override
  Future<DateTime> dateTimeRet() => mock.dateTimeRet();

  @override
  Future<Uri> uriRet() => mock.uriRet();

  @override
  Future<dynamic> dynamicRet() => mock.dynamicRet();

  @override
  Future<List<int>> listRet() => mock.listRet();

  @override
  Future<Iterable<bool>> iterableRet() => mock.iterableRet();

  @override
  Future<Set<String>> setRet() => mock.setRet();

  @override
  Future<Map<String, double>> mapRet() => mock.mapRet();

  @override
  Future<Map<String, Iterable<Map<dynamic, List<num>>>>> deepRet() =>
      mock.deepRet();

  @override
  Future<User> userRet() => mock.userRet();

  @override
  Future<Color?> colorRet() => mock.colorRet();

  @override
  Future<Permission> permissionRet() => mock.permissionRet();

  @override
  Future<Iterable<User>> usersRet() => mock.usersRet();

  @override
  Future<Map<dynamic, List<Permission>>> colorPermissionsRet() =>
      mock.colorPermissionsRet();

  @override
  Future<PosRecord> posRecordRet() => mock.posRecordRet();

  @override
  Future<NamedRecord> namedRecordRet() => mock.namedRecordRet();
}

void main() {
  late _TestReturnTestsServer sutServer;
  late ReturnTestsClient sutClient;

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
    sutServer = _TestReturnTestsServer(serverChannel)..listen();
    addTearDown(sutServer.close);
    // ignore: discarded_futures for setup
    sutClient = ReturnTestsClient(clientChannel)..listen();
    addTearDown(sutClient.close);
  });

  group('boolRet', () {
    test('returns the value returned by the server', () async {
      when(sutServer.mock.boolRet()).thenReturnAsync(true);

      await expectLater(sutClient.boolRet(), completion(isTrue));

      verify(sutServer.mock.boolRet());
    });
  });

  group('numRet', () {
    test('returns the value returned by the server', () async {
      when(sutServer.mock.numRet()).thenReturnAsync(12.5);

      await expectLater(sutClient.numRet(), completion(12.5));

      verify(sutServer.mock.numRet());
    });

    test('returns null if the server returns null', () async {
      when(sutServer.mock.numRet()).thenReturnAsync(null);

      await expectLater(sutClient.numRet(), completion(isNull));

      verify(sutServer.mock.numRet());
    });
  });

  group('intRet', () {
    test('returns the value returned by the server', () async {
      when(sutServer.mock.intRet()).thenReturnAsync(42);

      await expectLater(sutClient.intRet(), completion(42));

      verify(sutServer.mock.intRet());
    });
  });

  group('doubleRet', () {
    test('returns the value returned by the server', () async {
      when(sutServer.mock.doubleRet()).thenReturnAsync(4.75);

      await expectLater(sutClient.doubleRet(), completion(4.75));

      verify(sutServer.mock.doubleRet());
    });

    test('returns null if the server returns null', () async {
      when(sutServer.mock.doubleRet()).thenReturnAsync(null);

      await expectLater(sutClient.doubleRet(), completion(isNull));

      verify(sutServer.mock.doubleRet());
    });
  });

  group('stringRet', () {
    test('returns the value returned by the server', () async {
      when(sutServer.mock.stringRet()).thenReturnAsync('test-string');

      await expectLater(sutClient.stringRet(), completion('test-string'));

      verify(sutServer.mock.stringRet());
    });
  });

  group('dateTimeRet', () {
    final testDateTime = DateTime.utc(2026, 7, 30, 12, 34, 56, 789);

    test('returns the value returned by the server', () async {
      when(sutServer.mock.dateTimeRet()).thenReturnAsync(testDateTime);

      await expectLater(sutClient.dateTimeRet(), completion(testDateTime));

      verify(sutServer.mock.dateTimeRet());
    });
  });

  group('uriRet', () {
    final testUri = Uri.https('example.com', '/path', {'query': '1'});

    test('returns the value returned by the server', () async {
      when(sutServer.mock.uriRet()).thenReturnAsync(testUri);

      await expectLater(sutClient.uriRet(), completion(testUri));

      verify(sutServer.mock.uriRet());
    });
  });

  group('dynamicRet', () {
    const testDynamic = {
      'key': 'value',
      'nested': [1, 2.5, true, null],
    };

    test('returns the value returned by the server', () async {
      when(sutServer.mock.dynamicRet()).thenReturnAsync(testDynamic);

      await expectLater(sutClient.dynamicRet(), completion(testDynamic));

      verify(sutServer.mock.dynamicRet());
    });
  });

  group('listRet', () {
    const testList = [1, 2, 3];

    test('returns the value returned by the server', () async {
      when(sutServer.mock.listRet()).thenReturnAsync(testList);

      await expectLater(sutClient.listRet(), completion(testList));

      verify(sutServer.mock.listRet());
    });
  });

  group('iterableRet', () {
    const testIterable = [true, false, true];

    test('returns the value returned by the server', () async {
      when(sutServer.mock.iterableRet()).thenReturnAsync(testIterable);

      await expectLater(sutClient.iterableRet(), completion(testIterable));

      verify(sutServer.mock.iterableRet());
    });
  });

  group('setRet', () {
    const testSet = {'value-a', 'value-b'};

    test('returns the value returned by the server', () async {
      when(sutServer.mock.setRet()).thenReturnAsync(testSet);

      await expectLater(sutClient.setRet(), completion(testSet));

      verify(sutServer.mock.setRet());
    });
  });

  group('mapRet', () {
    const testMap = {'key-a': 1.5, 'key-b': 2.25};

    test('returns the value returned by the server', () async {
      when(sutServer.mock.mapRet()).thenReturnAsync(testMap);

      await expectLater(sutClient.mapRet(), completion(testMap));

      verify(sutServer.mock.mapRet());
    });
  });

  group('deepRet', () {
    const testDeep = <String, List<Map<dynamic, List<num>>>>{
      'deep-a': [
        {
          'deep-c': [1, 2.5],
        },
      ],
    };

    test('returns the value returned by the server', () async {
      when(sutServer.mock.deepRet()).thenReturnAsync(testDeep);

      await expectLater(sutClient.deepRet(), completion(testDeep));

      verify(sutServer.mock.deepRet());
    });
  });

  group('userRet', () {
    const testUser = User('user-first', 'user-last');

    test('returns the value returned by the server', () async {
      when(sutServer.mock.userRet()).thenReturnAsync(testUser);

      await expectLater(sutClient.userRet(), completion(testUser));

      verify(sutServer.mock.userRet());
    });
  });

  group('colorRet', () {
    const testColor = Color(11, 22, 33);

    test('returns the value returned by the server', () async {
      when(sutServer.mock.colorRet()).thenReturnAsync(testColor);

      await expectLater(
        sutClient.colorRet(),
        completion(deepEquals(testColor)),
      );

      verify(sutServer.mock.colorRet());
    });

    test('returns null if the server returns null', () async {
      when(sutServer.mock.colorRet()).thenReturnAsync(null);

      await expectLater(sutClient.colorRet(), completion(isNull));

      verify(sutServer.mock.colorRet());
    });
  });

  group('permissionRet', () {
    test('returns the value returned by the server', () async {
      when(
        sutServer.mock.permissionRet(),
      ).thenReturnAsync(Permission.writeOnly);

      await expectLater(
        sutClient.permissionRet(),
        completion(Permission.writeOnly),
      );

      verify(sutServer.mock.permissionRet());
    });
  });

  group('usersRet', () {
    const testUsers = [
      User('users-first', 'users-last'),
      User('users-first-2', 'users-last-2'),
    ];

    test('returns the value returned by the server', () async {
      when(sutServer.mock.usersRet()).thenReturnAsync(testUsers);

      await expectLater(sutClient.usersRet(), completion(testUsers));

      verify(sutServer.mock.usersRet());
    });
  });

  group('colorPermissionsRet', () {
    const testColorPermissions = <dynamic, List<Permission>>{
      'gray': [Permission.readOnly, Permission.writeOnly],
      'black': [Permission.readWrite],
    };

    test('returns the value returned by the server', () async {
      when(
        sutServer.mock.colorPermissionsRet(),
      ).thenReturnAsync(testColorPermissions);

      await expectLater(
        sutClient.colorPermissionsRet(),
        completion(testColorPermissions),
      );

      verify(sutServer.mock.colorPermissionsRet());
    });
  });

  group('posRecordRet', () {
    const PosRecord testRecord = (
      42,
      Permission.writeOnly,
      [User('record-first', 'record-last'), null],
      (x: 11, y: 22),
    );

    test('returns the value returned by the server', () async {
      when(sutServer.mock.posRecordRet()).thenReturnAsync(testRecord);

      final result = await sutClient.posRecordRet();

      // records compare their fields via Object.==, which does not work for
      // the collections within them - assert on the fields instead
      expect(result.$1, testRecord.$1);
      expect(result.$2, testRecord.$2);
      expect(result.$3, testRecord.$3);
      expect(result.$4, testRecord.$4);

      verify(sutServer.mock.posRecordRet());
    });
  });

  group('namedRecordRet', () {
    const NamedRecord testRecord = (
      c: Color(44, 55, 66),
      d: {'key-a': 'value-a', 'key-b': null},
      p: (33, 44),
      r: 7.5,
    );

    test('returns the value returned by the server', () async {
      when(sutServer.mock.namedRecordRet()).thenReturnAsync(testRecord);

      final result = await sutClient.namedRecordRet();

      // records compare their fields via Object.==, which does not work for
      // the collections and colors within them - assert on the fields instead
      expect(result.c, deepEquals(testRecord.c));
      expect(result.d, testRecord.d);
      expect(result.p, testRecord.p);
      expect(result.r, testRecord.r);

      verify(sutServer.mock.namedRecordRet());
    });

    const NamedRecord testNullRecord = (
      c: Color(0, 0, 0),
      d: null,
      p: (1, 2),
      r: 0.5,
    );

    test('returns null for the nullable field', () async {
      when(sutServer.mock.namedRecordRet()).thenReturnAsync(testNullRecord);

      final result = await sutClient.namedRecordRet();

      expect(result.d, isNull);

      verify(sutServer.mock.namedRecordRet());
    });
  });
}
