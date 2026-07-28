import '../models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> login(String email, String password);
}

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<UserModel?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (email.isEmpty || password.isEmpty) return null;

    final role = _resolveRole(email, password);
    
    if (role == UserRole.admin) {
      return UserModel(
        id: 'admin_1',
        name: 'Jomeme Admin',
        email: email.toLowerCase(),
        role: UserRole.admin,
      );
    } else {
      return UserModel(
        id: 'worker_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Worker Operator',
        email: email.toLowerCase(),
        role: UserRole.worker,
      );
    }
  }

  UserRole _resolveRole(String email, String password) {
    if (email.toLowerCase() == 'jomeme@gmail.com' && password == '12345678') {
      return UserRole.admin;
    }
    return UserRole.worker;
  }
}
