import '../../../../core/api/dio_client.dart';
import '../../../reviews/models/review_model.dart';
import '../models/contact_message_model.dart';

class ModerationService {
  DioClient? _dioClient;

  Future<void> _initializeClient() async {
    _dioClient ??= await DioClient.create();
  }

  // ==================== AVIS ====================

  /// Récupère tous les avis (avec tri optionnel)
  Future<List<ReviewModel>> getReviews({
    String? sortBy, // 'date' ou 'rating'
    String? order, // 'asc' ou 'desc'
    int? limit,
  }) async {
    await _initializeClient();

    try {
      final queryParams = <String, dynamic>{};
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      if (order != null) queryParams['order'] = order;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _dioClient!.dio.get(
        '/reviews/all',
        queryParameters: queryParams,
      );

      List<dynamic> reviewsData;
      if (response.data is List) {
        reviewsData = response.data as List;
      } else if (response.data is Map && response.data['items'] != null) {
        reviewsData = response.data['items'] as List;
      } else {
        reviewsData = [];
      }

      return reviewsData
          .map((json) => ReviewModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des avis: $e');
    }
  }

  /// Modère un avis (APPROVED ou REJECTED)
  Future<ReviewModel> moderateReview({
    required int reviewId,
    required String status, // APPROVED ou REJECTED
  }) async {
    await _initializeClient();

    try {
      final response = await _dioClient!.dio.patch(
        '/reviews/$reviewId/moderate',
        data: {'status': status},
      );

      return ReviewModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Erreur lors de la modération: $e');
    }
  }

  // ==================== MESSAGES CONTACT ====================

  /// Récupère tous les messages de contact
  Future<List<ContactMessageModel>> getContactMessages() async {
    await _initializeClient();

    try {
      final response = await _dioClient!.dio.get('/admin/messages');

      List<dynamic> messagesData;
      if (response.data is List) {
        messagesData = response.data as List;
      } else {
        messagesData = [];
      }

      return messagesData
          .map(
            (json) =>
                ContactMessageModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des messages: $e');
    }
  }

  /// Change le statut d'un message de contact
  Future<ContactMessageModel> updateMessageStatus({
    required int messageId,
    required String status, // SENT, FAILED, ARCHIVED, TREATED
  }) async {
    await _initializeClient();

    try {
      final response = await _dioClient!.dio.patch(
        '/admin/messages/$messageId/status',
        data: {'status': status},
      );

      return ContactMessageModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour: $e');
    }
  }
}
