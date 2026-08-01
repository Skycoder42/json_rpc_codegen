// the default values are passed and verified explicitly on purpose

import 'dart:convert';

import 'package:json_rpc_codegen/json_rpc_codegen.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'matchers.dart';
import 'models/common.dart';
import 'models/parameter_tests.dart';

@GenerateNiceMocks([MockSpec<ParameterTests>()])
import 'parameter_test.mocks.dart';

typedef PositionalRecord = (
  (int, int),
  String,
  Color?,
  User,
  List<Permission>?,
);

typedef NamedRecord = ({
  Color color,
  String name,
  Iterable<Permission?> permissions,
  ({int x, int y}) point,
  User? user,
});

class ParameterTestsClient extends ClientBase with ParameterTestsClientMixin {
  ParameterTestsClient(super.channel) : super();
}

abstract class ParameterTestsServer extends ServerBase
    with ParameterTestsServerMixin {
  ParameterTestsServer(super.channel) : super();
}

class _TestParameterTestsServer extends ParameterTestsServer {
  final mock = MockParameterTests();

  _TestParameterTestsServer(super.channel) : super();

  @override
  Future<void> simplePositionalServer(
    bool a,
    num? b, [
    int c = 42,
    double? d,
    String? e = 'default',
  ]) => mock.simplePositionalServer(a, b, c, d, e);

  @override
  Future<void> simpleNamedServer({
    required bool a,
    required num? b,
    int c = 42,
    double? d,
    String? e = 'default',
  }) => mock.simpleNamedServer(a: a, b: b, c: c, d: d, e: e);

  @override
  Future<void> simplePositionalClient(
    bool a,
    num? b, [
    int c = 42,
    double? d,
    String? e = 'default',
  ]) => mock.simplePositionalClient(a, b, c, d, e);

  @override
  Future<void> simpleNamedClient({
    required bool a,
    required num? b,
    int c = 42,
    double? d,
    String? e = 'default',
  }) => mock.simpleNamedClient(a: a, b: b, c: c, d: d, e: e);

  @override
  Future<void> simpleSpecials({
    Uri? url,
    Permission permission = .readOnly,
    DateTime? dateTime,
  }) =>
      mock.simpleSpecials(url: url, permission: permission, dateTime: dateTime);

  @override
  Future<void> containers(
    Iterable<String> names,
    List<int> bytes,
    Map<String, bool> features,
    Map<String, Iterable<Map<dynamic, List<num>>>> deep,
  ) => mock.containers(names, bytes, features, deep);

  @override
  Future<void> custom(
    User user, [
    Color color = const Color(255, 255, 255),
    Permission permission = Permission.readOnly,
  ]) => mock.custom(user, color, permission);

  @override
  Future<void> dotShorthands(
    User user, [
    Color color = const .new(255, 255, 255),
    Permission permission = .readOnly,
  ]) => mock.dotShorthands(user, color, permission);

  @override
  Future<void> customContainers({
    required Iterable<User> users,
    Map<String, List<Permission>> colorPermissions = const {
      'black': [Permission.readWrite],
    },
    List<Set<User?>?>? nullables,
    Map<Object, bool?>? optionalsNullable = const {
      'readOnly': true,
      'readWrite': null,
    },
  }) => mock.customContainers(
    users: users,
    colorPermissions: colorPermissions,
    nullables: nullables,
    optionalsNullable: optionalsNullable,
  );

  @override
  Future<void> records(
    () empty,
    PositionalRecord positional,
    NamedRecord named,
  ) => mock.records(empty, positional, named);

  @override
  Future<void> renamed({required bool a, int b = 42, String? c}) =>
      mock.renamed(a: a, b: b, c: c);

  @override
  Future<void> customNamed({
    required Color color,
    Permission permission = .readOnly,
    Color? optional,
  }) => mock.customNamed(
    color: color,
    permission: permission,
    optional: optional,
  );

  @override
  Future<void> customPositional(
    Color color, [
    Permission permission = .readWrite,
  ]) => mock.customPositional(color, permission);

  @override
  Future<void> customPrimitive(double value, [double? optional]) =>
      mock.customPrimitive(value, optional);
}

void main() {
  late _TestParameterTestsServer sutServer;
  late ParameterTestsClient sutClient;
  late List<String> sentFrames;

  setUp(() {
    sentFrames = [];

    final upstreamController = StreamController<String>.broadcast();
    addTearDown(upstreamController.close);
    upstreamController.stream.listen((frame) {
      printOnFailure(frame);
      sentFrames.add(frame);
    });

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
    sutServer = _TestParameterTestsServer(serverChannel)..listen();
    addTearDown(sutServer.close);
    // ignore: discarded_futures for setup
    sutClient = ParameterTestsClient(clientChannel)..listen();
    addTearDown(sutClient.close);
  });

  group('simplePositionalServer', () {
    test('sends minimal parameters', () async {
      await sutClient.simplePositionalServer(true, 12.5);

      verify(sutServer.mock.simplePositionalServer(true, 12.5));
    });

    test('sends all parameters', () async {
      await sutClient.simplePositionalServer(false, 24, 13, 4.75, 'custom');

      verify(
        sutServer.mock.simplePositionalServer(false, 24, 13, 4.75, 'custom'),
      );
    });

    test('sends last optional parameter', () async {
      await sutClient.simplePositionalServer(true, 12.5, 42, null, 'last');

      verify(
        sutServer.mock.simplePositionalServer(true, 12.5, 42, null, 'last'),
      );
    });
  });

  group('simpleNamedServer', () {
    test('sends minimal parameters', () async {
      await sutClient.simpleNamedServer(a: true, b: 12.5);

      verify(sutServer.mock.simpleNamedServer(a: true, b: 12.5));
    });

    test('sends all parameters', () async {
      await sutClient.simpleNamedServer(
        a: false,
        b: 24,
        c: 13,
        d: 4.75,
        e: 'custom',
      );

      verify(
        sutServer.mock.simpleNamedServer(
          a: false,
          b: 24,
          c: 13,
          d: 4.75,
          e: 'custom',
        ),
      );
    });

    test('sends last optional parameter', () async {
      await sutClient.simpleNamedServer(a: true, b: 12.5, e: 'last');

      verify(sutServer.mock.simpleNamedServer(a: true, b: 12.5, e: 'last'));
    });
  });

  group('simplePositionalClient', () {
    test('sends minimal parameters', () async {
      await sutClient.simplePositionalClient(true, 12.5);

      verify(sutServer.mock.simplePositionalClient(true, 12.5));
    });

    test('sends all parameters', () async {
      await sutClient.simplePositionalClient(false, 24, 13, 4.75, 'custom');

      verify(
        sutServer.mock.simplePositionalClient(false, 24, 13, 4.75, 'custom'),
      );
    });

    test('sends last optional parameter', () async {
      await sutClient.simplePositionalClient(true, 12.5, 42, null, 'last');

      verify(
        sutServer.mock.simplePositionalClient(true, 12.5, 42, null, 'last'),
      );
    });
  });

  group('simpleNamedClient', () {
    test('sends minimal parameters', () async {
      await sutClient.simpleNamedClient(a: true, b: 12.5);

      verify(sutServer.mock.simpleNamedClient(a: true, b: 12.5));
    });

    test('sends all parameters', () async {
      await sutClient.simpleNamedClient(
        a: false,
        b: 24,
        c: 13,
        d: 4.75,
        e: 'custom',
      );

      verify(
        sutServer.mock.simpleNamedClient(
          a: false,
          b: 24,
          c: 13,
          d: 4.75,
          e: 'custom',
        ),
      );
    });

    test('sends last optional parameter', () async {
      await sutClient.simpleNamedClient(a: true, b: 12.5, e: 'last');

      verify(sutServer.mock.simpleNamedClient(a: true, b: 12.5, e: 'last'));
    });
  });

  group('simpleSpecials', () {
    test('sends minimal parameters', () async {
      await sutClient.simpleSpecials();

      verify(sutServer.mock.simpleSpecials());
    });

    test('sends all parameters', () async {
      await sutClient.simpleSpecials(
        url: Uri.parse('https://example.com'),
        permission: .writeOnly,
        dateTime: DateTime(2024),
      );

      verify(
        sutServer.mock.simpleSpecials(
          url: Uri.parse('https://example.com'),
          permission: .writeOnly,
          dateTime: DateTime(2024),
        ),
      );
    });
  });

  group('containers', () {
    const testNames = ['name-a', 'name-b'];
    const testBytes = [1, 2, 3];
    const testFeatures = {'feature-a': true, 'feature-b': false};
    const testDeep = <String, List<Map<dynamic, List<num>>>>{
      'deep-a': [
        {
          'deep-c': [1, 2.5],
        },
      ],
    };

    // all parameters are required, there are no defaults to test
    test('sends all parameters', () async {
      await sutClient.containers(testNames, testBytes, testFeatures, testDeep);

      verify(
        sutServer.mock.containers(testNames, testBytes, testFeatures, testDeep),
      );
    });
  });

  group('custom', () {
    const testUser = User('custom-first', 'custom-last');

    test('sends minimal parameters', () async {
      await sutClient.custom(testUser);

      verify(
        sutServer.mock.custom(testUser, deepArg(const Color(255, 255, 255))),
      );
    });

    test('sends all parameters', () async {
      await sutClient.custom(
        testUser,
        const Color(11, 22, 33),
        Permission.writeOnly,
      );

      verify(
        sutServer.mock.custom(
          testUser,
          deepArg(const Color(11, 22, 33)),
          Permission.writeOnly,
        ),
      );
    });

    test('sends last optional parameter', () async {
      await sutClient.custom(
        testUser,
        const Color(255, 255, 255),
        Permission.readWrite,
      );

      verify(
        sutServer.mock.custom(
          testUser,
          deepArg(const Color(255, 255, 255)),
          Permission.readWrite,
        ),
      );
    });
  });

  group('dotShorthands', () {
    const testUser = User('shorthand-first', 'shorthand-last');

    test('sends minimal parameters', () async {
      await sutClient.dotShorthands(testUser);

      verify(
        sutServer.mock.dotShorthands(
          testUser,
          deepArg(const Color(255, 255, 255)),
        ),
      );
    });

    test('sends all parameters', () async {
      await sutClient.dotShorthands(
        testUser,
        const .new(11, 22, 33),
        .writeOnly,
      );

      verify(
        sutServer.mock.dotShorthands(
          testUser,
          deepArg(const Color(11, 22, 33)),
          .writeOnly,
        ),
      );
    });

    test('sends last optional parameter', () async {
      await sutClient.dotShorthands(
        testUser,
        const .new(255, 255, 255),
        .readWrite,
      );

      verify(
        sutServer.mock.dotShorthands(
          testUser,
          deepArg(const Color(255, 255, 255)),
          .readWrite,
        ),
      );
    });
  });

  group('customContainers', () {
    const testUsers = [
      User('users-first', 'users-last'),
      User('users-first-2', 'users-last-2'),
    ];
    const defaultOptionalsNullable = {'readOnly': true, 'readWrite': null};
    const testColorPermissions = {
      'gray': [Permission.readOnly, Permission.writeOnly],
    };
    final testNullables = <Set<User?>?>[
      {const User('nullable-first', 'nullable-last'), null},
      null,
    ];
    const testOptionalsNullable = {'writeOnly': false, 'readWrite': null};

    test('sends minimal parameters', () async {
      await sutClient.customContainers(users: testUsers);

      verify(
        sutServer.mock.customContainers(
          users: testUsers,
          optionalsNullable: defaultOptionalsNullable,
        ),
      );
    });

    test('sends all parameters', () async {
      await sutClient.customContainers(
        users: testUsers,
        colorPermissions: testColorPermissions,
        nullables: testNullables,
        optionalsNullable: testOptionalsNullable,
      );

      verify(
        sutServer.mock.customContainers(
          users: testUsers,
          colorPermissions: testColorPermissions,
          nullables: testNullables,
          optionalsNullable: testOptionalsNullable,
        ),
      );
    });

    test('sends last optional parameter', () async {
      await sutClient.customContainers(
        users: testUsers,
        optionalsNullable: testOptionalsNullable,
      );

      verify(
        sutServer.mock.customContainers(
          users: testUsers,
          optionalsNullable: testOptionalsNullable,
        ),
      );
    });
  });

  group('records', () {
    const testEmpty = ();
    const PositionalRecord testPositional = (
      (11, 22),
      'positional-name',
      Color(77, 88, 99),
      User('positional-first', 'positional-last'),
      [Permission.writeOnly, Permission.readWrite],
    );
    const NamedRecord testNamed = (
      color: Color(12, 34, 56),
      name: 'named-name',
      permissions: [Permission.readOnly, null],
      point: (x: 33, y: 44),
      user: User('named-first', 'named-last'),
    );

    // all parameters are required, there are no defaults to test
    test('sends all parameters', () async {
      await sutClient.records(testEmpty, testPositional, testNamed);

      // records compare their fields via Object.==, which does not work for
      // the collections and colors within them - assert on the fields instead
      final captured = verify(
        sutServer.mock.records(captureAny, captureAny, captureAny),
      ).captured;

      expect(captured[0], testEmpty);

      final positional = captured[1] as PositionalRecord;
      expect(positional.$1, testPositional.$1);
      expect(positional.$2, testPositional.$2);
      expect(positional.$3, deepEquals(testPositional.$3));
      expect(positional.$4, testPositional.$4);
      expect(positional.$5, testPositional.$5);

      final named = captured[2] as NamedRecord;
      expect(named.color, deepEquals(testNamed.color));
      expect(named.name, testNamed.name);
      expect(named.permissions, testNamed.permissions);
      expect(named.point, testNamed.point);
      expect(named.user, testNamed.user);
    });
  });

  group('renamed', () {
    // the mock verifications alone would pass even if both sides silently kept
    // using the dart names - assert on the actual wire format as well
    test('sends minimal parameters', () async {
      await sutClient.renamed(a: true);

      expect(jsonDecode(sentFrames.single), {
        'jsonrpc': '2.0',
        'id': anything,
        'method': 'renamed-method',
        'params': {'renamed-a': true},
      });
      verify(sutServer.mock.renamed(a: true));
    });

    test('sends all parameters', () async {
      await sutClient.renamed(a: false, b: 13, c: 'custom');

      expect(jsonDecode(sentFrames.single), {
        'jsonrpc': '2.0',
        'id': anything,
        'method': 'renamed-method',
        'params': {'renamed-a': false, r'renamed:$b': 13, 'c': 'custom'},
      });
      verify(sutServer.mock.renamed(a: false, b: 13, c: 'custom'));
    });

    test('sends last optional parameter', () async {
      await sutClient.renamed(a: true, c: 'last');

      expect(jsonDecode(sentFrames.single), {
        'jsonrpc': '2.0',
        'id': anything,
        'method': 'renamed-method',
        'params': {'renamed-a': true, 'c': 'last'},
      });
      verify(sutServer.mock.renamed(a: true, c: 'last'));
    });
  });

  // the custom converters use a different wire format than the built in
  // conversion would - assert on it, as the mock verifications alone would pass
  // even if both sides silently kept using the default conversion

  group('customNamed', () {
    const testColor = Color(17, 34, 51);
    const testOptional = Color(1, 2, 3);

    test('sends minimal parameters', () async {
      await sutClient.customNamed(color: testColor);

      expect(jsonDecode(sentFrames.single), {
        'jsonrpc': '2.0',
        'id': anything,
        'method': 'customNamed',
        'params': {
          'color': [17, 34, 51],
        },
      });
      verify(
        sutServer.mock.customNamed(color: deepNamedArg('color', testColor)),
      );
    });

    test('sends all parameters', () async {
      await sutClient.customNamed(
        color: testColor,
        permission: .writeOnly,
        optional: testOptional,
      );

      expect(jsonDecode(sentFrames.single), {
        'jsonrpc': '2.0',
        'id': anything,
        'method': 'customNamed',
        'params': {
          'color': [17, 34, 51],
          'perm': 2,
          'optional': [1, 2, 3],
        },
      });
      verify(
        sutServer.mock.customNamed(
          color: deepNamedArg('color', testColor),
          permission: .writeOnly,
          optional: deepNamedArg('optional', testOptional),
        ),
      );
    });

    test('sends last optional parameter', () async {
      await sutClient.customNamed(color: testColor, optional: testOptional);

      expect(jsonDecode(sentFrames.single), {
        'jsonrpc': '2.0',
        'id': anything,
        'method': 'customNamed',
        'params': {
          'color': [17, 34, 51],
          'optional': [1, 2, 3],
        },
      });
      verify(
        sutServer.mock.customNamed(
          color: deepNamedArg('color', testColor),
          optional: deepNamedArg('optional', testOptional),
        ),
      );
    });
  });

  group('customPositional', () {
    const testColor = Color(17, 34, 51);

    test('sends minimal parameters', () async {
      await sutClient.customPositional(testColor);

      expect(jsonDecode(sentFrames.single), {
        'jsonrpc': '2.0',
        'id': anything,
        'method': 'customPositional',
        'params': [
          [17, 34, 51],
        ],
      });
      verify(sutServer.mock.customPositional(deepArg(testColor)));
    });

    test('sends all parameters', () async {
      await sutClient.customPositional(testColor, .writeOnly);

      expect(jsonDecode(sentFrames.single), {
        'jsonrpc': '2.0',
        'id': anything,
        'method': 'customPositional',
        'params': [
          [17, 34, 51],
          2,
        ],
      });
      verify(sutServer.mock.customPositional(deepArg(testColor), .writeOnly));
    });
  });

  group('customPrimitive', () {
    test('sends minimal parameters', () async {
      await sutClient.customPrimitive(12.5);

      expect(jsonDecode(sentFrames.single), {
        'jsonrpc': '2.0',
        'id': anything,
        'method': 'customPrimitive',
        // a string, not the number 12.5 - the built in double handling would
        // have transmitted it as is
        'params': ['12.500'],
      });
      verify(sutServer.mock.customPrimitive(12.5));
    });

    test('sends all parameters', () async {
      await sutClient.customPrimitive(12.5, 0.25);

      expect(jsonDecode(sentFrames.single), {
        'jsonrpc': '2.0',
        'id': anything,
        'method': 'customPrimitive',
        'params': ['12.500', '0.250'],
      });

      final captured = verify(
        sutServer.mock.customPrimitive(captureAny, captureAny),
      ).captured;
      expect(captured[0], isA<double>().having(($v) => $v, 'value', 12.5));
      expect(captured[1], isA<double>().having(($v) => $v, 'value', 0.25));
    });
  });
}
