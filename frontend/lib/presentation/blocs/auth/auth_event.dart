import 'package:equatable/equatable.dart';
import '../../../domain/models/user.dart';

/// === AUTHENTICATION EVENTS ===

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Vérifier si l'utilisateur est déjà connecté au démarrage
class AuthCheckRequested extends AuthEvent {}

/// Connexion utilisateur
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Inscription utilisateur
class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

/// Récupérer le profil
class ProfileRequested extends AuthEvent {}

/// Mettre à jour le profil
class ProfileUpdateRequested extends AuthEvent {
  final String? name;
  final String? email;
  final String? phone;
  final String? address;

  const ProfileUpdateRequested({
    this.name,
    this.email,
    this.phone,
    this.address,
  });

  @override
  List<Object?> get props => [name, email, phone, address];
}

/// Changer le mot de passe
class PasswordChangeRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const PasswordChangeRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

/// Déconnexion
class LogoutRequested extends AuthEvent {}

/// === AUTHENTICATION STATES ===

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// État initial
class AuthInitial extends AuthState {}

/// Chargement en cours
class AuthLoading extends AuthState {}

/// Utilisateur authentifié
class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Utilisateur non authentifié
class Unauthenticated extends AuthState {}

/// Erreur d'authentification
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Profil mis à jour avec succès
class ProfileUpdated extends AuthState {
  final User user;

  const ProfileUpdated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Mot de passe changé avec succès
class PasswordChanged extends AuthState {}
