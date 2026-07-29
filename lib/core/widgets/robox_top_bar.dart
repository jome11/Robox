import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../data/models/user_model.dart';
import '../../features/auth/bloc/auth_bloc.dart';

/// Persistent top bar shown above the bottom-nav shells: brand logo, a role
/// badge (Admin/Worker), and a sign-out action — same on every screen.
class RoboxTopBar extends StatelessWidget implements PreferredSizeWidget {
  final UserRole role;

  const RoboxTopBar({super.key, required this.role});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text('Robox', style: AppTextStyles.logo),
          const Spacer(),
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
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => context.read<AuthBloc>().add(LogoutRequested()),
            child: Text('Sign out', style: AppTextStyles.body.copyWith(color: AppColors.textMuted, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
