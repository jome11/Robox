import '../models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> login(String email, String password);
  Future<void> signup(String name, String email, String password);
}

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<UserModel?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (email.isEmpty || password.isEmpty) return null;

    // Simulate "pending approval" for a specific email for testing
    if (email.toLowerCase() == 'pending@robox.ai') {
      throw Exception('ACCOUNT_PENDING');
    }

    final role = _resolveRole(email, password);
    
    if (role == UserRole.admin) {
      if (email.toLowerCase() == 'jomeme@gmail.com' && password == '12345678') {
        return UserModel(
          id: 'admin_1',
          name: 'Jomeme Admin',
          email: email.toLowerCase(),
          role: UserRole.admin,
        );
      }
      return null; // For admin, we keep exact match for now
    } else {
      // For worker, accept any for now except if we want to simulate failure
      if (password == 'wrong') return null;
      
      return UserModel(
        id: 'worker_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Worker',
        email: email.toLowerCase(),
        role: UserRole.worker,
      );
    }
  }

  @override
  Future<void> signup(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Simulations
    if (email.toLowerCase() == 'exists@robox.ai') {
      throw Exception('EMAIL_EXISTS');
    }
    if (email.toLowerCase() == 'pending@robox.ai') {
      throw Exception('EMAIL_PENDING');
    }
    // Success simulation
  }

  UserRole _resolveRole(String email, String password) {
    if (email.toLowerCase() == 'jomeme@gmail.com' && password == '12345678') {
      return UserRole.admin;
    }
    return UserRole.worker;
  }
}
