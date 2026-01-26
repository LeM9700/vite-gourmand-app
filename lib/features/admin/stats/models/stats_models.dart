import 'package:flutter/material.dart';

/// Modèles de données pour les statistiques admin

/// Statistiques de commandes par menu
class OrdersByMenuData {
  final String startDate;
  final String endDate;
  final int totalOrders;
  final double totalRevenue;
  final List<MenuOrderStats> menus;

  OrdersByMenuData({
    required this.startDate,
    required this.endDate,
    required this.totalOrders,
    required this.totalRevenue,
    required this.menus,
  });

  factory OrdersByMenuData.fromJson(Map<String, dynamic> json) {
    return OrdersByMenuData(
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      totalOrders: json['total_orders'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      menus:
          (json['menus'] as List?)
              ?.map((m) => MenuOrderStats.fromJson(m))
              .toList() ??
          [],
    );
  }
}

class MenuOrderStats {
  final int menuId;
  final String? menuName;
  final int ordersCount;
  final double totalRevenue;
  final double avgOrderValue;
  final String? firstOrderDate;
  final String? lastOrderDate;

  MenuOrderStats({
    required this.menuId,
    this.menuName,
    required this.ordersCount,
    required this.totalRevenue,
    required this.avgOrderValue,
    this.firstOrderDate,
    this.lastOrderDate,
  });

  factory MenuOrderStats.fromJson(Map<String, dynamic> json) {
    return MenuOrderStats(
      menuId: json['menu_id'] ?? 0,
      menuName: json['menu_name'],
      ordersCount: json['orders_count'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      avgOrderValue: (json['avg_order_value'] ?? 0).toDouble(),
      firstOrderDate: json['first_order_date'],
      lastOrderDate: json['last_order_date'],
    );
  }
}

/// Chiffre d'affaires par menu
class RevenueByMenuData {
  final String startDate;
  final String endDate;
  final int? menuId;
  final double totalRevenue;
  final int totalOrders;
  final List<MenuRevenueStats> data;

  RevenueByMenuData({
    required this.startDate,
    required this.endDate,
    this.menuId,
    required this.totalRevenue,
    required this.totalOrders,
    required this.data,
  });

  factory RevenueByMenuData.fromJson(Map<String, dynamic> json) {
    return RevenueByMenuData(
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      menuId: json['menu_id'],
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      totalOrders: json['total_orders'] ?? 0,
      data:
          (json['data'] as List?)
              ?.map((m) => MenuRevenueStats.fromJson(m))
              .toList() ??
          [],
    );
  }
}

class MenuRevenueStats {
  final int menuId;
  final String? menuName;
  final double periodRevenue;
  final int ordersCount;
  final double avgOrderValue;
  final double bestDayRevenue;
  final String? bestDayDate;

  MenuRevenueStats({
    required this.menuId,
    this.menuName,
    required this.periodRevenue,
    required this.ordersCount,
    required this.avgOrderValue,
    required this.bestDayRevenue,
    this.bestDayDate,
  });

  factory MenuRevenueStats.fromJson(Map<String, dynamic> json) {
    return MenuRevenueStats(
      menuId: json['menu_id'] ?? 0,
      menuName: json['menu_name'],
      periodRevenue: (json['period_revenue'] ?? 0).toDouble(),
      ordersCount: json['orders_count'] ?? 0,
      avgOrderValue: (json['avg_order_value'] ?? 0).toDouble(),
      bestDayRevenue: (json['best_day_revenue'] ?? 0).toDouble(),
      bestDayDate: json['best_day_date'],
    );
  }
}

/// Comparaison entre menus
class MenuComparisonData {
  final String startDate;
  final String endDate;
  final int totalMenus;
  final List<MenuComparison> menus;

  MenuComparisonData({
    required this.startDate,
    required this.endDate,
    required this.totalMenus,
    required this.menus,
  });

  factory MenuComparisonData.fromJson(Map<String, dynamic> json) {
    return MenuComparisonData(
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      totalMenus: json['total_menus'] ?? 0,
      menus:
          (json['menus'] as List?)
              ?.map((m) => MenuComparison.fromJson(m))
              .toList() ??
          [],
    );
  }
}

class MenuComparison {
  final int menuId;
  final String? menuName;
  final int ordersCount;
  final double revenue;
  final double? avgRating;
  final int reviewsCount;

  MenuComparison({
    required this.menuId,
    this.menuName,
    required this.ordersCount,
    required this.revenue,
    this.avgRating,
    required this.reviewsCount,
  });

  factory MenuComparison.fromJson(Map<String, dynamic> json) {
    return MenuComparison(
      menuId: json['menu_id'] ?? 0,
      menuName: json['menu_name'],
      ordersCount: json['orders_count'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
      avgRating:
          json['avg_rating'] != null
              ? (json['avg_rating'] as num).toDouble()
              : null,
      reviewsCount: json['reviews_count'] ?? 0,
    );
  }
}

/// Enum pour les types de graphiques
enum ChartType {
  bar,
  line,
  pie;

  String get label {
    switch (this) {
      case ChartType.bar:
        return 'Barres';
      case ChartType.line:
        return 'Lignes';
      case ChartType.pie:
        return 'Camembert';
    }
  }

  IconData get icon {
    switch (this) {
      case ChartType.bar:
        return Icons.bar_chart_rounded;
      case ChartType.line:
        return Icons.show_chart_rounded;
      case ChartType.pie:
        return Icons.pie_chart_rounded;
    }
  }
}
