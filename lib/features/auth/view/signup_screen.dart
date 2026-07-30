import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/signup_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/robox_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: BlocListener<SignupBloc, SignupState>(
        listener: (context, state) {
          if (state is SignupSuccess) {
            context.go('/pending-approval');
          }
          if (state is SignupError && state.field == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Image.asset(
                    'assets/logo.png',
                    height: 80,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.smart_toy_outlined,
                      size: 80,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Worker Registration',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headline.copyWith(fontSize: 32),
                ),
                const SizedBox(height: 8),
                Text(
                  'Submit your details for admin approval',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _nameController,
                  style: AppTextStyles.body,
                  decoration: const InputDecoration(
                    labelText: 'FULL NAME',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                BlocBuilder<SignupBloc, SignupState>(
                  builder: (context, state) {
                    final emailError = (state is SignupError && state.field == 'email')
                        ? state.message
                        : null;
                    return TextFormField(
                      controller: _emailController,
                      style: AppTextStyles.body,
                      decoration: InputDecoration(
                        labelText: 'EMAIL ADDRESS',
                        border: const OutlineInputBorder(),
                        errorText: emailError,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Email is required';
                        if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  style: AppTextStyles.body,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'SECURITY KEY',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Password is required';
                    if (value.length < 8) return 'Minimum 8 characters required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  style: AppTextStyles.body,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'CONFIRM SECURITY KEY',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please confirm your password';
                    if (value != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                BlocBuilder<SignupBloc, SignupState>(
                  builder: (context, state) {
                    if (state is SignupLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return RoboxButton(
                      label: 'SUBMIT REQUEST',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<SignupBloc>().add(
                                SignupSubmitted(
                                  name: _nameController.text,
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                ),
                              );
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
