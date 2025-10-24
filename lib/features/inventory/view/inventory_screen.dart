import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:inventory_management/core/util/theme/theme_controller.dart';
import 'package:inventory_management/features/inventory/controller/item_controller.dart';
import 'package:inventory_management/features/inventory/model/item_model.dart';
import 'package:inventory_management/features/inventory/view/add_new_item_screen.dart';
import 'package:inventory_management/features/inventory/view/item_details_screen.dart';
import 'package:inventory_management/features/inventory/view/modify_item_screen.dart';
import 'package:inventory_management/features/user_controller.dart';

class InventoryScreen extends StatelessWidget {
  final ItemController itemController = Get.put(ItemController());
  final UserController userController = Get.find<UserController>();

  InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: TextField(
            onChanged: (value) => itemController.applySearch(value),
            decoration: InputDecoration(
              hintText: 'Search items...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          child: Row(
            children: [
              Obx(() => Row(
                    children: [
                      Switch(
                        activeColor: Colors.red,
                        activeTrackColor: Colors.white,
                        value: itemController.showLowStockOnly.value,
                        onChanged: (value) =>
                            itemController.toggleLowStockFilter(value),
                      ),
                      Text(
                        'Low Stock',
                        style: textTheme.titleSmall,
                      ),
                    ],
                  )),
              const Spacer(),
              Obx(() => DropdownButton<SortOption>(
                    value: itemController.selectedSort.value,
                    onChanged: (SortOption? newValue) {
                      if (newValue != null) {
                        itemController.setSortOption(newValue);
                      }
                    },
                    items: [
                      DropdownMenuItem(
                        value: SortOption.name,
                        child: const Text('Sort by Name'),
                      ),
                      DropdownMenuItem(
                        value: SortOption.cost,
                        child: const Text('Sort by Cost'),
                      ),
                      DropdownMenuItem(
                        value: SortOption.quantity,
                        child: const Text('Sort by Quantity'),
                      ),
                    ],
                  )),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            final items = itemController.filteredItems;

            if (items.isEmpty) {
              return Center(
                child: Text(
                  "No items found",
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onBackground,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return userController.isAdmin || userController.isEditor
                    ? Slidable(
                        startActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) {
                                Get.to(() => ModifyItemScreen(itemId: item.id));
                              },
                              backgroundColor: Colors.blue,
                              icon: Icons.edit,
                              label: 'Edit',
                            ),
                            SlidableAction(
                              onPressed: (_) {
                                itemController.confirmDeleteItem(item.id);
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
                                Get.to(() => ModifyItemScreen(itemId: item.id));
                              },
                              backgroundColor: Colors.blue,
                              icon: Icons.edit,
                              label: 'Edit',
                            ),
                            SlidableAction(
                              onPressed: (_) {
                                itemController.confirmDeleteItem(item.id);
                              },
                              backgroundColor: Colors.red,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: ItemWidget(
                            item: item,
                            colorScheme: colorScheme,
                            textTheme: textTheme),
                      )
                    : ItemWidget(
                        item: item,
                        colorScheme: colorScheme,
                        textTheme: textTheme);
              },
            );
          }),
        ),
      ],
    );
  }
}

class ItemWidget extends StatelessWidget {
  const ItemWidget({
    super.key,
    required this.item,
    required this.colorScheme,
    required this.textTheme,
  });

  final ItemModel item;
  final ColorScheme colorScheme;
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
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: CachedNetworkImage(
            imageUrl: item.imageUrl,
            width: 50.w,
            height: 50.w,
            fit: BoxFit.cover,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
        title: Text(
          "${item.name} ( ${item.cost}\$ per unit )",
          style: textTheme.titleMedium?.copyWith(
            fontSize: 16.sp,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Row(
          children: [
            Text(
              'Remaining Quantity: ${item.quantity}',
              style: textTheme.bodyMedium?.copyWith(
                color: item.quantity < 100
                    ? Colors.red
                    : colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            if (item.quantity < 100) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 18,
              ),
            ],
          ],
        ),
        onTap: () => Get.to(() => ItemDetailsScreen(item: item)),
      ),
    );
  }
}
