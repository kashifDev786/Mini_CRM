import '../models/user_model.dart';
import 'package:hive/hive.dart';

class LocalUserDataSource {
  final Box<UserModel> userBox = Hive.box<UserModel>('users');

  Future<UserModel?> getUser(String email, String password) async {
    try {
      return userBox.values.firstWhere(
            (user) => user.email == email && user.password == password,
      );
    } catch (e) {
      return null; // Return null if no user found
    }
  }

  Future<void> addUser(UserModel user) async {
    await userBox.add(user);
  }
}
