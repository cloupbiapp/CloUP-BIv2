import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<UserModel?> signIn(String email, String password) async {
    final response = await _client.auth.signInWithPassword(email: email, password: password);
    if (response.user != null) return await getUser(response.user!.id);
    return null;
  }

  Future<UserModel?> register(String email, String password, String username) async {
    final response = await _client.auth.signUp(email: email, password: password);
    if (response.user != null) {
      final user = UserModel(
        uid: response.user!.id,
        username: username,
        email: email,
        createdAt: DateTime.now(),
      );
      await _client.from('profiles').upsert({
        'id': response.user!.id,
        'username': username,
        'email': email,
        'created_at': DateTime.now().toIso8601String(),
      });
      return user;
    }
    return null;
  }

  Future<void> signOut() async => await _client.auth.signOut();

  Future<UserModel?> getUser(String uid) async {
    try {
      final data = await _client.from('profiles').select().eq('id', uid).maybeSingle();
      if (data != null) {
        return UserModel(
          uid: uid,
          username: data['username'] ?? '',
          email: data['email'] ?? '',
          bio: data['bio'],
          photoUrl: data['photo_url'],
          followers: data['followers'] ?? 0,
          following: data['following'] ?? 0,
          createdAt: DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
        );
      }
    } catch (_) {}
    final user = _client.auth.currentUser;
    if (user != null && user.id == uid) {
      return UserModel(
        uid: uid,
        username: user.email?.split('@').first ?? 'usuario',
        email: user.email ?? '',
        createdAt: DateTime.now(),
      );
    }
    return null;
  }
}
