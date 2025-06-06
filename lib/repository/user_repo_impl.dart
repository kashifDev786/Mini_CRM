
import 'package:mini_crm/repository/user_repository.dart';

import '../models/user.dart';
import '../utils/localdatasource.dart';

class UserRepositoryImpl implements UserRepository {
  final LocalUserDataSource localDataSource;

  UserRepositoryImpl(this.localDataSource);

  @override
  Future<User?> login(String email, String password) async {
    final userModel = await localDataSource.getUser(email, password);
    if (userModel != null) {
      return User(email: userModel.email, password: userModel.password);
    }
    return null;
  }
}