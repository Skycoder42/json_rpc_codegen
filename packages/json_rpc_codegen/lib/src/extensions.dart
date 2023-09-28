import 'package:json_rpc_2/json_rpc_2.dart';

// TODO make generated
extension ParameterX on Parameter {
  T? nullOr<T>(T Function(Parameter self) getter) =>
      value == null ? null : getter(this);

  T? maybeNullOr<T>(T Function(Parameter self) getter, T? defaultValue) =>
      exists ? nullOr<T>(getter) : defaultValue;
}
