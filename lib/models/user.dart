enum UserRole { admin, user, donor }

class User {
  final String id;
  final String email;
  final String fullName;
  final String password;
  final UserRole role;
  final bool isPublic;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.password,
    required this.role,
    this.isPublic = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'password': password,
      'role': role.name,
      'isPublic': isPublic,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      fullName: json['fullName'],
      password: json['password'],
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.user,
      ),
      isPublic: json['isPublic'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? password,
    UserRole? role,
    bool? isPublic,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      password: password ?? this.password,
      role: role ?? this.role,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
