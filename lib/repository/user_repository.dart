import '../models/user.dart';

abstract class UserRepository {
  Future<User?> login(String email, String password);
}
