import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Holds the current logged-in user
final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, UserModel?>(
        (ref) => CurrentUserNotifier(ref));

class CurrentUserNotifier extends StateNotifier<UserModel?> {
  final Ref _ref;

  CurrentUserNotifier(this._ref) : super(null) {
    loadCurrentUser();
  }

  AuthService get _authService => _ref.read(authServiceProvider);

  /// Load current user from Firebase
  Future<void> loadCurrentUser() async {
    try {
      UserModel? user = await _authService.getCurrentUser();
      state = user;
    } catch (_) {}
  }

  /// Login method returns role
  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      UserModel user = await _authService.login(email: email, password: password);
      state = user;
      return user.role;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign up method returns role
  Future<String> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    String role = "user",
  }) async {
    try {
      UserModel user = await _authService.signUp(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );
      state = user;
      return user.role;
    } catch (e) {
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _authService.logout();
    state = null;
  }

  /// Update user profile
  Future<void> updateProfile(UserModel updatedUser) async {
    try {
      await _authService.updateProfile(updatedUser);
      state = updatedUser;
    } catch (e) {
      rethrow;
    }
  }
}
