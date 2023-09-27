import 'package:json_rpc_2/json_rpc_2.dart';

extension ParameterX on Parameter {
  double get asDouble => asNum.toDouble();

  double asDoubleOr(double defaultValue) => asNumOr(defaultValue).toDouble();

  T? maybe<T>(T Function(Parameter self) getter) =>
      value == null ? null : getter(this);

  T? maybeOr<T>(T Function(Parameter self) getter, T? defaultValue) =>
      value == null ? defaultValue : getter(this);
}
