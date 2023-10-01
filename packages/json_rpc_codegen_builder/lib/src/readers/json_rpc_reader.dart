import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

/// @nodoc
@internal
class JsonRpcReader {
  final ConstantReader _reader;

  /// @nodoc
  const JsonRpcReader(this._reader);

  /// @nodoc
  bool get client => _reader.read('client').boolValue;

  /// @nodoc
  bool get server => _reader.read('server').boolValue;

  /// @nodoc
  bool get mixinsOnly => _reader.read('mixinsOnly').boolValue;
}
