class User {
  final String firstName;
  final String lastName;

  const User(this.firstName, this.lastName);

  factory User.fromJson(Map<String, dynamic> json) => User(
        json['firstName'] as String,
        json['lastName'] as String,
      );

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
      };

  @override
  String toString() => '<$firstName $lastName>';
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

enum Permission {
  readOnly,
  writeOnly,
  readWrite,
}
