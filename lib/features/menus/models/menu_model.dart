import 'package:flutter/foundation.dart';

class MenuModel {
  final int id;
  final String title;
  final String description;
  final String theme;
  final String regime;
  final int minPeople;
  final double basePrice;
  final String conditionsText;
  final int stock;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<MenuImage> images;
  final List<Dish> dishes;

  MenuModel({
    required this.id,
    required this.title,
    required this.description,
    required this.theme,
    required this.regime,
    required this.minPeople,
    required this.basePrice,
    required this.conditionsText,
    required this.stock,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    required this.images,
    required this.dishes,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      theme: json['theme'] ?? '',
      regime: json['regime'] ?? '',
      minPeople: json['min_people'] ?? 2,
      basePrice: _parseDouble(json['base_price']),
      conditionsText: json['conditions_text'] ?? '',
      stock: json['stock'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      images: _parseImages(json['images']),
      dishes: _parseDishes(json['dishes']),
    );
  }

  // Helper methods pour parser les listes
  static List<MenuImage> _parseImages(dynamic imagesData) {
    if (imagesData == null) return [];
    if (imagesData is! List) return [];
    
    try {
      return imagesData
          .map((img) => MenuImage.fromJson(img as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Erreur parsing images: $e');
      return [];
    }
  }

  static List<Dish> _parseDishes(dynamic dishesData) {
    if (dishesData == null) return [];
    if (dishesData is! List) return [];
    
    try {
      return dishesData
          .map((dish) => Dish.fromJson(dish as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Erreur parsing dishes: $e');
      return [];
    }
  }

  // Helper method pour parser les doubles qui peuvent être des strings
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  // Getter pour la première image (compatibilité)
  String? get imageUrl => images.isNotEmpty ? images.first.imageUrl : null;
}

class MenuImage {
  final int id;
  final int menuId;
  final String imageUrl;
  final String? altText;
  final int sortOrder;

  MenuImage({
    required this.id,
    required this.menuId,
    required this.imageUrl,
    this.altText,
    required this.sortOrder,
  });

  factory MenuImage.fromJson(Map<String, dynamic> json) {
    return MenuImage(
      id: json['id'] ?? 0,
      menuId: json['menu_id'] ?? 0,
      imageUrl: json['url'] ?? '', // Champ 'url' du backend
      altText: json['alt_text'],
      sortOrder: json['sort_order'] ?? 0,
    );
  }
}

class Dish {
  final int id;
  final String name;
  final String dishType; // STARTER, MAIN, DESSERT
  final String description;
  final List<DishAllergen> allergens;

  Dish({
    required this.id,
    required this.name,
    required this.dishType,
    required this.description,
    required this.allergens,
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['title'] ?? '',
      dishType: json['dish_type'] ?? 'MAIN',
      description: json['description'] ?? '',
      allergens: _parseAllergens(json['allergens']),
    );
  }

  static List<DishAllergen> _parseAllergens(dynamic allergensData) {
    if (allergensData == null) return [];
    if (allergensData is! List) return [];
    
    try {
      return allergensData
          .map((a) => DishAllergen.fromJson(a as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Erreur parsing allergens: $e');
      return [];
    }
  }

  // Getter pour compatibilité
  String get title => name;
  String get category => dishType;
  bool get isActive => true;
  
  // Getter pour le nom traduit du type
  String get dishTypeName {
    switch (dishType) {
      case 'STARTER':
        return 'Entrée';
      case 'MAIN':
        return 'Plat';
      case 'DESSERT':
        return 'Dessert';
      default:
        return dishType;
    }
  }
}

class DishAllergen {
  final int id;
  final String allergen;

  DishAllergen({
    required this.id,
    required this.allergen,
  });

  factory DishAllergen.fromJson(Map<String, dynamic> json) {
    return DishAllergen(
      id: json['id'] ?? 0,
      allergen: json['allergen'] ?? '',
    );
  }
}