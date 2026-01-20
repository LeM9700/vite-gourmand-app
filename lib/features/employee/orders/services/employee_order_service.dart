import '../../../../core/api/dio_client.dart';
import 'package:dio/dio.dart';
import '../models/order_employee_model.dart';

class EmployeeOrderService {
  DioClient? _dioClient;

  Future<void> _initializeClient() async {
    _dioClient ??= await DioClient.create();
  }

  /// Récupère toutes les commandes (avec infos client et menu)
  Future<List<OrderEmployeeModel>> getOrders({
    String? status,
    String? clientName,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? city,
  }) async {
    await _initializeClient();

    try {
      final queryParams = <String, dynamic>{};
      
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (clientName != null && clientName.isNotEmpty) {
        queryParams['client_name'] = clientName;
      }
      if (dateFrom != null) {
        queryParams['date_from'] = dateFrom.toIso8601String().split('T')[0];
      }
      if (dateTo != null) {
        queryParams['date_to'] = dateTo.toIso8601String().split('T')[0];
      }
      if (city != null && city.isNotEmpty) {
        queryParams['city'] = city;
      }

      final response = await _dioClient!.dio.get(
        '/orders',
        queryParameters: queryParams,
      );

      List<dynamic> ordersData;
      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        ordersData = map['items'] ?? [];
      } else if (response.data is List) {
        ordersData = response.data as List;
      } else {
        ordersData = [];
      }

      return ordersData
          .map((json) => OrderEmployeeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des commandes: $e');
    }
  }

  /// Récupère le détail d'une commande avec historique
  Future<OrderEmployeeModel> getOrderDetail(int orderId) async {
    await _initializeClient();

    try {
      final response = await _dioClient!.dio.get('/orders/$orderId');
      return OrderEmployeeModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Erreur lors du chargement de la commande: $e');
    }
  }

  /// Met à jour le statut d'une commande
  Future<OrderEmployeeModel> updateOrderStatus({
    required int orderId,
    required String newStatus,
    String? note,
  }) async {
    await _initializeClient();

    try {
      final response = await _dioClient!.dio.patch(
        '/orders/$orderId/status',
        data: {
          'status': newStatus,
          if (note != null && note.isNotEmpty) 'note': note,
        },
      );

      return OrderEmployeeModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 400) {
        final message = e.response?.data?['detail'] ?? 'Transition de statut non autorisée';
        throw Exception(message);
      }
      throw Exception('Erreur lors de la mise à jour du statut: $e');
    }
  }

  /// Annule une commande (avec motif et mode de contact obligatoires)
  Future<OrderEmployeeModel> cancelOrder({
    required int orderId,
    required String contactMode, // EMAIL ou PHONE
    required String reason,
  }) async {
    await _initializeClient();

    try {
      final response = await _dioClient!.dio.post(
        '/orders/$orderId/cancel',
        data: {
          'contact_mode': contactMode,
          'reason': reason,
        },
      );

      return OrderEmployeeModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 400) {
        final message = e.response?.data?['detail'] ?? 'Impossible d\'annuler cette commande';
        throw Exception(message);
      }
      throw Exception('Erreur lors de l\'annulation: $e');
    }
  }
}
