import 'package:equatable/equatable.dart';

/// Modèle Utilisateur
class User extends Equatable {
  final int id;
  final String email;
  final String fullName;
  final String? phone;
  final String role;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    required this.role,
    this.createdAt,
  });

  /// Créer un User depuis JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Convertir User en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'role': role,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Vérifier si l'utilisateur est admin
  bool get isAdmin => role == 'admin';

  /// Copier avec modifications
  User copyWith({
    int? id,
    String? email,
    String? fullName,
    String? phone,
    String? role,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, email, fullName, phone, role, createdAt];
}

/// Réponse d'authentification (login/register)
class AuthResponse extends Equatable {
  final User user;
  final String token;

  const AuthResponse({
    required this.user,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }

  @override
  List<Object?> get props => [user, token];
}
