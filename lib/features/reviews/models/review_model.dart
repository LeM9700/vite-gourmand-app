class ReviewModel {
  final int id;
  final int orderId;
  final int userId;
  final int rating;
  final String comment;
  final String status;
  final DateTime createdAt;
  final int? moderatedByUserId;
  final DateTime? moderatedAt;
  final String? customerFirstname;
  final String? customerLastname;

  ReviewModel({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.status,
    required this.createdAt,
    this.moderatedByUserId,
    this.moderatedAt,
    this.customerFirstname,
    this.customerLastname,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    return ReviewModel(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      status: json['status'] ?? 'PENDING',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      moderatedByUserId: json['moderated_by_user_id'],
      moderatedAt: json['moderated_at'] != null
          ? DateTime.tryParse(json['moderated_at'] as String)
          : null,
      customerFirstname: customer?['firstname'] as String?,
      customerLastname: customer?['lastname'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'moderated_by_user_id': moderatedByUserId,
      'moderated_at': moderatedAt?.toIso8601String(),
    };
  }
}
