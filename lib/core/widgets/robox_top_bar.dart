import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../data/models/user_model.dart';

class RoboxTopBar extends StatelessWidget implements PreferredSizeWidget {
  final UserRole role;

  const RoboxTopBar({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'ROBOX',
              style: AppTextStyles.label.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            role == UserRole.admin ? 'ADMIN OS' : 'OPERATOR OS',
            style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppColors.textMuted),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
