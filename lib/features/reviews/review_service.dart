import '../../core/api/dio_client.dart';
import 'models/review_model.dart';

class ReviewService {
  final DioClient _dioClient;

  ReviewService(this._dioClient);

  /// Crée un avis pour une commande
  Future<ReviewModel> createReview({
    required int orderId,
    required int rating,
    required String comment,
  }) async {
    final response = await _dioClient.dio.post(
      '/orders/$orderId/review',
      data: {
        'rating': rating,
        'comment': comment,
      },
    );

    return ReviewModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Récupère les avis approuvés (publics)
  Future<List<ReviewModel>> getApprovedReviews({
    int? limit,
    String sortBy = 'date',
    String order = 'desc',
  }) async {
    final response = await _dioClient.dio.get(
      '/reviews/approved',
      queryParameters: {
        if (limit != null) 'limit': limit,
        'sort_by': sortBy,
        'order': order,
      },
    );

    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => ReviewModel.fromJson(json as Map<String, dynamic>)).toList();
  }
}
