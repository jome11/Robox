import 'package:flutter/material.dart';

class RoboxButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isSecondary;

  const RoboxButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isSecondary) {
      return OutlinedButton(
        onPressed: onPressed,
        child: Text(label),
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}