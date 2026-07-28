import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title.toUpperCase(), style: AppTextStyles.label),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Text('Content for $title', style: AppTextStyles.body),
      ),
    );
  }
}
