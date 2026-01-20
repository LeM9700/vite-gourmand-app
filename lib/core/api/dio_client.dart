// lib/core/api/dio_client.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../config.dart';
import '../storage/secure_storage.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class DioClient {
  final Dio dio;

  DioClient._(this.dio);

  static Future<DioClient> create() async {
    final storage = SecureStorage();
    
    // ✅ URL selon la plateforme
    String apiUrl = AppConfig.getApiUrl();
    
    final dio = Dio(BaseOptions(
      baseUrl: apiUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60),  // Augmenté pour operations email
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // ✅ Configuration pour Android/iOS uniquement
    if (!kIsWeb && dio.httpClientAdapter is IOHttpClientAdapter) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
    }

    // ✅ Interceptor de debug
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: true,
        logPrint: (obj) => print('🌐 API: $obj'),
      ));
    }

    // ✅ Intercepteur d'authentification et gestion 401
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.readToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (DioException error, ErrorInterceptorHandler handler) async {
        print('❌ Erreur API: ${error.message}');
        print('❌ URL: ${error.requestOptions.uri}');
        
        // Si 401, déconnexion automatique
        if (error.response?.statusCode == 401) {
          print('🔑 Token invalide, déconnexion automatique');
          
          // Effacer le token
          await storage.clearToken();
          
          // Rediriger vers la page d'accueil
          final context = navigatorKey.currentContext;
          if (context != null && context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/',
              (route) => false,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Votre session a expiré. Veuillez vous reconnecter.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 4),
              ),
            );
          }
        }
        
        handler.next(error);
      },
    ));

    return DioClient._(dio);
  }

  

  /// Vérifie si un token valide existe
  Future<bool> hasValidToken() async {
    final storage = SecureStorage();
    final token = await storage.readToken();
    return token != null && token.isNotEmpty;
  }

  /// Efface le token (pour déconnexion)
  Future<void> clearToken() async {
    final storage = SecureStorage();
    await storage.clearToken();
  }
}