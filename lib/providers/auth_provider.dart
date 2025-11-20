import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../models/user_profile.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  UserProfile? _userProfile;
  bool _isLoading = false;
  bool _isLoadingProfile = false;
  String? _error;

  User? get user => _user;
  UserProfile? get userProfile => _userProfile;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _userProfile?.isAdmin ?? false;
  bool get isLoading => _isLoading;
  bool get isLoadingProfile => _isLoadingProfile;
  String? get error => _error;

  StreamSubscription<AuthState>? _authSubscription;

  AuthProvider() {
    _user = _authService.currentUser;
    _initializeAuthListener();
  }

  void _initializeAuthListener() {
    _authSubscription = _authService.authStateChanges.listen(
      (authState) async {
        _user = authState.session?.user;
        if (_user != null) {
          await _loadUserProfile();
        } else {
          _userProfile = null;
          _isLoadingProfile = false;
        }
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isLoadingProfile = false;
        notifyListeners();
      },
    );
    // Load initial profile if user exists
    if (_user != null) {
      _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    if (_user != null) {
      _isLoadingProfile = true;
      notifyListeners();
      try {
        _userProfile = await _authService.getCurrentUserProfile();
      } finally {
        _isLoadingProfile = false;
        notifyListeners();
      }
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String secretKey,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signUp(
        email: email,
        password: password,
        secretKey: secretKey,
      );
      await _loadUserProfile();
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signIn(
        email: email,
        password: password,
      );
      await _loadUserProfile();
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signOut();
      _user = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUsername(String username) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.updateUsername(username);
      await _loadUserProfile(); // Reload profile to get updated username
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool get needsUsernameSetup {
    return _userProfile == null || 
           _userProfile!.username == null || 
           _userProfile!.username!.isEmpty;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

