class UserModel {
  final int id;
  final String email;
  final String name;
  final String role;
  final String avatarUrl;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.avatarUrl = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'avatar_url': avatarUrl,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      email: (json['email'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      role: (json['role'] as String?)?.toLowerCase() ?? 'user',
      avatarUrl: (json['avatar_url'] as String?) ??
          (json['avatarUrl'] as String?) ??
          '',
    );
  }

  static String getNameFromEmail(String email) {
    if (email.isEmpty) return '';

    final parts = email.split('@');
    if (parts.isEmpty || parts.first.isEmpty) {
      return '';
    }

    final localPart = parts.first;
    if (localPart.length == 1) {
      return localPart.toUpperCase();
    }

    return '';
  }
}
