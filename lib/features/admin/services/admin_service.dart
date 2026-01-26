import 'package:dio/dio.dart';
import '../../../../core/api/dio_client.dart';
import '../employees/models/employee_model.dart';

/// Service pour les appels API admin
/// Gestion des employés et statistiques
class AdminService {
  DioClient? _dio;

  Future<DioClient> _getDio() async {
    _dio ??= await DioClient.create();
    return _dio!;
  }

  // ==================== EMPLOYÉS ====================

  /// Récupère la liste de tous les employés
  Future<List<EmployeeModel>> getEmployees() async {
    try {
      final dio = await _getDio();
      final response = await dio.dio.get('/admin/employees');
      final List<dynamic> data = response.data as List;
      return data.map((json) => EmployeeModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des employés: $e');
    }
  }

  /// Crée un nouvel employé
  Future<EmployeeModel> createEmployee(CreateEmployeeRequest request) async {
    try {
      final dio = await _getDio();
      final response = await dio.dio.post(
        '/auth/create-employee',
        data: request.toJson(),
      );
      return EmployeeModel.fromJson(response.data);
    } catch (e) {
      if (e is DioException && e.response != null) {
        final detail = e.response?.data['detail'];
        if (detail != null) {
          throw Exception(detail);
        }
      }
      throw Exception('Erreur lors de la création de l\'employé: $e');
    }
  }

  /// Active ou désactive un employé
  Future<Map<String, dynamic>> toggleEmployeeActive({
    required int employeeId,
    required bool isActive,
  }) async {
    try {
      final dio = await _getDio();
      final response = await dio.dio.patch(
        '/admin/employees/$employeeId/toggle-active',
        data: {'is_active': isActive},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final detail = e.response?.data['detail'];
        if (detail != null) {
          throw Exception(detail);
        }
      }
      throw Exception('Erreur lors de la modification du statut: $e');
    }
  }

  // ==================== STATISTIQUES ====================

  /// Récupère les statistiques de commandes par menu
  Future<Map<String, dynamic>> getOrdersByMenu({
    required String startDate, // Format: YYYY-MM-DD
    required String endDate,
    int? menuId,
  }) async {
    try {
      final dio = await _getDio();
      final queryParams = {'start_date': startDate, 'end_date': endDate};
      if (menuId != null) {
        queryParams['menu_id'] = menuId.toString();
      }

      final response = await dio.dio.get(
        '/admin/stats/orders-by-menu',
        queryParameters: queryParams,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Erreur lors du chargement des statistiques: $e');
    }
  }

  /// Récupère le chiffre d'affaires par menu
  Future<Map<String, dynamic>> getRevenueByMenu({
    required String startDate,
    required String endDate,
    List<int>? menuIds,
  }) async {
    try {
      final dio = await _getDio();
      final queryParams = {'start_date': startDate, 'end_date': endDate};
      if (menuIds != null && menuIds.isNotEmpty) {
        queryParams['menu_ids'] = menuIds.join(',');
      }

      final response = await dio.dio.get(
        '/admin/stats/revenue-by-menu',
        queryParameters: queryParams,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Erreur lors du chargement du CA: $e');
    }
  }

  /// Récupère les données de comparaison entre menus
  Future<Map<String, dynamic>> getMenuComparison({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final dio = await _getDio();
      final response = await dio.dio.get(
        '/admin/stats/comparison',
        queryParameters: {'start_date': startDate, 'end_date': endDate},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Erreur lors du chargement de la comparaison: $e');
    }
  }

  // ==================== DASHBOARD KPI ====================

  /// Récupère les KPI du jour (commandes, CA, etc.)
  Future<Map<String, dynamic>> getTodayKpi() async {
    try {
      final dio = await _getDio();
      final response = await dio.dio.get('/admin/stats/dashboard/kpi');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Erreur lors du chargement des KPI: $e');
    }
  }
}
