import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_config.dart';
import '../models/user_profile.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<void> signUp({
    required String email,
    required String password,
    required String secretKey,
  }) async {
    // Validate secret key
    if (secretKey != AppConfig.registrationSecretKey) {
      throw Exception('Invalid secret key. Registration is restricted.');
    }

    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      
      // Create user profile with default role 'user'
      // Username will be set on first login via username setup screen
      if (response.user != null) {
        await _client.from('user_profiles').insert({
          'id': response.user!.id,
          'email': email,
          'role': 'user',
          'username': null, // User will set this on first login
        });
      }
    } catch (e) {
      throw Exception('Failed to register: ${e.toString()}');
    }
  }
  
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .single();
      
      return UserProfile.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      // Profile doesn't exist - try to create it for existing user
      try {
        final user = _client.auth.currentUser;
        if (user != null && user.id == userId) {
          // Get email from auth user
          final email = user.email ?? '';
          await _client.from('user_profiles').insert({
            'id': userId,
            'email': email,
            'role': 'user',
            'username': null, // User will set this on first login
          });
          
          // Fetch the newly created profile
          final newResponse = await _client
              .from('user_profiles')
              .select()
              .eq('id', userId)
              .single();
          
          return UserProfile.fromJson(newResponse as Map<String, dynamic>);
        }
      } catch (createError) {
        // If creation fails, return null
        print('Failed to auto-create user profile: $createError');
      }
      return null;
    }
  }
  
  Future<UserProfile?> getCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) return null;
    return getUserProfile(user.id);
  }
  
  Future<bool> isAdmin() async {
    final profile = await getCurrentUserProfile();
    return profile?.isAdmin ?? false;
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Failed to send password reset email: ${e.toString()}');
    }
  }

  Future<void> updateUsername(String username) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Check if username is already taken
      final existing = await _client
          .from('user_profiles')
          .select('id')
          .eq('username', username)
          .neq('id', user.id)
          .maybeSingle();

      if (existing != null) {
        throw Exception('Username is already taken');
      }

      // Update username
      await _client
          .from('user_profiles')
          .update({
            'username': username,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);
    } catch (e) {
      throw Exception('Failed to update username: ${e.toString()}');
    }
  }
}

