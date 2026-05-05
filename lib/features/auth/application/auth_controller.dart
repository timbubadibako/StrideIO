import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_logger.dart';
import '../../../dev/dev_providers.dart';

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

class AuthController {
  final Ref _ref;
  final SupabaseClient _supabase = Supabase.instance.client;

  AuthController(this._ref);

  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  bool get _logEnabled => _ref.read(supabaseDevLogEnabledProvider);

  Future<AuthResponse> signInWithEmailPassword(String email, String password) async {
    try {
      final res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      SupabaseLogger.log(_logEnabled, 'Auth SignIn');
      return res;
    } catch (e) {
      SupabaseLogger.log(_logEnabled, 'Auth SignIn', success: false, error: e.toString());
      rethrow;
    }
  }

  Future<AuthResponse> signUpWithEmailPassword(String email, String password, String displayName) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name': displayName,
        },
      );
      SupabaseLogger.log(_logEnabled, 'Auth SignUp');
      return response;
    } catch (e) {
      SupabaseLogger.log(_logEnabled, 'Auth SignUp', success: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> resetPasswordForEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      SupabaseLogger.log(_logEnabled, 'Auth ResetPassword');
    } catch (e) {
      SupabaseLogger.log(_logEnabled, 'Auth ResetPassword', success: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      SupabaseLogger.log(_logEnabled, 'Auth SignOut');
    } catch (e) {
      SupabaseLogger.log(_logEnabled, 'Auth SignOut', success: false, error: e.toString());
      rethrow;
    }
  }
}
