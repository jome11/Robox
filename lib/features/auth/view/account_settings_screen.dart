import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/robox_button.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../bloc/auth_bloc.dart';

class AccountSettingsScreen extends StatefulWidget {
  final UserModel user;

  const AccountSettingsScreen({
    super.key,
    required this.user,
  });

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final AuthRepository _authRepository = AuthRepositoryImpl();

  late final _nameController = TextEditingController(text: widget.user.name);
  late final _emailController = TextEditingController(text: widget.user.email);
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSavingProfile = false;
  bool _isSavingPassword = false;
  String? _emailError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    setState(() {
      _isSavingProfile = true;
      _emailError = null;
    });

    try {
      await _authRepository.updateProfile(
        name: name,
        email: email,
      );
      
      if (!mounted) return;

      // Update local state in AuthBloc
      final updatedUser = UserModel(
        id: widget.user.id,
        name: name,
        email: email,
        role: widget.user.role,
        mustChangePassword: widget.user.mustChangePassword,
      );
      context.read<AuthBloc>().add(UserUpdated(updatedUser));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
    } catch (e) {
      if (e.toString().contains('EMAIL_EXISTS')) {
        setState(() => _emailError = 'That email is already in use');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingProfile = false);
    }
  }

  Future<void> _savePassword() async {
    if (_newPasswordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 8 characters')),
      );
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isSavingPassword = true);
    try {
      await _authRepository.setNewPassword(_newPasswordController.text);
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update password. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isSavingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ACCOUNT SETTINGS', style: AppTextStyles.label),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PERSONAL INFORMATION', style: AppTextStyles.label.copyWith(color: AppColors.primary)),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              style: AppTextStyles.body,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                labelText: 'Email Address',
                border: const OutlineInputBorder(),
                errorText: _emailError,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            RoboxButton(
              label: _isSavingProfile ? 'SAVING...' : 'UPDATE PROFILE',
              onPressed: _isSavingProfile ? () {} : _saveProfile,
            ),

            const SizedBox(height: 40),
            const Divider(color: AppColors.border),
            const SizedBox(height: 24),

            Text('SECURITY', style: AppTextStyles.label.copyWith(color: AppColors.primary)),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              style: AppTextStyles.body,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              style: AppTextStyles.body,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            RoboxButton(
              label: _isSavingPassword ? 'UPDATING...' : 'CHANGE PASSWORD',
              isSecondary: true,
              onPressed: _isSavingPassword ? () {} : _savePassword,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
