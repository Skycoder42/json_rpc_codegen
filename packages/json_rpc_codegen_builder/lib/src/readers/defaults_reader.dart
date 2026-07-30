import 'package:analyzer/dart/element/element.dart';
import 'package:json_rpc_codegen/json_rpc_codegen.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

@internal
abstract base class DefaultsReader {
  static const _clientTypeChecker = TypeChecker.typeNamed(
    ClientDefaults,
    inPackage: 'json_rpc_codegen',
  );
  static const _serverTypeChecker = TypeChecker.typeNamed(
    ServerDefaults,
    inPackage: 'json_rpc_codegen',
  );

  DefaultsReader._();

  static bool isServerDefault(MethodElement method) {
    final methodIsClient = _isClient(method);
    if (methodIsClient != null) {
      return !methodIsClient;
    }

    final clazz = method.enclosingElement! as ClassElement;
    final classIsClient = _isClient(clazz);
    if (classIsClient != null) {
      return !classIsClient;
    }

    return true;
  }

  static bool? _isClient(Element element) {
    final hasClient = _clientTypeChecker.hasAnnotationOfExact(element);
    final hasServer = _serverTypeChecker.hasAnnotationOfExact(element);

    if (hasClient && hasServer) {
      throw InvalidGenerationSourceError(
        'You cannot use both, @clientDefaults and @serverDefaults on the same '
        'element!',
        element: element,
        todo: 'Remove one of the two',
      );
    } else if (hasClient) {
      return true;
    } else if (hasServer) {
      return false;
    } else {
      return null;
    }
  }
}
