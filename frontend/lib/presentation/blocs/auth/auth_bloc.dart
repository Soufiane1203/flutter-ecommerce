import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/auth_service.dart';
import 'auth_event.dart';
import 'auth_event.dart' as auth_event;

export 'auth_event.dart';

/// BLoC de gestion de l'authentification
/// Gère login, register, profile, logout
class AuthBloc extends Bloc<AuthEvent, auth_event.AuthState> {
  final AuthService _authService;

  AuthBloc(this._authService) : super(auth_event.AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<ProfileRequested>(_onProfileRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
    on<PasswordChangeRequested>(_onPasswordChangeRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  /// Vérifier si l'utilisateur est déjà connecté
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<auth_event.AuthState> emit,
  ) async {
    emit(auth_event.AuthLoading());

    try {
      if (_authService.isLoggedIn()) {
        // Récupérer l'utilisateur depuis le cache
        final user = _authService.getCachedUser();
        if (user != null) {
          emit(auth_event.Authenticated(user));
        } else {
          // Si pas de cache, récupérer depuis l'API
          final user = await _authService.getProfile();
          emit(auth_event.Authenticated(user));
        }
      } else {
        emit(auth_event.Unauthenticated());
      }
    } catch (e) {
      emit(auth_event.Unauthenticated());
    }
  }

  /// Connexion
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<auth_event.AuthState> emit,
  ) async {
    emit(auth_event.AuthLoading());

    try {
      final authResponse = await _authService.login(
        email: event.email,
        password: event.password,
      );
      emit(auth_event.Authenticated(authResponse.user));
    } catch (e) {
      emit(auth_event.AuthError(e.toString()));
      emit(auth_event.Unauthenticated());
    }
  }

  /// Inscription
  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<auth_event.AuthState> emit,
  ) async {
    emit(auth_event.AuthLoading());

    try {
      final authResponse = await _authService.register(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      emit(auth_event.Authenticated(authResponse.user));
    } catch (e) {
      emit(auth_event.AuthError(e.toString()));
      emit(auth_event.Unauthenticated());
    }
  }

  /// Récupérer le profil
  Future<void> _onProfileRequested(
    ProfileRequested event,
    Emitter<auth_event.AuthState> emit,
  ) async {
    emit(auth_event.AuthLoading());

    try {
      final user = await _authService.getProfile();
      emit(auth_event.Authenticated(user));
    } catch (e) {
      emit(auth_event.AuthError(e.toString()));
    }
  }

  /// Mettre à jour le profil
  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<auth_event.AuthState> emit,
  ) async {
    emit(auth_event.AuthLoading());

    try {
      final user = await _authService.updateProfile(
        name: event.name,
        email: event.email,
        phone: event.phone,
        address: event.address,
      );
      emit(auth_event.ProfileUpdated(user));
      emit(auth_event.Authenticated(user));
    } catch (e) {
      emit(auth_event.AuthError(e.toString()));
    }
  }

  /// Changer le mot de passe
  Future<void> _onPasswordChangeRequested(
    PasswordChangeRequested event,
    Emitter<auth_event.AuthState> emit,
  ) async {
    emit(auth_event.AuthLoading());

    try {
      await _authService.changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );
      emit(auth_event.PasswordChanged());
      // Recharger le profil après changement de mot de passe
      final user = await _authService.getProfile();
      emit(auth_event.Authenticated(user));
    } catch (e) {
      emit(auth_event.AuthError(e.toString()));
    }
  }

  /// Déconnexion
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<auth_event.AuthState> emit,
  ) async {
    await _authService.logout();
    emit(auth_event.Unauthenticated());
  }
}
