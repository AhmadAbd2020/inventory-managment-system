import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:inventory_management/core/util/app_colors.dart';
import 'package:inventory_management/features/home/controller/bottom_nav_controller.dart';
import 'package:inventory_management/features/home/view/settings/settings_screen.dart';
import 'package:inventory_management/features/inventory/view/add_new_item_screen.dart';
import 'package:inventory_management/features/site/views/add_site_screen.dart';
import 'package:inventory_management/features/inventory/view/inventory_screen.dart';
import 'package:inventory_management/features/site/views/sites_screen.dart';
import 'package:inventory_management/features/user_controller.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final BottomNavController navController = Get.put(BottomNavController());
  final UserController userController = Get.find<UserController>();
  final List<Widget> _screens = [
    InventoryScreen(),
    SitesScreen(),
    SettingsScreen(),
  ];
  final _titles = [
    'Inventory',
    'Sites',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          floatingActionButton:
              userController.isAdmin && navController.selectedIndex.value != 2
                  ? FloatingActionButton(
                      backgroundColor: Get.isDarkMode
                          ? AppColors.primaryDark
                          : AppColors.primary,
                      onPressed: () {
                        if (navController.selectedIndex.value == 0) {
                          print('object');
                          print(userController.isAdmin);
                          Get.to(() => AddItemScreen());
                        } else {
                          Get.to(() => AddSiteScreen());
                        }
                      },
                      child: Icon(
                        navController.selectedIndex.value == 0
                            ? Icons.add_box
                            : Icons.add_location_alt,
                        color: Colors.white,
                      ))
                  : null,
          appBar: AppBar(
            title: Text(_titles[navController.selectedIndex.value]),
          ),
          body: IndexedStack(
            index: navController.selectedIndex.value,
            children: _screens,
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                )
              ],
            ),
            child: GNav(
              gap: 8,
              activeColor: Colors.white,
              color: Theme.of(context)
                  .bottomNavigationBarTheme
                  .unselectedItemColor,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 300),
              tabBackgroundColor: Theme.of(context).primaryColor,
              tabs: const [
                GButton(
                  icon: Icons.inventory_2_outlined,
                  text: 'Inventory',
                ),
                GButton(
                  icon: Icons.location_on_outlined,
                  text: 'Sites',
                ),
                GButton(
                  icon: Icons.settings_outlined,
                  text: 'Settings',
                ),
              ],
              selectedIndex: navController.selectedIndex.value,
              onTabChange: navController.changeTab,
            ),
          ),
        ));
  }
}
