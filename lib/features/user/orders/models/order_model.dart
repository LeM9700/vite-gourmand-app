import 'package:intl/intl.dart';

/// Modèle pour les commandes - Mapping du schéma OrderOut backend
class OrderModel {
  final int id;
  final int userId;
  final int menuId;
  final String eventAddress;
  final String eventCity;
  final DateTime eventDate;
  final String eventTime;
  final double deliveryKm;
  final double deliveryFee;
  final int peopleCount;
  final double menuPrice;
  final double discount;
  final double totalPrice;
  final OrderStatus status;
  final bool hasLoanedEquipment;

  OrderModel({
    required this.id,
    required this.userId,
    required this.menuId,
    required this.eventAddress,
    required this.eventCity,
    required this.eventDate,
    required this.eventTime,
    required this.deliveryKm,
    required this.deliveryFee,
    required this.peopleCount,
    required this.menuPrice,
    required this.discount,
    required this.totalPrice,
    required this.status,
    required this.hasLoanedEquipment,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      menuId: json['menu_id'] as int,
      eventAddress: json['event_address'] as String,
      eventCity: json['event_city'] as String,
      eventDate: DateTime.parse(json['event_date'] as String),
      eventTime: json['event_time'] as String,
      deliveryKm: _parseDecimal(json['delivery_km']),
      deliveryFee: _parseDecimal(json['delivery_fee']),
      peopleCount: json['people_count'] as int,
      menuPrice: _parseDecimal(json['menu_price']),
      discount: _parseDecimal(json['discount']),
      totalPrice: _parseDecimal(json['total_price']),
      status: OrderStatus.fromString(json['status'] as String),
      hasLoanedEquipment: json['has_loaned_equipment'] as bool,
    );
  }

  static double _parseDecimal(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'menu_id': menuId,
      'event_address': eventAddress,
      'event_city': eventCity,
      'event_date': DateFormat('yyyy-MM-dd').format(eventDate),
      'event_time': eventTime,
      'delivery_km': deliveryKm,
      'delivery_fee': deliveryFee,
      'people_count': peopleCount,
      'menu_price': menuPrice,
      'discount': discount,
      'total_price': totalPrice,
      'status': status.value,
      'has_loaned_equipment': hasLoanedEquipment,
    };
  }

  /// Formatte la date en français
  String get formattedDate =>
      DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(eventDate);

  /// Formatte l'heure
  String get formattedTime => eventTime.substring(0, 5);

  /// Vérifie si la commande est modifiable
  bool get isEditable => status == OrderStatus.placed;

  /// Vérifie si la commande est annulable
  bool get isCancellable =>
      status == OrderStatus.placed || status == OrderStatus.accepted;

  /// Vérifie si c'est une commande en cours
  bool get isActive =>
      status != OrderStatus.completed && status != OrderStatus.cancelled;

  /// Calcule les jours restants avant l'événement
  int get daysUntilEvent {
    final now = DateTime.now();
    final eventDateTime = eventDate;
    return eventDateTime.difference(now).inDays;
  }

  /// Vérifie si la commande peut être évaluée (review)
  bool get canBeReviewed =>
      status == OrderStatus.delivered || status == OrderStatus.completed;
}

/// Status de commande - Mapping des statuts backend
enum OrderStatus {
  placed('PLACED', 'Demande envoyée', '📋'),
  accepted('ACCEPTED', 'Acceptée', '✅'),
  preparing('PREPARING', 'En préparation', '👨‍🍳'),
  delivering('DELIVERING', 'En livraison', '🚚'),
  delivered('DELIVERED', 'Livrée', '📦'),
  waitingReturn('WAITING_RETURN', 'Retour matériel', '🔄'),
  completed('COMPLETED', 'Terminée', '🎉'),
  cancelled('CANCELLED', 'Annulée', '❌');

  final String value;
  final String label;
  final String emoji;

  const OrderStatus(this.value, this.label, this.emoji);

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OrderStatus.placed,
    );
  }

  /// Couleur associée au statut
  int get colorValue {
    switch (this) {
      case OrderStatus.placed:
        return 0xFF1565C0; // Bleu info
      case OrderStatus.accepted:
        return 0xFF2E7D32; // Vert success
      case OrderStatus.preparing:
        return 0xFFD4AF37; // Or warning
      case OrderStatus.delivering:
        return 0xFFD4AF37; // Or warning
      case OrderStatus.delivered:
        return 0xFF2E7D32; // Vert success
      case OrderStatus.waitingReturn:
        return 0xFFD4AF37; // Or warning
      case OrderStatus.completed:
        return 0xFF2E7D32; // Vert success
      case OrderStatus.cancelled:
        return 0xFFB71C1C; // Rouge danger
    }
  }
}

/// Modèle pour l'historique de statut
class OrderHistoryModel {
  final String status;
  final DateTime changedAt;
  final int? changedByUserId;
  final String? note;

  OrderHistoryModel({
    required this.status,
    required this.changedAt,
    this.changedByUserId,
    this.note,
  });

  factory OrderHistoryModel.fromJson(Map<String, dynamic> json) {
    return OrderHistoryModel(
      status: json['status'] as String,
      changedAt: DateTime.parse(json['changed_at'] as String),
      changedByUserId: json['changed_by_user_id'] as int?,
      note: json['note'] as String?,
    );
  }

  String get formattedDate =>
      DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(changedAt);
}

/// Modèle pour le détail d'une commande avec historique
class OrderDetailModel extends OrderModel {
  final List<OrderHistoryModel> history;

  OrderDetailModel({
    required super.id,
    required super.userId,
    required super.menuId,
    required super.eventAddress,
    required super.eventCity,
    required super.eventDate,
    required super.eventTime,
    required super.deliveryKm,
    required super.deliveryFee,
    required super.peopleCount,
    required super.menuPrice,
    required super.discount,
    required super.totalPrice,
    required super.status,
    required super.hasLoanedEquipment,
    required this.history,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    final baseOrder = OrderModel.fromJson(json);

    return OrderDetailModel(
      id: baseOrder.id,
      userId: baseOrder.userId,
      menuId: baseOrder.menuId,
      eventAddress: baseOrder.eventAddress,
      eventCity: baseOrder.eventCity,
      eventDate: baseOrder.eventDate,
      eventTime: baseOrder.eventTime,
      deliveryKm: baseOrder.deliveryKm,
      deliveryFee: baseOrder.deliveryFee,
      peopleCount: baseOrder.peopleCount,
      menuPrice: baseOrder.menuPrice,
      discount: baseOrder.discount,
      totalPrice: baseOrder.totalPrice,
      status: baseOrder.status,
      hasLoanedEquipment: baseOrder.hasLoanedEquipment,
      history: (json['history'] as List<dynamic>?)
              ?.map(
                (h) => OrderHistoryModel.fromJson(h as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}
