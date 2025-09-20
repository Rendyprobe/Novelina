class UserModel {
  final String email;
  final String name;
  final String password;

  UserModel({
    required this.email,
    required this.name,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'password': password,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'],
      name: json['name'],
      password: json['password'],
    );
  }

  static String getNameFromEmail(String email) {
    if (email.isEmpty) return '';
    String name = email.split('@')[0];
    return name[0].toUpperCase() + name.substring(1).toLowerCase();
  }
}
