import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/robox_button.dart';
import '../../../data/repositories/auth_repository.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _authRepository = AuthRepositoryImpl();
  bool _isLoading = false;
  String? _successMessage;
  String? _errorMessage;

  Future<void> _submitRequest() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email address');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _authRepository.forgotPassword(email);
      setState(() {
        _successMessage = 'A temporary password has been sent to your email.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        if (e.toString().contains('USER_NOT_FOUND')) {
          _errorMessage = 'No account found with this email.';
        } else {
          _errorMessage = 'Failed to request reset. Please check your connection.';
        }
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.lock_reset_outlined,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Reset Password',
                textAlign: TextAlign.center,
                style: AppTextStyles.headline,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your registered email and we\'ll send you a temporary password.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  border: const OutlineInputBorder(),
                  errorText: _errorMessage,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              if (_successMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    _successMessage!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(color: Colors.green),
                  ),
                ),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                RoboxButton(
                  label: 'SEND PASSWORD',
                  onPressed: _submitRequest,
                ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text(
                  'BACK TO SIGN IN',
                  style: AppTextStyles.label.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
