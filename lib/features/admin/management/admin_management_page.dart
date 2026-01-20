import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/responsive.dart';
import '../../employee/orders/employee_orders_list_page.dart';
import '../../employee/moderation/moderation_page.dart';
import '../../employee/management/pages/menus_management_page.dart';
import '../../employee/management/pages/dishes_management_page.dart';
import '../../employee/management/pages/schedules_management_page.dart';

/// Page de gestion admin avec 5 onglets complets
/// Commandes, Modération, Menus, Plats, Horaires
class AdminManagementPage extends StatefulWidget {
  final int initialTabIndex;

  const AdminManagementPage({super.key, this.initialTabIndex = 0});

  @override
  State<AdminManagementPage> createState() => _AdminManagementPageState();
}

class _AdminManagementPageState extends State<AdminManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: context.horizontalPadding,
              right: context.horizontalPadding,
              bottom: 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gestion',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: const [
                    Tab(text: 'Commandes'),
                    Tab(text: 'Modération'),
                    Tab(text: 'Menus'),
                    Tab(text: 'Plats'),
                    Tab(text: 'Horaires'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                EmployeeOrdersListPage(),
                ModerationPage(),
                MenusManagementPage(),
                DishesManagementPage(),
                SchedulesManagementPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
