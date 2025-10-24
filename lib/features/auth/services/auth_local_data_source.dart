import 'package:sqflite/sqflite.dart';
import 'package:get_storage/get_storage.dart';

import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  UserModel? getCachedUser();
  Future<void> clearUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final GetStorage _storage = GetStorage();

  @override
  Future<void> cacheUser(UserModel user) async {
    _storage.write('user', user.toMap());
  }

  @override
  UserModel? getCachedUser() {
    final data = _storage.read('user');
    if (data == null) return null;

    try {
      var user = UserModel.fromMap(data);
      print(user.role);
      return user;
    } catch (e) {
      print('Error decoding cached user: $e');
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    await _storage.remove('user');
  }
}
