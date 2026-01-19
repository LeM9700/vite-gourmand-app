import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = "access_token";
  static const _roleKey = "user_role";

  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);
  Future<String?> readToken() => _storage.read(key: _tokenKey);
  Future<void> clearToken() => _storage.delete(key: _tokenKey);

  Future<void> saveRole(String role) => _storage.write(key: _roleKey, value: role);
  Future<String?> readRole() => _storage.read(key: _roleKey);
  Future<void> clearRole() => _storage.delete(key: _roleKey);

  /// Efface toutes les données stockées (déconnexion complète)
  Future<void> clearAll() async {
    await clearToken();
    await clearRole();
  }
}
