class User {
  final int? id;
  final String email;
  final String password;
  final DateTime createdAt;

  User({
    this.id,
    required this.email,
    required this.password,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id']?.toInt(),
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }
}