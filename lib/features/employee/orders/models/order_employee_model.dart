import '../../../orders/models/order_model.dart';
import '../../../orders/models/user_info_model.dart';
import '../../../menus/models/menu_model.dart';

/// Modèle étendu de commande pour l'espace employé
/// Inclut les informations du client et du menu
class OrderEmployeeModel extends OrderModel {
  final UserInfoModel? customer;
  final MenuModel? menu;
  final OrderCancellationInfo? cancellation;

  final List<OrderHistoryModel>? history;

  OrderEmployeeModel({
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
    this.history,
    this.customer,
    this.menu,
    this.cancellation,
  });

  factory OrderEmployeeModel.fromJson(Map<String, dynamic> json) {
    return OrderEmployeeModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      menuId: json['menu_id'] ?? 0,
      eventAddress: json['event_address'] ?? '',
      eventCity: json['event_city'] ?? '',
      eventDate: DateTime.tryParse(json['event_date'] ?? '') ?? DateTime.now(),
      eventTime: json['event_time'] ?? '',
      deliveryKm:
          double.tryParse(json['delivery_km']?.toString() ?? '0') ?? 0.0,
      deliveryFee:
          double.tryParse(json['delivery_fee']?.toString() ?? '0') ?? 0.0,
      peopleCount: json['people_count'] ?? 0,
      menuPrice: double.tryParse(json['menu_price']?.toString() ?? '0') ?? 0.0,
      discount: double.tryParse(json['discount']?.toString() ?? '0') ?? 0.0,
      totalPrice:
          double.tryParse(json['total_price']?.toString() ?? '0') ?? 0.0,
      status: OrderStatus.fromString(json['status'] ?? 'PLACED'),
      hasLoanedEquipment: json['has_loaned_equipment'] ?? false,
      history:
          (json['history'] as List<dynamic>?)
              ?.map(
                (h) => OrderHistoryModel.fromJson(h as Map<String, dynamic>),
              )
              .toList(),
      customer:
          json['customer'] != null
              ? UserInfoModel.fromJson(json['customer'] as Map<String, dynamic>)
              : null,
      menu:
          json['menu'] != null
              ? MenuModel.fromJson(json['menu'] as Map<String, dynamic>)
              : null,
      cancellation:
          json['cancellation'] != null
              ? OrderCancellationInfo.fromJson(
                json['cancellation'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['customer'] = customer?.toJson();
    if (menu != null) {
      json['menu'] = {
        'id': menu!.id,
        'title': menu!.title,
        'base_price': menu!.basePrice,
      };
    }
    json['cancellation'] = cancellation?.toJson();
    return json;
  }
}

/// Informations sur l'annulation d'une commande
class OrderCancellationInfo {
  final int id;
  final int orderId;
  final int cancelledByUserId;
  final String contactMode; // EMAIL ou PHONE
  final String reason;
  final DateTime createdAt;

  OrderCancellationInfo({
    required this.id,
    required this.orderId,
    required this.cancelledByUserId,
    required this.contactMode,
    required this.reason,
    required this.createdAt,
  });

  factory OrderCancellationInfo.fromJson(Map<String, dynamic> json) {
    return OrderCancellationInfo(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      cancelledByUserId: json['cancelled_by_user_id'] ?? 0,
      contactMode: json['contact_mode'] ?? 'EMAIL',
      reason: json['reason'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'cancelled_by_user_id': cancelledByUserId,
      'contact_mode': contactMode,
      'reason': reason,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Transitions de statut autorisées
class OrderStatusTransitions {
  static const Map<String, List<String>> allowed = {
    'PLACED': ['ACCEPTED', 'CANCELLED'],
    'ACCEPTED': ['PREPARING', 'CANCELLED'],
    'PREPARING': ['DELIVERING'],
    'DELIVERING': ['DELIVERED'],
    'DELIVERED': ['WAITING_RETURN', 'COMPLETED'],
    'WAITING_RETURN': ['COMPLETED'],
    'COMPLETED': [],
    'CANCELLED': [],
  };

  static List<String> getAllowedTransitions(String currentStatus) {
    return allowed[currentStatus] ?? [];
  }

  static bool canTransition(String from, String to) {
    return getAllowedTransitions(from).contains(to);
  }
}

/// Labels pour les statuts
class OrderStatusLabels {
  static const Map<String, String> labels = {
    'PLACED': 'Reçue',
    'ACCEPTED': 'Acceptée',
    'PREPARING': 'En préparation',
    'DELIVERING': 'En livraison',
    'DELIVERED': 'Livrée',
    'WAITING_RETURN': 'Attente retour matériel',
    'COMPLETED': 'Terminée',
    'CANCELLED': 'Annulée',
  };

  static String getLabel(String status) {
    return labels[status] ?? status;
  }
}
