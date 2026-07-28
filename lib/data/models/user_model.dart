enum UserRole { admin, worker }

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserModel.mockAdmin() => const UserModel(
        id: 'admin_1',
        name: 'Alex Rivera',
        email: 'admin@robox.ai',
        role: UserRole.admin,
      );

  factory UserModel.mockWorker() => const UserModel(
        id: 'worker_1',
        name: 'Jordan Smith',
        email: 'jordan@robox.ai',
        role: UserRole.worker,
      );
}
