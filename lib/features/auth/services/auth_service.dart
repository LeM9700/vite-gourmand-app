import '../../../core/api/dio_client.dart';
import '../models/auth_models.dart';
import '../../../core/storage/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  DioClient? _dioClient;
  final _storage = SecureStorage();

  Future<void> _initializeClient() async {
    _dioClient ??= await DioClient.create();
  }

  Future<AuthResponse> login(LoginRequest request) async {
    await _initializeClient();

    try {
      final response = await _dioClient!.dio.post(
        '/auth/login',
        data:
            'grant_type=password&username=${Uri.encodeComponent(request.email)}&password=${Uri.encodeComponent(request.password)}&scope=&client_id=string&client_secret=',
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'accept': 'application/json',
          },
        ),
      );

      final authResponse = AuthResponse.fromJson(response.data);
      await _storage.saveToken(authResponse.accessToken);

      // Récupérer les infos utilisateur pour obtenir le rôle
      final userResponse = await _dioClient!.dio.get('/auth/me');
      final userData = UserData.fromJson(userResponse.data);
      await _storage.saveRole(userData.role);

      return authResponse;
    } catch (e) {
      if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        throw Exception('Email ou mot de passe incorrect');
      }
      throw Exception('Erreur de connexion: Vérifiez votre connexion internet');
    }
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    await _initializeClient();

    try {
      final response = await _dioClient!.dio.post(
        '/auth/register',
        data: request.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'accept': 'application/json',
          },
        ),
      );

      // Auto-login after register is often expected, or just return response
      // For now, let's just return. If the API returns a token, we should save it.
      // Usually register returns the user, or sometimes a token too.
      // Inspecting scheams is hard now, but let's assume register just registers.
      // If AuthResponse contains accessToken, safe to save it if present.

      final authResponse = AuthResponse.fromJson(response.data);
      if (authResponse.accessToken.isNotEmpty) {
        await _storage.saveToken(authResponse.accessToken);
      }

      return authResponse;
    } catch (e) {
      if (e.toString().contains('409') ||
          e.toString().contains('already exists')) {
        throw Exception('Cet email est déjà utilisé');
      }
      if (e.toString().contains('400') || e.toString().contains('validation')) {
        throw Exception('Données invalides: Vérifiez tous les champs');
      }
      throw Exception(
        'Erreur d\'inscription: Vérifiez votre connexion internet',
      );
    }
  }

  Future<void> logout() async {
    await _initializeClient();

    try {
      await _dioClient!.dio.post('/auth/logout');
    } catch (e) {
      // Log de l'erreur mais ne pas bloquer la déconnexion
      debugPrint('Erreur lors de la déconnexion: $e');
    } finally {
      await _storage.clearAll();
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await _storage.readToken();
    return token != null && token.isNotEmpty;
  }

  Future<UserData> getCurrentUser() async {
    await _initializeClient();

    try {
      final response = await _dioClient!.dio.get('/auth/me');
      return UserData.fromJson(response.data);
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération du profil: ${e.toString()}',
      );
    }
  }

  Future<UserData> updateProfile({
    String? firstname,
    String? lastname,
    String? phone,
    String? address,
  }) async {
    await _initializeClient();

    try {
      final data = <String, dynamic>{};
      if (firstname != null) data['firstname'] = firstname;
      if (lastname != null) data['lastname'] = lastname;
      if (phone != null) data['phone'] = phone;
      if (address != null) data['address'] = address;

      final response = await _dioClient!.dio.patch('/auth/me', data: data);
      return UserData.fromJson(response.data);
    } catch (e) {
      throw Exception(
        'Erreur lors de la mise à jour du profil: ${e.toString()}',
      );
    }
  }

  Future<void> forgotPassword(String email) async {
    await _initializeClient();

    try {
      await _dioClient!.dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération du mot de passe: ${e.toString()}',
      );
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    await _initializeClient();

    try {
      await _dioClient!.dio.post(
        '/auth/reset-password',
        data: {'token': token, 'new_password': newPassword},
      );
    } catch (e) {
      throw Exception(
        'Erreur lors de la réinitialisation du mot de passe: ${e.toString()}',
      );
    }
  }
}
