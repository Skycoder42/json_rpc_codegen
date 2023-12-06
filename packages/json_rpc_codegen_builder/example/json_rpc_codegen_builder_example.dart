// ignore_for_file: unreachable_from_main

import 'package:json_rpc_codegen/json_rpc_codegen.dart';

part 'json_rpc_codegen_builder_example.g.dart';

enum Permission {
  read,
  write,
  administrate,
}

enum Stage { all, pre, post }

class User {
  final String firstName;
  final String lastName;

  const User(this.firstName, this.lastName);

  factory User.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError(json.toString());
}

@jsonRpc
// ignore: unused_element
abstract class _SampleApi {
  void hello(
    String name, [
    int times = 5,
    double? interval,
    int delay = 100,
  ]);

  @clientDefaults
  void notify({
    required int id,
    List<double> measures = const [1, 2],
  });

  String echo(String message);

  User? createUser(Map<String, Set<Permission>?> permissions);

  List<List<User>?> userMatrix([Permission? permission]);

  Map<String, List<Permission>> permissions();

  // ignore: prefer_void_to_null
  Null setHomepage({required Uri url, DateTime? timestamp});

  Uri findForDates(Iterable<DateTime> times);

  @clientDefaults
  void log(
    String message,
    dynamic context, [
    User user = const User('admin', 'admin'),
  ]);

  bool validate({
    User user = const User('admin', 'admin'),
    required User? authorizeFor,
    Permission permission = Permission.administrate,
    List<Uri>? resources,
  });

  Map merge(Set keys, Iterable values);

  (int, List<User>?, Permission, (int, int)) flip(
    ({int am, List<User>? ul, Permission pm, (int, int) pt}) record,
    () control,
  );

  void startServerTask({
    required int id,
    required String taskName,
    bool verbose = false,
    double? scale,
  });

  @clientDefaults
  double getProgress(int id, [Stage stage = Stage.all]);

  Stream<User> streamUsers(Permission permission);
}

void main() {}

extension on PeerBase {
  Stream<User> streamUsers(Permission permission) {
    const streamId = 42;
    final controller = StreamController<User>(
      onListen: () => jsonRpcInstance.sendNotification(
        'streamUsers',
        [StreamCommand.listen.name, streamId, permission.name],
      ),
      onCancel: () => jsonRpcInstance.sendNotification(
        'streamUsers',
        [StreamCommand.cancel.name, streamId],
      ),
      onPause: () => jsonRpcInstance.sendNotification(
        'streamUsers',
        [StreamCommand.pause.name, streamId],
      ),
      onResume: () => jsonRpcInstance.sendNotification(
        'streamUsers',
        [StreamCommand.resume.name, streamId],
      ),
    );

    jsonRpcInstance.registerMethod('streamUsers',
        // ignore: avoid_types_on_closure_parameters
        (Parameters parameters) async {
      final kind = Kind.values.byName(parameters['kind'].asString);
      switch (kind) {
        case Kind.onData:
          controller.add(User.fromJson(parameters['value'].asMap.cast()));
        case Kind.onError:
          controller.addError(
            Exception(parameters['error'].asString),
            StackTrace.fromString(parameters['stackTrace'].asString),
          );
        case Kind.onDone:
          await controller.close();
      }
    });

    return controller.stream;
  }
}
