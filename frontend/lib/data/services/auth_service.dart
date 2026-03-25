import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/storage_constants.dart';
import '../../domain/models/user.dart';
import 'api_service.dart';

/// Service d'authentification
/// Gère login, register, profile, logout avec JWT
class AuthService {
  final ApiService _apiService;
  final SharedPreferences _prefs;

  AuthService(this._apiService, this._prefs);

  /// Inscription d'un nouvel utilisateur
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      ApiConstants.register,
      data: {
        'full_name': name, // Backend attend 'full_name' et non 'name'
        'email': email,
        'password': password,
      },
    );

    // L'API retourne les données dans response.data.data
    final authResponse = AuthResponse.fromJson(response.data['data'] as Map<String, dynamic>);
    await _saveAuthData(authResponse);
    return authResponse;
  }

  /// Connexion utilisateur
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    // L'API retourne les données dans response.data.data
    final authResponse = AuthResponse.fromJson(response.data['data'] as Map<String, dynamic>);
    await _saveAuthData(authResponse);
    return authResponse;
  }

  /// Récupérer le profil de l'utilisateur connecté
  Future<User> getProfile() async {
    final response = await _apiService.get(ApiConstants.profile);
    // L'API retourne le user directement dans response.data
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  /// Mettre à jour le profil
  Future<User> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? address,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;
    if (address != null) data['address'] = address;

    final response = await _apiService.put(
      ApiConstants.updateProfile,
      data: data,
    );

    // L'API retourne le user dans response.data
    final user = User.fromJson(response.data as Map<String, dynamic>);
    await _saveUser(user);
    return user;
  }

  /// Changer le mot de passe
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiService.put(
      ApiConstants.changePassword,
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
  }

  /// Déconnexion
  Future<void> logout() async {
    await _prefs.remove(StorageConstants.authToken);
    await _prefs.remove(StorageConstants.userRole);
    await _prefs.remove(StorageConstants.userFullName);
    await _prefs.remove(StorageConstants.userEmail);
    await _prefs.remove(StorageConstants.userRole);
  }

  /// Vérifier si l'utilisateur est connecté
  bool isLoggedIn() {
    return _prefs.getString(StorageConstants.authToken) != null;
  }

  /// Vérifier si l'utilisateur est admin
  bool isAdmin() {
    return _prefs.getString(StorageConstants.userRole) == 'admin';
  }

  /// Récupérer l'utilisateur depuis le cache local
  User? getCachedUser() {
    final userId = _prefs.getInt(StorageConstants.userId);
    final fullName = _prefs.getString(StorageConstants.userFullName);
    final email = _prefs.getString(StorageConstants.userEmail);
    final role = _prefs.getString(StorageConstants.userRole);

    if (userId == null || email == null || role == null) {
      return null;
    }

    return User(
      id: userId,
      fullName: fullName ?? '',
      email: email,
      role: role,
      phone: _prefs.getString(StorageConstants.userPhone),
    );
  }

  /// Sauvegarder les données d'authentification
  Future<void> _saveAuthData(AuthResponse authResponse) async {
    await _prefs.setString(StorageConstants.authToken, authResponse.token);
    await _saveUser(authResponse.user);
  }

  /// Sauvegarder l'utilisateur en cache
  Future<void> _saveUser(User user) async {
    await _prefs.setInt(StorageConstants.userId, user.id);
    await _prefs.setString(StorageConstants.userFullName, user.fullName);
    await _prefs.setString(StorageConstants.userEmail, user.email);
    await _prefs.setString(StorageConstants.userRole, user.role);
    if (user.phone != null) {
      await _prefs.setString(StorageConstants.userPhone, user.phone!);
    }
  }
}
