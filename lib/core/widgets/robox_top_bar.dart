import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../data/models/user_model.dart';
import '../../features/auth/bloc/auth_bloc.dart';

/// Persistent top bar shown above the bottom-nav shells.
/// Uses [AppBar] internally to handle system status bar insets (SafeArea) automatically.
class RoboxTopBar extends StatelessWidget implements PreferredSizeWidget {
  final UserRole role;

  const RoboxTopBar({super.key, required this.role});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      shape: const Border(bottom: BorderSide(color: AppColors.border)),
      title: Text('Robox', style: AppTextStyles.logo),
      actions: [
        IconButton(
          onPressed: () {
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated) {
              context.push('/account/settings', extra: authState.user);
            }
          },
          icon: const Icon(Icons.settings_outlined, color: AppColors.textMuted, size: 20),
          tooltip: 'Account Settings',
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.secondary.withAlpha((0.25 * 255).toInt()),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            role == UserRole.admin ? 'ADMIN' : 'WORKER',
            style: AppTextStyles.label.copyWith(color: AppColors.secondary),
          ),
        ),
        const SizedBox(width: 8),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => context.read<AuthBloc>().add(LogoutRequested()),
              child: Text(
                'Sign out',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
