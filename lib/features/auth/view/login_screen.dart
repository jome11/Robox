import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/robox_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Image.asset(
                'assets/logo.png',
                height: 100,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.smart_toy_outlined,
                  size: 100,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Sign in to your workspace', textAlign: TextAlign.center, style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 40),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthError) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              builder: (context, state) {
                if (state is AuthLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return RoboxButton(
                  label: 'Sign In',
                  onPressed: () {
                    context.read<AuthBloc>().add(
                      LoginRequested(_emailController.text, _passwordController.text),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
