import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:inventory_management/features/site/controller/modify_site_controller.dart';
import 'package:inventory_management/features/inventory/controller/transactions_controller.dart';
import 'package:inventory_management/features/site/models/site_model.dart';
import 'package:inventory_management/features/site/views/site_detail_screen.dart';
import 'package:inventory_management/features/user_controller.dart';

class SitesScreen extends StatelessWidget {
  final TransactionController controller = Get.put(TransactionController());
  final ModifySiteController modifySiteController =
      Get.put(ModifySiteController());
  final UserController userController = Get.find<UserController>();

  SitesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Obx(() {
      final sites = controller.sites;
      return ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        itemCount: sites.length,
        itemBuilder: (_, index) {
          final site = sites[index];
          return userController.isAdmin || userController.isEditor
              ? Slidable(
                  key: ValueKey(site.id),
                  startActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) {
                          _showEditDialog(site);
                        },
                        backgroundColor: Colors.blue,
                        icon: Icons.edit,
                        label: 'Edit',
                      ),
                      SlidableAction(
                        onPressed: (_) {
                          modifySiteController.confirmDeleteSite(site.id);
                        },
                        backgroundColor: Colors.red,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) {
                          _showEditDialog(site);
                        },
                        backgroundColor: Colors.blue,
                        icon: Icons.edit,
                        label: 'Edit',
                      ),
                      SlidableAction(
                        onPressed: (_) {
                          modifySiteController.confirmDeleteSite(site.id);
                        },
                        backgroundColor: Colors.red,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: SiteWidget(
                      colorScheme: colorScheme,
                      site: site,
                      textTheme: textTheme),
                )
              : SiteWidget(
                  colorScheme: colorScheme, site: site, textTheme: textTheme);
        },
      );
    });
  }

  void _showEditDialog(SiteModel site) {
    Get.defaultDialog(
      title: "Edit Site Name",
      content: Column(
        children: [
          TextField(
            controller: modifySiteController.nameController,
            decoration: const InputDecoration(
              labelText: "New Site Name",
              border: OutlineInputBorder(),
            ),
          ),
          Obx(() => modifySiteController.isLoading.value
              ? const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: CircularProgressIndicator(),
                )
              : const SizedBox.shrink()),
        ],
      ),
      textConfirm: "Save",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      onConfirm: () {
        modifySiteController.updateSite(site.id);
      },
    );
  }
}

class SiteWidget extends StatelessWidget {
  const SiteWidget({
    super.key,
    required this.colorScheme,
    required this.site,
    required this.textTheme,
  });

  final ColorScheme colorScheme;
  final SiteModel site;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
        title: Text(
          site.name,
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        onTap: () => Get.to(() => SiteDetailScreen(site: site)),
      ),
    );
  }
}
