import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class StatStripItem {
  final String value;
  final String label;
  final IconData icon;
  final Color accentColor;

  const StatStripItem({
    required this.value,
    required this.label,
    required this.icon,
    this.accentColor = AppColors.primary,
  });
}

/// One wide banner card holding several stats inline, separated by
/// dividers — a single strip rather than a grid of separate tiles.
class StatStrip extends StatelessWidget {
  final List<StatStripItem> items;

  const StatStrip({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: List.generate(items.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Container(
              width: 1,
              height: 32,
              color: AppColors.border,
              margin: const EdgeInsets.symmetric(horizontal: 4),
            );
          }
          final item = items[i ~/ 2];
          return Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, size: 16, color: item.accentColor),
                const SizedBox(width: 6),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          item.value,
                          style: AppTextStyles.headline.copyWith(fontSize: 18),
                        ),
                      ),
                      Text(
                        item.label,
                        style: AppTextStyles.label.copyWith(fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
