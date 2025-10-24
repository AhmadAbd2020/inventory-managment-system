import 'package:get/get.dart';
import 'package:inventory_management/features/auth/models/user_model.dart';
import 'package:inventory_management/features/auth/services/auth_local_data_source.dart';

class UserController extends GetxController {
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    loadUser();
    super.onInit();
  }

  void loadUser() {
    final user = AuthLocalDataSourceImpl().getCachedUser();

    currentUser.value = user;
  }

  String get userRole => currentUser.value?.role ?? 'Guest';

  bool get isAdmin => userRole == 'Admin';
  bool get isViewer => userRole == 'Viewer';
  bool get isEditor => userRole == 'Editor';
  bool get isGuest => userRole == 'Guest';
}
