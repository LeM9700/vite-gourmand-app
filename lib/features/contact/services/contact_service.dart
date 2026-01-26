import 'package:dio/dio.dart';
import '../../../core/api/dio_client.dart';
import '../models/contact_models.dart';

class ContactService {
  DioClient? _dioClient;

  Future<void> _initializeClient() async {
    _dioClient ??= await DioClient.create();
  }

  Future<ContactResponse> sendMessage(ContactRequest request) async {
    await _initializeClient();

    try {
      final response = await _dioClient!.dio.post(
        '/contact',
        data: request.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'accept': 'application/json',
          },
        ),
      );

      return ContactResponse.fromJson(response.data ?? {});
    } catch (e) {
      if (e.toString().contains('400') || e.toString().contains('validation')) {
        throw Exception('Données invalides: Vérifiez tous les champs');
      }
      if (e.toString().contains('429')) {
        throw Exception('Trop de messages envoyés. Veuillez patienter');
      }
      throw Exception('Erreur d\'envoi: Vérifiez votre connexion internet');
    }
  }
}
