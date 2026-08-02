enum UserRole { admin, worker }

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final bool mustChangePassword;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.mustChangePassword = false,
  });

  factory UserModel.mockAdmin() => const UserModel(
        id: 'admin_1',
        name: 'Alex Rivera',
        email: 'admin@robox.ai',
        role: UserRole.admin,
        mustChangePassword: false,
      );

  factory UserModel.mockWorker() => const UserModel(
        id: 'worker_1',
        name: 'Jordan Smith',
        email: 'jordan@robox.ai',
        role: UserRole.worker,
        mustChangePassword: false,
      );
}
