class AuthUser {
  final String id;
  final String email;
  final String? nickname;
  final String role;

  const AuthUser({
    required this.id,
    required this.email,
    required this.nickname,
    required this.role,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      nickname: json['nickname'] as String?,
      role: json['role'] as String,
    );
  }
}