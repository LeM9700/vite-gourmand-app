import '../../../../core/api/dio_client.dart';
import '../../../menus/models/menu_model.dart';

class ManagementService {
  DioClient? _dio;

  Future<DioClient> _getDio() async {
    _dio ??= await DioClient.create();
    return _dio!;
  }

  // ==================== MENUS ====================

  Future<List<MenuModel>> getMenus() async {
    try {
      final dio = await _getDio();
      final response = await dio.dio.get(
        '/menus',
        queryParameters: {'active_only': 'false'},
      );

      // L'API retourne {"items": [...]}
      final data = response.data;
      List<dynamic> menusList;

      if (data is Map<String, dynamic> && data.containsKey('items')) {
        menusList = data['items'] as List<dynamic>;
      } else if (data is List) {
        menusList = data;
      } else {
        menusList = [];
      }

      return menusList
          .map((json) => MenuModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des menus: $e');
    }
  }

  Future<MenuModel> createMenu(Map<String, dynamic> menuData) async {
    try {
      final dio = await _getDio();
      final response = await dio.dio.post('/menus', data: menuData);
      return MenuModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la création du menu: $e');
    }
  }

  Future<MenuModel> updateMenu(
    int menuId,
    Map<String, dynamic> menuData,
  ) async {
    try {
      final dio = await _getDio();
      final response = await dio.dio.patch('/menus/$menuId', data: menuData);
      return MenuModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du menu: $e');
    }
  }

  Future<void> deleteMenu(int menuId) async {
    try {
      final dio = await _getDio();
      await dio.dio.delete('/menus/$menuId');
    } catch (e) {
      throw Exception('Erreur lors de la suppression du menu: $e');
    }
  }

  // ==================== DISHES ====================

  Future<List<Map<String, dynamic>>> getDishes() async {
    try {
      final dio = await _getDio();
      final response = await dio.dio.get('/dishes');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des plats: $e');
    }
  }

  Future<Map<String, dynamic>> createDish(Map<String, dynamic> dishData) async {
    try {
      final dio = await _getDio();
      final response = await dio.dio.post('/dishes', data: dishData);
      return response.data;
    } catch (e) {
      throw Exception('Erreur lors de la création du plat: $e');
    }
  }

  Future<Map<String, dynamic>> updateDish(
    int dishId,
    Map<String, dynamic> dishData,
  ) async {
    try {
      final dio = await _getDio();
      final response = await dio.dio.patch('/dishes/$dishId', data: dishData);
      return response.data;
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du plat: $e');
    }
  }

  Future<void> deleteDish(int dishId) async {
    try {
      final dio = await _getDio();
      await dio.dio.delete('/dishes/$dishId');
    } catch (e) {
      throw Exception('Erreur lors de la suppression du plat: $e');
    }
  }

  // ==================== SCHEDULES ====================

  Future<List<Map<String, dynamic>>> getSchedules() async {
    try {
      final dio = await _getDio();
      final response = await dio.dio.get('/schedules');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des horaires: $e');
    }
  }

  Future<Map<String, dynamic>> createSchedule(
    Map<String, dynamic> scheduleData,
  ) async {
    try {
      final dio = await _getDio();
      final response = await dio.dio.post('/schedules', data: scheduleData);
      return response.data;
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'horaire: $e');
    }
  }

  Future<Map<String, dynamic>> updateSchedule(
    int scheduleId,
    Map<String, dynamic> scheduleData,
  ) async {
    try {
      final dio = await _getDio();
      final response = await dio.dio.put(
        '/schedules/$scheduleId',
        data: scheduleData,
      );
      return response.data;
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'horaire: $e');
    }
  }

  Future<void> deleteSchedule(int scheduleId) async {
    try {
      final dio = await _getDio();
      await dio.dio.delete('/schedules/$scheduleId');
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'horaire: $e');
    }
  }
}
