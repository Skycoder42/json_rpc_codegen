import 'package:meta/meta.dart';

@immutable
class User {
  final String firstName;
  final String lastName;

  const User(this.firstName, this.lastName);

  factory User.fromJson(Map<String, dynamic> json) =>
      User(json['firstName'] as String, json['lastName'] as String);

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
  };

  @override
  String toString() => '<$firstName $lastName>';

  @override
  int get hashCode => Object.hash(firstName, lastName);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! User) {
      return false;
    }

    return firstName == other.firstName && lastName == other.lastName;
  }
}

class Color {
  final int r;
  final int g;
  final int b;

  const Color(this.r, this.g, this.b);

  factory Color.fromJson(String json) {
    final regExp = RegExp(
      r'^#([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})$',
    );
    final match = regExp.matchAsPrefix(json);
    if (match == null) {
      throw FormatException('Not a valid hex color code', json);
    }

    return Color(
      int.parse(match[1]!, radix: 16),
      int.parse(match[2]!, radix: 16),
      int.parse(match[3]!, radix: 16),
    );
  }

  String toJson() => '#${_toHex(r)}${_toHex(g)}${_toHex(b)}';

  @override
  String toString() => toJson();

  static String _toHex(int v) =>
      v.toRadixString(16).padLeft(2, '0').toUpperCase();
}

enum Permission { readOnly, writeOnly, readWrite }

// custom converters - all of them deliberately use a different wire format
// than the built in conversion would, so that the tests can detect whether the
// annotations are actually honored

List<int> colorToRgb(Color color) => [color.r, color.g, color.b];

Color colorFromRgb(List<dynamic> json) =>
    Color(json[0] as int, json[1] as int, json[2] as int);

abstract final class PermissionCodec {
  static int toCode(Permission permission) => permission.index + 1;

  static Permission fromCode(int code) => Permission.values[code - 1];
}

// primitives must be overridable as well - a double is transmitted as a fixed
// length string instead of via the built in asNum/toDouble handling

String doubleToFixed(double value) => value.toStringAsFixed(3);

double doubleFromFixed(String json) => double.parse(json);
